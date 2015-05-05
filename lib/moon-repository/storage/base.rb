module Moon
  # Data storing classes
  # Storage classes define a basic interface for encoding/decoding a data
  # Hash, to some storage format.
  module Storage
    # Base class for other Storage classes
    class Base
      # @!attribute [r] data
      #   @return [Hash<String, Hash>]
      attr_reader :data

      def initialize
        @data = {}
        post_initialize
      end

      # Post initialization
      # Use this method to initialize your inherited storage class
      #
      # @return [void]
      def post_initialize
      end

      # Mutex shim, overwrite this method with a locking mechanism
      #
      # @yieldparam [self] self
      # @return [void]
      def synchronize
        yield self
      end

      # Unsynchronized loading method, use this to access the file system or
      # other IO operations for loading data, you must set the `@data` instance
      # variable in this method.
      #
      # @return [void]
      # @abstract
      # @api
      def load_unsafe
        #
      end

      # Synchornized loading method, this is the public api method for loading
      # the storage's data.
      #
      # @return [void]
      def load
        synchronize do
          load_unsafe
        end
      end

      # Unsynchronized saving method, use this to access the file system or
      # other IO operations for saving the data.
      #
      # @return [void]
      # @abstract
      # @api
      def save_unsafe
        #
      end

      # Syncrhonized saving method, this is the public api method for saving
      # the current data.
      #
      # @return [void]
      def save
        synchronize do
          save_unsafe
        end
      end

      # Unsynchronized update, replaces the current data and {#save}s
      #
      # @param [Hash] new_data
      # @return [void]
      def update_unsafe(new_data)
        @data = new_data
        save_unsafe
      end

      # Synchronized update, replaces the current data and {#save}s
      #
      # @param [Hash] new_data
      # @return [void]
      def update(new_data)
        synchronize do
          update_unsafe(new_data)
        end
      end

      # Synchronized map, replaces the current data with the result
      # from the block and {#save}s
      #
      # @yieldparam [Hash] data
      # @return [void]
      def map(&block)
        synchronize do
          update_unsafe block.call(@data)
        end
      end

      # Synchronized, yields the current data for modification, saves the
      # same data.
      # Use this method if you only wish to make changes to the internal
      # data and do not need to replace it.
      #
      # @yieldparam [Hash] data
      # @return [void]
      def modify(&block)
        map do |data|
          block.call data
          data
        end
      end
    end
  end
end
