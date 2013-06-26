ENV["MONGOID_ENV"] = "test"

Mongoid.load! "spec/config/mongoid.yml"

RSpec.configure do |config|
  config.before(:each) do
    Mongoid.purge!
    TestTagged.tag_class.index_options.each_pair do |name, options|
      TestTagged.tag_class.collection.indexes.create(name, options)
    end
  end
  config.after(:all) do
    Mongoid.default_session.drop
  end
end

