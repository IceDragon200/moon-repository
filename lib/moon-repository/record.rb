module Moon
  module Repo
    # define a #repository method on your target
    module RecordBase
      def update(*params)
        repository.update(self, *params)
      end

      def save
        update
      end

      def destroy
        repository.destroy(self)
      end

      def check_query(key, value)
        send(key) == value
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
