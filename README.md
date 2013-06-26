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
  include Mongoid::Timestamps
  include Mongoid::TagCollectible::Tagged
end

class ThingTag
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  include Mongoid::TagCollectible::Tag

  tag_for Thing
end

thing1 = Thing.create!(tags: [ 'funny', 'red' ])
thing2 = Thing.create!(tags: [ 'funny', 'yellow' ])

ThingTag.rebuild!

Thing.tagged # thing1 and thing2
ThingTag.count # 3 - funny, red and yellow

funny_tag = ThingTag.where(name: 'funny').first
funny_tag.count # 2
funny_tag.things # thing1, thing2
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
