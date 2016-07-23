require 'moon-repository/storage/memory'
require 'moon-repository/storage/yaml'

# Moon main module
module Moon
  # Class for mediating between a {Storage} object and a {Record}
  class Repository
    # Error raised when a data entry already exists
    class EntryExists < IndexError
    end

    # Error raised when a data entry does not exist
    class EntryMissing < IndexError
    end

    # Storage object implementation
    # @!attribute [r] storage
    #   @return [Storage::Base<>] {Storage} instance
    attr_reader :storage

    # @param [Storage::Base<>] storage  a Storage object
    def initialize(storage)
      @storage = storage
    end

    # Checks if an entry exists with the given id
    #
    # @param [String] id
    # @return [Boolean]
    def exists?(id)
      @storage.exists?(id)
    end

    # Checks if an entry exists with the given id, raises an error if it does.
    #
    # @param [String] id
    # @raise [EntryExists]
    private def ensure_no_entry(id)
      raise EntryExists, "entry #{id} exists" if exists?(id)
    end

    # Checks if an entry exists with the given id, raises an error if it doesnt.
    #
    # @param [String] id
    # @raise [EntryMissing]
    private def ensure_entry(id)
      raise EntryMissing, "entry #{id} does not exist" unless exists?(id)
    end

    # Creates an entry, if it already exists, it will raise a {EntryExists}
    # error
    #
    # @param [String] id
    # @param [Hash] data
    # @return [void]
    # @raise EntryExists
    def create(id, data)
      ensure_no_entry(id)
      @storage.insert(id, data)
    end

    # Creates an entry if it doesn't already exists
    #
    # @return [void]
    def touch(id, data = {})
      if exists?(id)
        @storage.update(id, data)
      else
        @storage.insert(id, data)
      end
    end

    # Returns all the entries in the repository,
    # @note This is a reference to the {Storage::Base#data}
    #       so don't do anything stupid.
    #
    # @return [Hash<String, Hash>]
    def all
      @storage.data
    end

    # Returns a entry for the given id, raises a IndexError if the entry
    # doesn't exist.
    #
    # @param [String] id
    # @return [Hash]
    # @raise IndexError
    def fetch(id)
      @storage.data.fetch(id)
    end

    # Returns a entry for the given id
    #
    # @param [String] id
    # @return [Hash]
    def get(id)
      @storage.get(id)
    end

    # Updates an entry, if it doesnt exist, it will raise a {EntryMissing}
    # error
    #
    # @param [String] id
    # @param [Hash] data
    # @return [void]
    # @raise EntryMissing
    def update(id, data)
      ensure_entry(id)
      @storage.update(id, data)
    end

    # Saves an entry.
    #
    # @param [String] id
    # @param [Hash] data
    # @return [Boolean] true if entry was created or false if it was updated
    def save(id, data)
      created = !exists?(id)
      touch(id, data)
      created
    end

    # Removes an entry, raises a {EntryMissing} error, if the entry didn't exist.
    #
    # @param [String] id
    # @return [void]
    # @raise EntryMissing
    def delete(id)
      ensure_entry(id)
      @storage.delete(id)
    end

    # Clears all entries
    #
    # @return [void]
    def clear
      @storage.clear
    end

    # Creates a Enumerator which yields all entries which return true for
    # the given `block`.
    #
    # @yieldparam [Hash] entry
    # @return [Enumerator]
    def query(&block)
      data = @storage.data.dup
      Enumerator.new do |yielder|
        data.each_value do |entry|
          yielder.yield entry if block.call(entry)
        end
      end
    end
  end
end
