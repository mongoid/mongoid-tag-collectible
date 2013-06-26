module Mongoid
  module TagCollectible
    module Tagged
      extend ActiveSupport::Concern

      included do
        field :tags, type: Array, default: []
        index({ tags: 1 })
        scope :tagged, where({ :tags.nin => [ nil, [] ], :tags.ne => nil })
        before_save :capitalize_tags
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

        def capitalize_tags
          self.tags = (self.tags || []).compact.map { |tag| Mongoid::TagCollectible::Tag.capitalize(tag) }
        end

    end
  end
end
