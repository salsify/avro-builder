# frozen_string_literal: true

module Avro
  module Builder
    module Types

      # This concern provides error handling for attributes related to naming
      # that are handled differently at the top-level vs inline.
      module NamedErrorHandling

        # Errors for attributes specified via block

        def type_name(_value)
          name_attribute_error!
        end

        def type_namespace(_value)
          namespace_attribute_error!
        end

        private

        # Errors for misnamed options

        def name=(_value)
          type_name_instead_of_name_error!
        end

        def namespace=(_value)
          type_namespace_instead_of_namespace_error!
        end

        # Methods to raise errors

        def specify_as_type_option_error!(name)
          raise AttributeError
            .new("'type_#{name}' must be specified as an option, not via a block")
        end

        def name_attribute_error!
          specify_as_type_option_error!(:name)
        end

        def namespace_attribute_error!
          specify_as_type_option_error!(:namespace)
        end

        def type_option_instead_of_option_error!(name)
          raise AttributeError
            .new("'type_#{name}' must be specified as an option instead of '#{name}'")
        end

        def type_name_instead_of_name_error!
          type_option_instead_of_option_error!(:name)
        end

        def type_namespace_instead_of_namespace_error!
          type_option_instead_of_option_error!(:namespace)
        end

      end
    end
  end
end
