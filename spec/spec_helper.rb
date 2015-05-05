require 'codeclimate-test-reporter'
require 'simplecov'
require 'yaml'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/hash'

CodeClimate::TestReporter.start
SimpleCov.start

require 'moon-repository/load'

def data_pathname(*paths)
  File.join(File.dirname(__FILE__), 'data', *paths)
end

module Fixtures
  module People
    extend Moon::Record::ClassMethods

    def self.model
      Person
    end
  end

  class Person
    include Moon::Record::InstanceMethods

    attr_accessor :id # required by Repo
    attr_accessor :name
    attr_accessor :junk

    # You will implement this in your own class
    def initialize(params = {})
      @id = params.fetch(:id) { rand(0xFFFF).to_s }
      @name = params.fetch(:name, '')
      @junk = params.fetch(:junk, 0)
    end

    def update_fields(data)
      @id = data[:id] if data.key?(:id)
      @name = data[:name] if data.key?(:name)
      @junk = data[:junk] if data.key?(:junk)
    end

    def repository
      People.repository
    end

    def to_h
      {
        id: @id,
        name: @name,
        junk: @junk
      }
    end
  end

  class Book
    include Moon::Record

    attr_accessor :id
    attr_accessor :name

    def self.repo_config
      {
        memory: false,
        filename: data_pathname('books.yml')
      }
    end

    def initialize(data)
      update_record(data)
    end

    def update_fields(data)
      @id = data.fetch(:id, @id || rand(0xFFFF).to_s)
      @name = data.fetch(:name, @name || '')
    end

    def to_h
      {
        id: @id,
        name: @name,
      }
    end
  end
end
