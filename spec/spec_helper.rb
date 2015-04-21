require 'codeclimate-test-reporter'
require 'simplecov'
require 'moon/packages'
require 'active_support/core_ext/string'

CodeClimate::TestReporter.start
SimpleCov.start

require 'moon-repository/load'
