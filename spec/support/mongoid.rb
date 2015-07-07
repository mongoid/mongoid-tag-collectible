ENV['MONGOID_ENV'] = 'test'

if Mongoid::TagCollectible.mongoid3?
  Mongoid.load! 'spec/config/mongoid3.yml'
else
  Mongoid.load! 'spec/config/mongoid4.yml'
end

RSpec.configure do |config|
  config.before(:all) do
    @indexes = []
    klass = TestTagged.tag_class
    if Mongoid::TagCollectible.mongoid3?
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
      klass.collection.indexes.create(name, options)
    end
  end
  config.after(:all) do
    Mongoid.default_session.drop
  end
end
