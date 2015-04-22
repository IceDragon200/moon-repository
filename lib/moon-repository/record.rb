module Moon
  module Repo
    # define a #repository method on your target
    module RecordBase
      # Callback invoked when the model is created
      def on_create
      end

      # Callback invoked when the model is updated
      def on_update
      end

      # Callback invoked when the model is destroyed
      def on_destroy
      end

      def update(params = {})
        repository.update self, params
      end

      def save
        repository.save self
      end

      def destroy
        repository.destroy self
      end

      # @param [Symbol] key
      # @param [Object] value
      def check_query(key, value)
        send(key) == value
      end

      def exists?
        repository.exists?(self.id)
      end
    end

    module Record
      include RecordBase

      def repository
        self.class
      end
    end
  end
end
