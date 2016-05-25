require 'avro/builder/type_factory'

module Avro
  module Builder
    module Types

      # This concern is used by Types that reference other types.
      module TypeReferencer
        include Avro::Builder::TypeFactory

        def create_builtin_or_lookup_named_type(avro_type_name)
          if builtin_type?(avro_type_name)
            create_builtin_type(avro_type_name, field: field, cache: cache)
          else
            cache.lookup_named_type(avro_type_name)
          end
        end
      end
    end
  end
end
