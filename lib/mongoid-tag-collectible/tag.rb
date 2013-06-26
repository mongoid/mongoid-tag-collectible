module Mongoid
  module TagCollectible
    class Tag
      include Mongoid::Document
      include Mongoid::Timestamps
      include Mongoid::Slug

      field :name, type: String
      slug :name, index: true
      index({ name: 1 })

      field :count, type: Integer, default: 0
      index({ count: -1 })

      before_destroy :remove_tags!
      attr_accessor :renaming

      def renaming?
        !! renaming
      end

      def tagged
        tagged_class.where(tags: self.name)
      end

      alias_method :_tag_build_slug, :build_slug
      def build_slug
        if ! new_record? && name_changed?
          self.class.where(name: name).each do |tag|
            tag.renaming = true
            tag.destroy
          end
          tagged_class.rename_tag!(name_was, name)
        end
        _tag_build_slug
      end

      def remove_tags!
        tagged_class.remove_tag!(self[:name]) unless renaming?
      end

      # tagging mechanisms from http://markembling.info/2010/11/using-map-reduce-in-a-mongodb-app
      def self.update!
        tags_before = self.all.group_by{ |t| t.name }

        map = <<-EOS
            function() {
              if (this.tags != null) {
                this.tags.forEach(function(t) {
                  if (t != null && t != "") {
                    emit(t, 1);
                  }
                });
              }
            }
        EOS

        reduce = <<-EOS
          function(key, values) {
            var count = 0;
            values.forEach(function(v) { count += v; });
            return count;
          }
        EOS

        tags_after = []
        tags_mapreduce = tagged_class.map_reduce(map, reduce).out(inline: true)['results']
        tags_mapreduce.each do |tag_mapreduce|
          name = tag_mapreduce['_id']
          next unless name
          tags = tags_before[name]
          count = tag_mapreduce['value'].to_i
          if ! tags
            self.create!(name: name, count: count)
          else # if there is more than one tag with the same name, keep the one with the shortest slug
            tag = tags.min_by{ |t| t.slug.length }
            attrs = {}
            attrs[:name] = name if name != tag.name
            attrs[:count] = count if count != tag.count
            tag.update_attributes!(attrs) if attrs.any?
          end
          tags_after << tag
        end
        (tags_before.values.flatten - tags_after).each do |tag|
          tag.destroy
        end
      end

      def check_tagged_class!
        unless tagged_class.respond_to?(:rename_tag!)
          raise "#{tagged_class.name} must include Mongoid::TagCollectible::Tagged"
        end
      end

    end
  end
end
