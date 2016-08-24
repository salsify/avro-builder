module Avro
  module Builder
    module Types

      # This module provides common functionality for non-primitive types
      # that do not require a name to be created.
      module ComplexType

        def self.included(base)
          base.extend ClassMethods
        end

        # Override initialize so that type name is not required
        def initialize(cache:, field: nil)
          super(self.class.avro_type_name, cache: cache, field: field)
        end

        def namespace
          field.namespace
        end

        def serialize(_reference_state, overrides: {})
          {
            type: avro_type_name,
            logicalType: logical_type
          }.merge(overrides).reject { |_, v| v.nil? }
        end

        module ClassMethods

          # Infer avro_type_name based on class
          def avro_type_name
            @avro_type_name ||= name.split('::').last.sub('Type', '').downcase.to_sym
          end
        end
      end
    end
  end
end
