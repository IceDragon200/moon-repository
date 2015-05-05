require 'moon-repository/repository'

module Moon
  # define a #repository method on your target
  module Record
    class RecordNotFound < IndexError
    end

    module ClassMethods
      # @return [Hash<Symbol, Object>]
      def repo_config
        {
          memory: true,
        }
      end

      # @return [Class]
      def model
        self
      end

      def prepare_repository
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

      # @return [Repository]
      def repository
        @repository ||= begin
          prepare_repository
          create_repository
        end
      end

      # @param [Hash<Symbol, Object>] query
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

      def all
        where({})
      end

      def update_all(data, options = {})
        where(options).each do |record|
          record.update(data)
        end
      end

      def destroy_all(options = {})
        where(options).each do |record|
          record.destroy
        end
      end

      def delete_all(options = {})
        where(options).each do |record|
          repository.delete record.id
        end
      end

      def clear_all
        repository.clear
      end

      # @param [Hash<Symbol, Object>] data
      def create(data = {})
        record = model.new(data)
        repository.create record.id, record.to_h
        record.on_create
        record.on_save
        record
      end

      # @param [String] id
      def exists?(id)
        repository.exists?(id)
      end

      # @param [String] id
      # @return [Object, nil]
      def get(id)
        (data = repository.get(id)) && model.new(data)
      end

      # @param [Hash<Symbol, Object>] query
      # @return [Object, nil] an instance of the model
      def first(query)
        where(query).first
      end

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

      def find_by(query)
        first(query) ||
          (raise RecordNotFound, "no record found for query: #{query}")
      end
    end

    module InstanceMethods
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

      # Callback invoked when the model is created
      def on_create
      end

      def pre_update
      end

      # Callback invoked when the model is updated
      def on_update
      end

      def pre_save
      end

      # General callback when an update or creation takes place.
      def on_save
      end

      def pre_destroy
      end

      # Callback invoked when the model is destroyed
      def on_destroy
        @__destroyed = true
      end

      # @param [Hash<Symbol, Object>] data
      def update_record(data)
        update_fields data
      end

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

      # @return [self]
      def save
        pre_save
        repository.save(id, record_data) ? on_create : on_update
        on_save
        self
      end

      # @return [self]
      def destroy
        pre_destroy
        repository.delete(id)
        on_destroy
        self
      end

      def exists?
        repository.exists?(id)
      end

      def destroyed?
        @__destroyed
      end
    end

    include InstanceMethods

    def self.included(mod)
      mod.extend ClassMethods
    end
  end
end
