ENV['MONGOID_ENV'] = 'test'

Mongoid.load! 'spec/config/mongoid.yml'

RSpec.configure do |config|
  config.before(:all) do
    @indexes = []
    klass = TestTagged.tag_class
    klass.index_specifications.each do |index_specification|
      next unless index_specification.options[:unique] || index_specification.key.values.include?('2d')
      @indexes << [klass, index_specification.key, index_specification.options]
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
