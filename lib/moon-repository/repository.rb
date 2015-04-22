module Moon
  module Repo
    class << self
      attr_accessor :adapter
    end

    def self.setup(type)
      case type
      when :memory
        self.adapter = Moon::Repo::MemoryAdapter.new
      else
        fail
      end
    end

    # Define a #model method on your target.
    module RepositoryBase
      attr_writer :adapter

      def adapter
        @adapter || Repo.adapter
      end

      def assert_is_kind_of_model(record)
        unless record.is_a?(model)
          raise TypeError, "unexpected model #{record.class} (expected #{model})"
        end
      end

      def create(params = {})
        adapter.create model, params
      end

      def save(record)
        adapter.save model, record
      end

      def all
        adapter.all model
      end

      def find(id)
        adapter.find model, id
      end

      def find_by(query)
        adapter.find_by model, query
      end

      def update(record, params)
        assert_is_kind_of_model record
        adapter.update record, params
      end

      def destroy(record)
        assert_is_kind_of_model record
        adapter.destroy record
      end

      def destroy_all
        adapter.destroy_all model
      end

      def clear_all
        adapter.clear_all model
      end

      def exists?(id)
        adapter.exists?(model, id)
      end

      def count
        adapter.count(model)
      end
    end

    module Repository
      include RepositoryBase

      def model
        self
      end
    end
  end
end
