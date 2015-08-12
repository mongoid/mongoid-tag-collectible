$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'
require 'mongoid-tag-collectible'

require 'support/mongoid'
require 'support/test_tagged'
require 'support/namespaced_test_tagged'

RSpec.configure(&:raise_errors_for_deprecations!)
