require 'moon-repository/repository'

module Moon
  # Public facing api for users
  module Record
    # Error raised when a record could not be found.
    class RecordNotFound < IndexError
    end

    # Class extensions, this defines queries and creation methods
    module ClassMethods
      # Repository configuration, only 2 options are supported at the moment,
      # if the `:memory` is set to true, it will create a {Storage::Memory},
      # for the repository, else a {Storage::YAMLStorage} is created instead.
      #
      # @return [Hash<Symbol, Object>] options
      # @option options [Boolean] :memory  use an in memory storage?
      # @option options [String] :filename  name for the YAMLStorage
      def repo_config
        {
          memory: true,
        }
      end

      # Record class for instances
      #
      # @return [Class]
      def model
        self
      end

      # Called before creating the repository, use this method to
      # create directories or preparations for the repo.
      #
      # @return [void]
      private def prepare_repository
        #
      end

      # Creates a {Storage} object for the {Repository}
      # @return [Storage::Base<>]
      # @api
      private def create_storage
        config = repo_config
        if config[:memory]
          Storage::Memory.new
        else
          Storage::YAMLStorage.new(config.fetch(:filename))
        end
      end

      # Creates an instance of {Repository} to use for the Record
      #
      # @return [Repository]
      # @api
      private def create_repository
        Repository.new(create_storage)
      end

      # A Repository instance for storing records
      #
      # @return [Repository]
      def repository
        @repository ||= begin
          prepare_repository
          create_repository
        end
      end

      # Creates a query Enumerator which yields all records which match
      # the given query, the query is a key value pair compared using `==`
      #
      # @param [Hash<Symbol, Object>] query
      # @return [Enumerator]
      def where(query)
        Enumerator.new do |yielder|
          repository.query do |data|
            query.all? do |key, value|
              data[key] == value
            end
          end.each do |data|
            yielder.yield model.new(data)
          end
        end
      end

      # Returns an enumerator for iterating all records.
      #
      # @return [Enumerator]
      def all
        where({})
      end

      # Updates records which match the given query, if query is empty
      # it will update all records.
      #
      # @param [Hash<Symbol, Object>] data
      # @param [Hash<Symbol, Object>] query
      def update_all(data, query = {})
        where(query).each do |record|
          record.update(data)
        end
      end

      # Destroys records which match the query, if query is empty, it
      # will destroy all records.
      #
      # @param [Hash<Symbol, Object>] query
      def destroy_all(query = {})
        where(query).each do |record|
          record.destroy
        end
      end

      # Deletes records which match the query, if `query` is empty, it will
      # delete all records, similar to {#clear_all}
      #
      # @param [Hash<Symbol, Object>] query
      def delete_all(query = {})
        where(query).each do |record|
          repository.delete record.id
        end
      end

      # Clears all records, this does not call destroy or delete, it simply
      # deletes all the records from the repository
      #
      # @return [void]
      def clear_all
        repository.clear
      end

      # Creates a new record from the given data
      #
      # @param [Hash<Symbol, Object>] data
      # @return [Object] the newly created record
      def create(data = {})
        record = model.new(data)
        repository.create record.id, record.to_h
        record.on_create
        record.on_save
        record
      end

      # Checks if a record exists with the given id
      #
      # @param [String] id
      # @return [Boolean] true if the record exists, false otherwise
      def exists?(id)
        repository.exists?(id)
      end

      # Gets and creates a model from the data gotten for the id,
      # if no entry was found, it will return nil.
      #
      # @param [String] id
      # @return [Object, nil]
      def get(id)
        (data = repository.get(id)) && model.new(data)
      end

      # Returns the first record which matches the given query
      #
      # @param [Hash<Symbol, Object>] query
      # @return [Object, nil] an instance of the model
      def first(query)
        where(query).first
      end

      # Counts records which matches the given query, if the query
      # is empty, counts all records instead.
      #
      # @param [Hash<Symbol, Object>] query
      def count(query = {})
        where(query).count
      end

      # Locates and returns a record by ID, if the record doesn't exist,
      # this will raise an {Repository::EntryMissing} error
      #
      # @param [String] id
      # @return [Object]
      def find(id)
        model.new(repository.fetch(id))
      end

      # Locates and returns the first record matching the query, if not
      # record is found, raises a {RecordNotFound} error
      #
      # @param [Hash<Symbol, Object>] query
      # @raise RecordNotFound
      def find_by(query)
        first(query) ||
          (raise RecordNotFound, "no record found for query: #{query}")
      end
    end

    # Instance methods for interacting with Record instance objects,
    # all Records must implement an `#id` attribute, and a `#to_h` methid,
    # which will be used by the repository to store its data.
    # The `#to_h` method must return a `Hash<Symbol, Object>` hash.
    module InstanceMethods
      # The repository that corresponds with this model
      #
      # @return [Repository] The repository instance
      def repository
        self.class.repository
      end

      # Data that is exported to the adapter
      #
      # @return [Hash]
      def record_data
        # simply defaults to converting the object to a Hash
        # this is done, since DataModel exports PiROs (Primitive Ruby Objects).
        to_h
      end

      # Callback invoked when the record is created in the repository
      #
      # @return [void]
      # @abstract
      def on_create
      end

      # Callback invoked before a record is updated in the repository
      # see {#on_update}, {#update}
      #
      # @return [void]
      # @abstract
      def pre_update
      end

      # Callback invoked after the record is updated in the repository
      # see {#pre_update}, {#update}
      #
      # @return [void]
      # @abstract
      def on_update
      end

      # Callback invoked after the record is updated or created in the repository.
      # see {#on_save}, {#save}, {ClassMethods#create}, {#update}
      #
      # @return [void]
      # @abstract
      def pre_save
      end

      # Callback invoked after the record is updated or created in the repository
      # see {#pre_save}, {#save}, {ClassMethods#create}, {#update}
      #
      # @return [void]
      # @abstract
      def on_save
      end

      # Callback invoked before the record is destroyed in the repository
      #
      # @return [void]
      # @abstract
      def pre_destroy
      end

      # Callback invoked after the record is destroyed in the repository
      #
      # @return [void]
      # @abstract
      def on_destroy
        @__destroyed = true
      end

      # Updates the record's attributes/fields
      #
      # @param [Hash<Symbol, Object>] data
      # @return [void]
      def update_record(data)
        update_fields data
      end

      # Updates the current record and invokes callbacks
      #
      # see {#pre_update}, {#on_update}
      # @param [Hash<Symbol, Object>] data
      # @return [self]
      def update(data)
        update_record data
        pre_update
        repository.update(id, record_data)
        on_update
        on_save
        self
      end

      # Saves the current record and invokes callbacks
      #
      # see {#pre_save}, {#on_save}
      # @return [self]
      def save
        pre_save
        repository.save(id, record_data) ? on_create : on_update
        on_save
        self
      end

      # Destroys the current record and invokes callbacks
      #
      # see {#pre_destroy}, {#on_destroy}
      # @return [self]
      def destroy
        pre_destroy
        repository.delete(id)
        on_destroy
        self
      end

      # Reports if the record exists in the repository
      #
      # @return [Boolean] true if the record exists in the repository,
      #                   false otherwise
      def exists?
        repository.exists?(id)
      end

      # Reports if the model has been destroyed,
      # @note, if this model existed before and another model was gotten
      #        for its underlying data, it will report a false value
      #
      # @return [Boolean]
      def destroyed?
        @__destroyed
      end
    end

    include InstanceMethods

    # @param [Module] mod
    # @api private
    def self.included(mod)
      mod.extend ClassMethods
    end
  end
end
