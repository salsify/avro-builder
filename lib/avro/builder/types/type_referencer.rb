require 'avro/builder/type_factory'

module Avro
  module Builder
    module Types

      # This concern is used by Types that reference other types.
      module TypeReferencer
        include Avro::Builder::TypeFactory

        def create_builtin_or_lookup_named_type(avro_type_or_name)
          type_dispatch(avro_type_or_name) do |avro_type_name|
            create_builtin_type(avro_type_name, field: field, cache: cache)
          end
        end
      end
    end
  end
end
