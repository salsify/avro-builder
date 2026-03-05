# frozen_string_literal: true

module Avro
  module Builder
    module Types
      # Subclass for the primitive Bytes type because it supports the decimal logical type.
      class BytesType < Type
        dsl_attributes :precision, :scale

        def initialize(cache:, field: nil)
          super('bytes', field: field, cache: cache)
        end

        private

        def serialized_attribute_hash(reference_state)
          super.merge(precision: precision, scale: scale)
        end
      end
    end
  end
end
