module Mongoid
  module TagCollectible
    def self.mongoid3?
      Mongoid::VERSION =~ /^3\./
    end

    def self.mongoid4?
      Mongoid::VERSION =~ /^4\./
    end

    def self.object_id?(value)
      self.mongoid3? ? Moped::BSON::ObjectId.legal?(value) : BSON::ObjectId.legal?(value)
    end
  end
end
