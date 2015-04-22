module Moon
  module Repo
    class ReadOnlyCollection
      include Enumerable

      def initialize(data)
        @data = data
      end

      def size
        @data.size
      end

      def [](id)
        @data[id]
      end

      def each(&block)
        @data.each(&block)
      end
    end

    class MemoryCollection
      include Enumerable

      def initialize(klass)
        @klass = klass
        @data = {}
        @id = 1
      end

      def exists?(id)
        @data.key?(id)
      end

      def size
        @data.size
      end

      def [](key)
        @data[key]
      end

      def fetch(key)
        @data.fetch(key)
      end

      def []=(key, value)
        @data[key] = value
      end

      def clear
        @data.clear
      end

      def swap
        old = @data
        @data = {}
        old
      end

      def next_id
        @id += 1
      end

      def save(record)
        unless record.id
          record.id = next_id
        end
        self[record.id] = record
      end

      def create(params = {})
        save(@klass.new({id: next_id}.merge(params)))
      end

      def update(id, params)
        record = self[id]
        return nil unless record
        params.each do |key, value|
          record.send("#{key}=", value)
        end
        record
      end

      def delete(id)
        @data.delete(id)
      end

      def each
        return to_enum :each unless block_given?
        @data.each do |_, value|
          yield value
        end
      end
    end

    class MemoryAdapter
      def initialize
        @store = {}
        @partials = {}
      end

      def on_create(record)
        return unless record
        record.on_create
      end

      def on_save(record)
        return unless record
        record.on_save
      end

      def on_update(record)
        return unless record
        record.on_update
      end

      def on_destroy(record)
        return unless record
        record.on_destroy
      end

      def count(model)
        store_for(model).size
      end

      def exists?(model, id)
        store_for(model).exists?(id)
      end

      def all(klass)
        partial_for(klass)
      end

      def find(klass, id)
        store_for(klass).find { |obj| obj.id == id }
      end

      def find_by(klass, query)
        store_for(klass).find do |obj|
          query.all? { |key, value| obj.check_query(key, value) }
        end
      end

      def create(klass, params = {})
        record = store_for(klass).create(params)
        on_create record
        record
      end

      def save(klass, record)
        storage = store_for(klass)
        if storage.exists?(record.id)
          # do regular saving stuff
        else
          storage.save(record)
        end
      end

      def update(record, params)
        record = store_for_class(record).update(record.id, params)
        on_update record
        record
      end

      def destroy(record)
        result = store_for_class(record).delete(record.id)
        on_destroy result
        result
      end

      def destroy_all(klass)
        store_for(klass).swap do |_, record|
          on_destroy record
        end
      end

      def clear_all(model)
        store_for(model).clear
      end

      private
      def store_for(klass)
        @store[klass] ||= MemoryCollection.new(klass)
      end

      def store_for_class(instance)
        store_for(instance.class)
      end

      def partial_for(klass)
        @partials[klass] ||= ReadOnlyCollection.new(store_for(klass))
      end
    end
  end
end
