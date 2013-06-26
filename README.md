Mongoid::TagCollectible
=======================

[![Build Status](https://travis-ci.org/dblock/mongoid-tag-collectible.png)](https://travis-ci.org/dblock/mongoid-tag-collectible)

Maintain a collection of `Tag` instances with counts rolled up from your model's `tags`.

### Install

Add `mongoid-tag-collectible` to your Gemfile.

```
gem 'mongoid-tag-collectible'
```

### Use

``` ruby
class Thing
  include Mongoid::Document
  include Mongoid::TagCollectible::Tagged
end

thing1 = Thing.create!(tags: [ 'funny', 'red' ])
thing2 = Thing.create!(tags: [ 'funny', 'yellow' ])

ThingTag.update! # the `ThingTag` class is automatically defined

funny_tag = ThingTag.find('funny')
funny_tag.name # "funny"
funny_tag.count # 2, not a database query
funny_tag.tagged # thing1 and thing2
```

Tags are case-sensitive. Transform your tags in `before_validation` if you don't want this behavior.

``` ruby
class Thing
  before_validation :downcase_tags

  private

  def downcase_tags
    tags = tags.map(&:downcase)
  end
end
```

### Contribute

You're encouraged to contribute to this gem.

* Fork this project.
* Make changes, write tests.
* Updated CHANGELOG.
* Make a pull request, bonus points for topic branches.

### Copyright and License

Copyright Daniel Doubrovkine and Contributors, Artsy Inc., 2013

[MIT License](LICENSE.md)
