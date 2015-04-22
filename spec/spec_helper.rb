require 'codeclimate-test-reporter'
require 'simplecov'
require 'moon/packages'
require 'active_support/core_ext/string'

CodeClimate::TestReporter.start
SimpleCov.start

require 'moon-repository/load'

Moon::Repo.setup(:memory)

module Fixtures
  module People
    extend Moon::Repo::RepositoryBase

    def self.model
      Person
    end
  end

  class Person
    include Moon::Repo::RecordBase

    attr_accessor :id # required by Repo
    attr_accessor :name

    # You will implement this in your own class
    def initialize(params = {})
      params.each do |key, value|
        send("#{key}=", value)
      end
    end

    def repository
      People
    end
  end
end
