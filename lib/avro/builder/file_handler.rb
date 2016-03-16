module Avro
  module Builder
    # TODO: eventually this should be refactored into something standalone
    # instead of a module that is included to provide the file handling methods.
    module FileHandler

      module ClassMethods
        # Load paths are used to search for imports and extends.
        def load_paths
          @load_paths ||= Set.new
        end
      end

      def self.included(base)
        base.extend ClassMethods
      end

      def read_file(name)
        File.read(find_file(name))
      end

      private

      def find_file(name)
        file_name = "#{name.to_s.sub(/\.rb$/, '')}.rb"
        matches = self.class.load_paths.flat_map do |load_path|
          Dir["#{load_path}/**/*.rb"].select do |file_path|
            file_path.end_with?(file_name)
          end
        end
        raise "Multiple matches: #{matches}" if matches.size > 1
        raise "File not found #{name}" if matches.empty?

        matches.first
      end

    end
  end
end
