module Moon
  module Repo
    # Define a #model method on your target.
    module RepositoryBase
      attr_accessor :adapter

      def create(*params)
        @adapter.create model, params
      end

      def all
        @adapter.all model
      end

      def find(*params)
        @adapter.find model, params
      end

      def update(record, *params)
        @adapter.update record, params
      end

      def destroy(record)
        @adapter.destroy record
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
