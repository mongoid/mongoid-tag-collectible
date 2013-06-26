module Mongoid
  module TagCollectible
    module Tag
      extend ActiveSupport::Concern

      included do
        raise "#{self.name} must include Mongoid::Slug" unless self.method_defined?(:build_slug)        
        field :name, type: String
        slug :name, index: true
        field :count, type: Integer, default: 0
        index({ count: -1 })
        index({ name: 1 })
        before_destroy :remove_tags!
        attr_accessor :renaming
      end

      class << self
        def capitalize(name)
          name = name.strip.capitalize
          name = name.split(" ").map{ |word| word.capitalize }.join(" ") if name =~ /\s/
          name = name.split("-").map{ |word| word.capitalize }.join("-") if name =~ /-/
          name
        end
      end

      module ClassMethods
        def tag_for(clazz)

          self.class_eval <<-RUBY

            raise "#{clazz.name} must include Mongoid::TagCollectible::Tagged" unless #{clazz}.respond_to?(:rename_tag!)

            def #{clazz.name.underscore.downcase.pluralize}
              #{clazz}.where(tags: self.name)
            end

            alias_method :_tag_build_slug, :build_slug
            def build_slug
              if ! new_record? && name_changed?
                self.class.where(name: name).each do |tag|
                  tag.renaming = true
                  tag.destroy
                end
                #{clazz}.rename_tag!(name_was, name)
              end
              _tag_build_slug
            end

            def remove_tags!
              #{clazz}.remove_tag!(self[:name]) unless renaming
            end

            # tagging mechanisms from http://markembling.info/2010/11/using-map-reduce-in-a-mongodb-app
            def self.rebuild!
              tags_before = self.all.group_by{ |t| t.name }

              map = <<-EOS
                  function() {
                    if (this.tags != null) {
                      this.tags.forEach(function(t) {
                        if (t != null && t != "") {
                          emit(t.toLowerCase(), 1);
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
              tags_mapreduce = #{clazz}.map_reduce(map, reduce).out(inline: true)['results']
              tags_mapreduce.each do |tag_mapreduce|
                name = Mongoid::TagCollectible::Tag.capitalize(tag_mapreduce['_id'])
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

          RUBY

        end
      end
    end
  end
end
