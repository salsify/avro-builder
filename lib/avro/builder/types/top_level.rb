module Avro
  module Builder
    module Types

      # This concern is used by types that can be defined at the top-level,
      # i.e. outside a field.
      module TopLevel

        def self.included(base)
          base.add_option_name :_name
        end

        # Provide a way to set the name internally for a top-level type.
        def _name=(value)
          @name = value
        end
        private :_name=

        # Namespace is settable as a top-level option
        attr_writer :namespace

        module TopLevelErrorHandling

          # Options disallowed for top-level types.

          def type_name=(_value)
            name_attribute_error!
          end

          def type_namespace=(_value)
            namespace_instead_of_type_namespace_error!
          end

          private

          def type_aliases=(_value)
            raise AttributeError
              .new("'aliases' must be used instead of 'type_aliases'")
          end
          alias_method :type_aliases, :type_aliases=

          def name_attribute_error!
            raise AttributeError
                    .new("name must be specified as the first argument for #{avro_type_name}")
          end
          alias_method :type_name_instead_of_name_error!, :name_attribute_error!
          private :type_name_instead_of_name_error!

          def namespace_attribute_error!
            raise AttributeError
                    .new("'namespace' must be specified as an option, not via a block")
          end
          alias_method :type_namespace_instead_of_namespace_error!, :namespace_attribute_error!
          private :type_namespace_instead_of_namespace_error!

          def namespace_instead_of_type_namespace_error!
            raise AttributeError
              .new("'namespace' must be specified as an option instead of 'type_namespace'")
          end
        end
        include TopLevelErrorHandling
      end

    end
  end
end
