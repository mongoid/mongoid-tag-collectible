$:.push File.expand_path("../lib", __FILE__)
require 'mongoid-tag-collectible/version'

Gem::Specification.new do |s|
  s.name = "mongoid-tag-collectible"
  s.version = Mongoid::TagCollectible::VERSION
  s.authors = [ "Daniel Doubrovkine" ]
  s.email = "dblock@dblock.org"
  s.platform = Gem::Platform::RUBY
  s.required_rubygems_version = '>= 1.3.6'
  s.files = `git ls-files`.split("\n")
  s.require_paths = [ "lib" ]
  s.homepage = "http://github.com/dblock/mongoid-tag-collectible"
  s.licenses = [ "MIT" ]
  s.summary = "Taggable objects with rollup."
  s.add_dependency "mongoid", ">= 3.0.0"
  s.add_dependency "activesupport"
end
