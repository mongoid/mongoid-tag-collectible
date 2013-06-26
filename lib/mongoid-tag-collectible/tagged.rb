module Mongoid
  module TagCollectible
    module Tagged
      extend ActiveSupport::Concern

      included do
        field :tags, type: Array, default: []
        index({ tags: 1 })
        scope :tagged, where({ :tags.nin => [ nil, [] ], :tags.ne => nil })

        klass = Class.new(Mongoid::TagCollectible::Tag) do
          cattr_accessor :tagged_class
        end
        klass.tagged_class = self
        klass.store_in collection: "#{self.name.underscore}_tags"
        Object.const_set "#{self.name}Tag", klass
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

    end
  end
end
