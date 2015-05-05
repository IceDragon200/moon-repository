require_relative 'lib/moon-repository/version'

Gem::Specification.new do |s|
  s.name        = 'moon-repository'
  s.summary     = 'Moon Repository package.'
  s.description = 'Moon implementation of the Repository pattern.'
  s.homepage    = 'https://github.com/IceDragon200/moon-repository'
  s.email       = 'mistdragon100@gmail.com'
  s.version     = Moon::Repository::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.date        = Time.now.to_date.to_s
  s.license     = 'MIT'
  s.authors     = ['Blaž Hrastnik', 'Corey Powell']

  s.add_dependency 'activesupport',    '~> 4.2'
  s.add_development_dependency 'rake',    '~> 10.3'
  s.add_development_dependency 'yard',    '~> 0.8'
  s.add_development_dependency 'rspec',   '~> 3.2'
  s.add_development_dependency 'codeclimate-test-reporter'
  s.add_development_dependency 'simplecov'

  s.require_path = 'lib'
  s.files = []
  s.files += Dir.glob('lib/**/*.{rb,yml}')
  s.files += Dir.glob('spec/**/*')
end
