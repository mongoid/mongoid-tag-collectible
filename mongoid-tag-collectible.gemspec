$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'mongoid-tag-collectible/version'

Gem::Specification.new do |s|
  s.name = 'mongoid-tag-collectible'
  s.version = Mongoid::TagCollectible::VERSION
  s.authors = ['Daniel Doubrovkine']
  s.email = 'dblock@dblock.org'
  s.platform = Gem::Platform::RUBY
  s.required_rubygems_version = '>= 1.3.6'
  s.files = `git ls-files`.split("\n")
  s.require_paths = ['lib']
  s.homepage = 'http://github.com/mongoid/mongoid-tag-collectible'
  s.licenses = ['MIT']
  s.summary = "Easily maintain a collection of Tag instances with aggregate counts from your model's tags."
  s.add_dependency 'mongoid', '>= 3.0.0'
  s.add_dependency 'mongoid-compatibility'
  s.add_dependency 'activesupport'
end
