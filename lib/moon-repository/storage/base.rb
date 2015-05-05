module Moon
  module Storage
    class Base
      # @!attribute [r] data
      #   @return [Hash<String, Hash>]
      attr_reader :data

      def initialize
        @data = {}
        post_initialize
      end

      def post_initialize
      end

      def synchronize
        yield
      end

      def load_unsafe
        #
      end

      def load
        synchronize do
          load_unsafe
        end
      end

      def save_unsafe
        #
      end

      def save
        synchronize do
          save_unsafe
        end
      end

      def update_unsafe(new_data)
        @data = new_data
        save_unsafe
      end

      def update(new_data)
        synchronize do
          update_unsafe(new_data)
        end
      end

      def map(&block)
        synchronize do
          update_unsafe block.call(@data)
        end
      end

      def modify(&block)
        map do |data|
          block.call data
          data
        end
      end
    end
  end
end
