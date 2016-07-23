module Moon
  # Data storing classes
  # Storage classes define a basic interface for encoding/decoding a data
  # Hash, to some storage format.
  module Storage
    # Generic storage error
    class StorageError < StandardError
    end

    # Raised when a record cannot be found
    class RecordNotFound < StorageError
    end

    # Raised when a record with the same id already exists
    class RecordExists < StorageError
    end

    # Base class for other Storage classes
    class Base
      # Hash storing all data in memory
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
      protected def post_initialize
      end

      # Mutex shim, overwrite this method with a locking mechanism
      #
      # @yieldparam [self] self
      # @return [void]
      protected def synchronize
        yield self
      end

      # Unsynchronized loading method, use this to access the file system or
      # other IO operations for loading data, you must set the `@data` instance
      # variable in this method.
      #
      # @return [void]
      # @abstract
      # @api
      protected def load_unsafe
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
      protected def save_unsafe
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
      protected def replace_unsafe(new_data)
        @data = new_data
        save_unsafe
      end

      # Synchronized update, replaces the current data and {#save}s
      #
      # @param [Hash] new_data
      # @return [void]
      def replace(new_data)
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
          replace_unsafe block.call(@data)
        end
      end

      # Synchronized, yields the current data for modification, saves the
      # same data.
      # Use this method if you only wish to make changes to the internal
      # data and do not need to replace it.
      #
      # @yieldparam [Hash] data
      # @return [void]
      private def modify(&block)
        map do |data|
          block.call data
          data
        end
      end

      # Retrieves data by id
      #
      # @param [String] id
      # @return [Hash] row
      def get(id)
        @data[id]
      end

      # Inserts a new record into storage
      #
      # @param [String] id
      # @param [Hash] data
      def insert(id, row)
        modify do |data|
          raise RecordExists, "record `#{id}` already exists" if data.key?(id)
          data[id] = row
        end
      end

      # Removes an existing record in storage
      #
      # @param [String] id
      # @param [Hash] id
      def delete(id)
        modify do |data|
          raise RecordNotFound, "record `#{id}` does not exist" unless data.key?(id)
          data.delete(id)
        end
      end

      # Removes an existing record in storage
      #
      # @param [String] id
      # @param [Hash] id
      def update(id, row)
        modify do |data|
          raise RecordNotFound, "record `#{id}` does not exist" unless data.key?(id)
          data[id] = row
        end
      end

      # Clears all data in Storage
      def clear
        modify do |data|
          data.clear
        end
      end

      # Determines if a record by the given id exists?
      #
      # @param [String] id
      # @return [Boolean] true the record exists, false otherwise
      def exists?(id)
        @data.key?(id)
      end
    end
  end
end
