module Mongoid
  module TagCollectible
    class Tag
      include Mongoid::Document
      include Mongoid::Timestamps

      field :name, type: String
      index({ name: 1 }, { unique: true })

      field :count, type: Integer, default: 0
      index({ count: -1 })

      before_destroy :_remove_tags!
      before_update :_rename_tag!
      attr_accessor :renaming

      def renaming?
        !! renaming
      end

      def tagged
        tagged_class.where(tags: self.name)
      end

      def _remove_tags!
        tagged_class.remove_tag!(self[:name]) unless renaming?
      end

      def check_tagged_class!
        unless tagged_class.respond_to?(:rename_tag!)
          raise "#{tagged_class.name} must include Mongoid::TagCollectible::Tagged"
        end
      end

      def self.find(value)
        if Moped::BSON::ObjectId.legal?(value)
          super(value)
        else
          where(name: value).first
        end
      end

      private

      def _rename_tag!
        if ! new_record? && name_changed?
          self.class.where(name: name).each do |tag|
            tag.renaming = true
            tag.destroy
          end
          tagged_class.rename_tag!(name_was, name)
        end
      end

    end
  end
end
