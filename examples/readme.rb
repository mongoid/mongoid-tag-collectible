require 'bundler'
Bundler.setup(:default, :development)

require 'mongoid-tag-collectible'

Mongoid.configure do |config|
  config.connect_to('mongoid_tag_collectible_example')
end

class Thing
  include Mongoid::Document
  include Mongoid::TagCollectible::Tagged
end

thing1 = Thing.create!(tags: [ 'funny', 'red' ])
thing2 = Thing.create!(tags: [ 'funny', 'yellow' ])

ThingTag.update!

funny_tag = ThingTag.find('funny')
puts funny_tag.name
puts funny_tag.count
p funny_tag.tagged.to_a

Mongoid.default_session.drop
