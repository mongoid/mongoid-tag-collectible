require 'bundler'
Bundler.setup(:default, :development)

require 'mongoid-tag-collectible'

Mongoid.configure do |config|
  config.connect_to('mongoid_tag_collectible_example')
end

class Thing
  include Mongoid::Document
  include Mongoid::TagCollectible::Tagged

  before_validation :downcase_tags

  private

  def downcase_tags
    tags = tags.map(&:downcase) if tags
  end
end

thing1 = Thing.create!(tags: [ 'funny', 'red' ])
thing2 = Thing.create!(tags: [ 'funny', 'yellow' ])

funny_tag = ThingTag.where(name: 'funny').first
puts funny_tag.name # funny
puts funny_tag.count # 2
p funny_tag.tagged.to_a # thing1 and thing2

# rename a tag
ThingTag.find('funny').update_attributes!(name: 'sad')
p Thing.first.tags # [ 'sad', 'red' ]

# delete a tag
ThingTag.find('red').destroy
p Thing.first.tags # [ 'sad' ]

Mongoid.default_session.drop
