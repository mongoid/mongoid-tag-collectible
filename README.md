Mongoid::TagCollectible
=======================

[![Gem Version](http://img.shields.io/gem/v/mongoid-tag-collectible.svg)](http://badge.fury.io/rb/mongoid-tag-collectible)
[![Test](https://github.com/mongoid/mongoid-tag-collectible/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/mongoid/mongoid-tag-collectible/actions/workflows/test.yml?query=branch%3Amaster)
[![Coverage Status](https://coveralls.io/repos/github/mongoid/mongoid-tag-collectible/badge.svg?branch=master)](https://coveralls.io/github/mongoid/mongoid-tag-collectible?branch=master)

The Ruby 4.0 CI job measures library line coverage with SimpleCov and submits `coverage/.resultset.json` to Coveralls using GitHub's automatic token. Other matrix jobs do not submit duplicate reports. Run `COVERAGE=true bundle install` followed by `COVERAGE=true bundle exec rake spec` for a local report. The default-branch badge requires Coveralls to accept an upstream `master` build; configuring this workflow does not activate the external service.

Easily maintain a collection of `Tag` instances with aggregate counts from your model's `tags`.

### Compatibility

CI tests representative compatible combinations of Mongoid 3 through 9, Ruby 2.3 through 4.0, and MongoDB Server 2.6 through 8.0, including Ruby 4.0 / Mongoid 9 / MongoDB 8.0. See [the test matrix](.github/workflows/test.yml); this is not a Cartesian product of supported versions. Mongoid 3–4 use MongoDB 2.6 because their Moped driver enumerates collections via the removed `system.namespaces` collection. Set `MONGOID_VERSION` to select a Mongoid major version and `MONGODB_HOST` to override the default `localhost:27017` when running tests.

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

funny_tag = ThingTag.find('funny') # find by tag
funny_tag.name # "funny"
funny_tag.count # 2, not a database query
funny_tag.tagged # thing1 and thing2
```

#### Renaming Tags

You can rename a tag, which causes all the tags in your model's `tags` collection to be renamed.

``` ruby
ThingTag.find('funny').update_attributes!(name: 'sad')

Thing.first.tags # [ 'sad', 'red' ]
```

#### Destroying Tags

You can destroy a tag, which also removes it from your model's `tags` collection.

``` ruby
ThingTag.find('red').destroy
Thing.first.tags # [ 'sad' ]
```

#### Case-Sensitive

Tags are case-sensitive. Transform your tags in `before_validation` if you don't want this behavior.

``` ruby
class Thing
  before_validation :downcase_tags

  private

  def downcase_tags
    tags = tags.map(&:downcase) if tags
  end
end
```

### Contribute

See [CONTRIBUTING](CONTRIBUTING.md).

### Copyright and License

Copyright Daniel Doubrovkine and Contributors, Artsy Inc., 2013-2015

[MIT License](LICENSE.md)
