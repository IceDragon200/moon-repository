require 'moon-repository/storage/memory'
require 'moon-repository/storage/yaml'

module Moon
  class Repository
    class EntryExists < IndexError
    end

    class EntryMissing < IndexError
    end

    attr_reader :storage

    def initialize(config = {})
      if config[:memory]
        @storage = Storage::Memory.new
      else
        @storage = Storage::YAMLStorage.new(config.fetch(:filename))
      end
    end

    private def store(id, data)
      @storage.modify do |stored|
        stored[id] = data
      end
    end

    def exists?(id)
      @storage.data.key?(id)
    end

    private def ensure_no_entry(id)
      raise EntryExists, "entry #{id} exists" if exists?(id)
    end

    private def ensure_entry(id)
      raise EntryMissing, "entry #{id} does not exist" unless exists?(id)
    end

    def create(id, data)
      ensure_no_entry(id)
      store(id, data)
    end

    def touch(id, data = {})
      store(id, data) unless exists?(id)
    end

    def all
      @storage.data
    end

    def fetch(id)
      @storage.data.fetch(id)
    end

    def get(id)
      @storage.data[id]
    end

    def update(id, data)
      ensure_entry(id)
      store(id, data)
    end

    # @return [Boolean] true if record was created or false if it was updated
    def save(id, data)
      created = !exists?(id)
      store(id, data)
      created
    end

    def delete(id)
      ensure_entry(id)
      @storage.modify { |stored| stored.delete(id) }
    end

    def clear
      @storage.modify { |stored| stored.clear }
    end

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
