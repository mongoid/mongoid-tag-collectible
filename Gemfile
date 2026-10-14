source 'https://rubygems.org'

gemspec

version = ENV['MONGOID_VERSION'] || '9'
gem 'mongoid', version =~ /\A\d+\z/ ? "~> #{version}.0" : version
gem 'bigdecimal' if RUBY_VERSION >= '3.4'
gem 'logger' if RUBY_VERSION >= '3.4'

group :development, :test do
  gem 'rspec'
  gem 'rake', RUBY_VERSION >= '3.0' ? '>= 12' : '< 12'
  gem 'rubocop', RUBY_VERSION >= '3.0' ? '~> 1.0' : '0.32.1'
  gem 'simplecov', '~> 0.22' if ENV['COVERAGE'] == 'true'
end
