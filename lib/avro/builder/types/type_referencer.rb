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

        def find_or_create_type(type_name)
          builder.lookup(type_name, required: false) || create_type(type_name)
        end
      end
    end
  end
end
