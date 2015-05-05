require 'moon-repository/storage/base'

module Moon
  module Storage
    class YAMLStorage < Base
      # @!attribute filename
      #   @return [String]
      attr_accessor :filename

      def initialize(filename)
        super()
        @filename = filename
        load if File.exist?(@filename)
      end

      def load_unsafe
        d = YAML.load_file(@filename) || {}
        @data = Hash[d.map do |key, value|
          [key, value.symbolize_keys]
        end]
      end

      def save_unsafe
        File.write @filename, @data.to_yaml
      end
    end
  end
end
