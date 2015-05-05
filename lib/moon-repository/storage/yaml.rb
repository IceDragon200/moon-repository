require 'moon-repository/storage/base'

module Moon
  module Storage
    # Storage class for encoding/decoding data as YAML.
    class YAMLStorage < Base
      # @!attribute filename
      #   @return [String]
      attr_accessor :filename

      # @param [String] filename  file to save/load
      def initialize(filename)
        super()
        @filename = filename
        load if File.exist?(@filename)
      end

      # Loads data from file
      #
      # @return [void]
      # @api
      def load_unsafe
        d = YAML.load_file(@filename) || {}
        @data = Hash[d.map do |key, value|
          [key, value.symbolize_keys]
        end]
      end

      # Writes the current data to file
      #
      # @return [void]
      # @api
      def save_unsafe
        File.write @filename, @data.to_yaml
      end
    end
  end
end
