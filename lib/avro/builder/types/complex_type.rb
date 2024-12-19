# frozen_string_literal: true

module Avro
  module Builder
    module Types

      # This is an abstract class that provides common functionality for
      # non-primitive types that do not require a name to be created.
      class ComplexType < Type

        # Infer avro_type_name based on class
        def self.avro_type_name
          @avro_type_name ||= name.split('::').last.sub('Type', '').downcase.to_sym
        end

        # Override initialize so that type name is not required
        def initialize(cache:, field: nil)
          super(self.class.avro_type_name, cache: cache, field: field)
        end

        def namespace
          field.namespace
        end
      end
    end
  end
end
