$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'
require 'mongoid-tag-collectible'

require 'support/mongoid'
require 'support/test_tagged'
require 'support/namespaced_test_tagged'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.before :all do
    Mongoid.logger.level = Logger::INFO
    Mongo::Logger.logger.level = Logger::INFO if Mongoid::Compatibility::Version.mongoid5?
  end
end
