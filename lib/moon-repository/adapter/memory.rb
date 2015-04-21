module Moon
  module Repo
    class PartialCollection
      include Enumerable

      def initialize(data)
        data
      end

      def [](id)
        data[id]
      end

      def each
        return to_enum :each unless block_given?
        data.each do |_, value|
          yield value
        end
      end
    end

    class QueryMachine
    end

    class MemoryAdapter
      def initialize
        @store = {}
        @partials = {}
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

      def create(klass, params)
        store_for(klass)[]
      end

      def update(record, params)
        store_for_class(record)
      end

      def destroy(record)
        store_for_class(record).delete(record.id)
      end

      private
      def partial_for(klass)
        @partials[klass] ||= PartialCollection.new(store_for(klass))
      end

      def store_for(klass)
        @store[klass] ||= {}
      end

      def store_for_class(instance)
        store_for(instance.class)
      end
    end
  end
end
