module Mongoid
  module TagCollectible
    module Tagged
      extend ActiveSupport::Concern

      included do
        field :tags, type: Array, default: []
        index({ tags: 1 })
        scope :tagged, -> { where(:tags.nin => [nil, []], :tags.ne => nil) }
        after_save :_update_tags!
        after_destroy :_destroy_tags!
        cattr_accessor :tag_class

        klass = Class.new do
          include Mongoid::TagCollectible::Tag
          cattr_accessor :tagged_class
        end
        klass.tagged_class = self
        klass.store_in collection: "#{name.underscore.gsub('/', '_')}_tags"
        parts = name.split('::')
        mod_name = parts[0..-2].join('::')
        mod_name = 'Object' if mod_name.blank?
        mod_name.constantize.const_set "#{name}Tag".demodulize, klass
        self.tag_class = "#{name}Tag".constantize
      end

      module ClassMethods
        if Mongoid::TagCollectible.mongoid3? || Mongoid::TagCollectible.mongoid4?
          def rename_tag!(old_tag, new_tag)
            collection.where(tags: old_tag).update({ '$addToSet' => { tags: new_tag } }, multi: true)
            self.remove_tag!(old_tag)
          end

          def remove_tag!(tag_name)
            collection.where(tags: tag_name).update({ '$pull' => { tags: tag_name } }, multi: true)
          end
        else
          def rename_tag!(old_tag, new_tag)
            collection.find(tags: old_tag).update_many({ '$addToSet' => { tags: new_tag } })
            self.remove_tag!(old_tag)
          end

          def remove_tag!(tag_name)
            collection.find(tags: tag_name).update_many({ '$pull' => { tags: tag_name } })
          end
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
          _update_tag!(tag, 1)
        end
        # removed tags
        (before - after).each do |tag|
          next unless tag && tag.length > 0
          _update_tag!(tag, -1)
        end
      end

      if Mongoid::TagCollectible.mongoid3? || Mongoid::TagCollectible.mongoid4?
        def _update_tag!(tag, count)
          tag_class.collection.find(
            name: tag,
            _type: tag_class.name
          ).upsert(
            '$inc' => { count: count }
          )
        end
      else
        def _update_tag!(tag, count)
          tag_class.collection.find(
            name: tag,
            _type: tag_class.name
          ).update_one(
            { '$inc' => { count: count } },
            upsert: true
          )
        end
      end

      def _destroy_tags!
        tags.each do |tag|
          next unless tag && tag.length > 0
          _update_tag!(tag, -1)
        end
      end
    end
  end
end
