require 'avro/builder/type_factory'

module Avro
  module Builder
    module Types

      # This concern is used by Types that reference other types.
      module TypeReferencer
        include Avro::Builder::TypeFactory

        def builder
          (!field.nil? && field.builder) || super
        end

        def create_builtin_or_lookup_named_type(type_name)
          if builtin_type?(type_name)
            create_builtin_type(type_name)
          else
            builder.lookup_named_type(type_name)
          end
        end
      end
    end
  end
end
