ENV["MONGOID_ENV"] = "test"

Mongoid.load! "config/mongoid.yml"

RSpec.configure do |config|
  config.before(:each) do
    Mongoid.purge!
  end
  config.after(:all) do
    Mongoid.default_session.drop
  end
end

