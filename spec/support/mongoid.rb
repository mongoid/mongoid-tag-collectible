ENV['MONGOID_ENV'] = 'test'

if Mongoid::Compatibility::Version.mongoid3?
  Mongoid.load! 'spec/config/mongoid3.yml'
elsif Mongoid::Compatibility::Version.mongoid4?
  Mongoid.load! 'spec/config/mongoid4.yml'
else
  Mongoid.load! 'spec/config/mongoid5.yml'
end

RSpec.configure do |config|
  config.before(:all) do
    @indexes = []
    klass = TestTagged.tag_class
    if Mongoid::Compatibility::Version.mongoid3?
      TestTagged.tag_class.index_options.each_pair do |name, options|
        @indexes << [klass, name, options]
      end
    else
      klass.index_specifications.each do |index_specification|
        @indexes << [klass, index_specification.key, index_specification.options]
      end
    end
  end
  config.before do
    Mongoid.purge!
    @indexes.each do |klass, name, options|
      if Mongoid::Compatibility::Version.mongoid3? || Mongoid::Compatibility::Version.mongoid4?
        klass.collection.indexes.create(name, options)
      else
        klass.collection.indexes.create_one(name, options)
      end
    end
  end
  config.after(:all) do
    if Mongoid::Compatibility::Version.mongoid3? || Mongoid::Compatibility::Version.mongoid4?
      Mongoid.default_session.drop
    else
      Mongoid::Clients.default.database.drop
    end
  end
end
