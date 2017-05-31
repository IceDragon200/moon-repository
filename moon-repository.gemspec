require_relative 'lib/moon-repository/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = 'moon-repository'
  s.summary     = 'Moon Repository package.'
  s.description = 'Moon implementation of the Repository pattern.'
  s.homepage    = 'https://github.com/polyfox/moon-repository'
  s.email       = 'mistdragon100@gmail.com'
  s.version     = Moon::Repository::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.date        = Time.now.to_date.to_s
  s.license     = 'MIT'
  s.authors     = ['Blaž Hrastnik', 'Corey Powell']

  s.add_dependency 'activesupport',              ['>= 4.2', '< 6.0']
  s.add_development_dependency 'rake',           '>= 11.0'
  s.add_development_dependency 'yard',           '~> 0.8'
  s.add_development_dependency 'rspec',          '~> 3.2'
  s.add_development_dependency 'simplecov'

  s.require_path = 'lib'
  s.files = []
  s.files += Dir.glob('lib/**/*.{rb,yml}')
  s.files += Dir.glob('spec/**/*')
end
