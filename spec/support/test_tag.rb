class TestTag
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  include Mongoid::TagCollectible::Tag

  tag_for TestTagged
end
