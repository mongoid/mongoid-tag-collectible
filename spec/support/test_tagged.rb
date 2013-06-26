class TestTagged
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::TagCollectible::Tagged
end
