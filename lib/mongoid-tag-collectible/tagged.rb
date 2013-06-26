module Mongoid
  module TagCollectible
    module Tagged
      extend ActiveSupport::Concern

      included do
        field :tags, type: Array, default: []
        index({ tags: 1 })
        scope :tagged, where({ :tags.nin => [ nil, [] ], :tags.ne => nil })
        after_save :_update_tags!
        after_destroy :_destroy_tags!
        cattr_accessor :tag_class

        klass = Class.new(Mongoid::TagCollectible::Tag) do
          cattr_accessor :tagged_class
        end
        klass.tagged_class = self
        klass.store_in collection: "#{self.name.underscore}_tags"
        Object.const_set "#{self.name}Tag", klass
        self.tag_class = "#{self.name}Tag".constantize
      end

      module ClassMethods

        def rename_tag!(old_tag, new_tag)
          self.collection.where({ tags: old_tag }).update({ '$addToSet' => { tags: new_tag }}, multi: true)
          self.remove_tag!(old_tag)
        end

        def remove_tag!(tag_name)
          self.collection.where({ tags: tag_name }).update({'$pull' => { tags: tag_name}}, multi: true)
        end

      end

      private

      def _update_tags!
        return unless tags_changed?
        before = (tags_was || [])
        after = (tags || [])
        # added tags
        (after - before).each do |tag|
          next unless tag && tag.length > 0
          self.tag_class.collection.find(
            name: tag,
            _type: self.tag_class.name
          ).upsert(
            "$inc" => { count: 1 }
          )
        end
        # removed tags
        (before - after).each do |tag|
          next unless tag && tag.length > 0
          self.tag_class.collection.find(
            name: tag,
            _type: self.tag_class.name
          ).upsert(
            "$inc" => { count: -1 }
          )
        end
      end

      def _destroy_tags!
        tags.each do |tag|
          next unless tag && tag.length > 0
          self.tag_class.collection.find(
            name: tag,
            _type: self.tag_class.name
          ).upsert(
            "$inc" => { count: -1 }
          )
        end
      end

    end
  end
end
