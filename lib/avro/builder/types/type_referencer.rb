require 'avro/builder/type_factory'

module Avro
  module Builder
    module Types

      # This concern is used by Types that reference other types.
      module TypeReferencer
        include Avro::Builder::TypeFactory

        def create_builtin_or_lookup_named_type(avro_type_or_name)
          if avro_type_or_name.is_a?(Avro::Builder::Types::Type)
            avro_type_or_name
          elsif builtin_type?(avro_type_or_name)
            create_builtin_type(avro_type_or_name, field: field, cache: cache)
          else
            cache.lookup_named_type(avro_type_or_name)
          end
        end
      end
    end
  end
end
