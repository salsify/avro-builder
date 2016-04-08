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
        def initialize
        end

        def type_name
          self.class.type_name
        end

        module ClassMethods

          # Infer type_name based on class
          def type_name
            @type_name ||= name.split('::').last.sub('Type', '').downcase.to_sym
          end
        end
      end
    end
  end
end
