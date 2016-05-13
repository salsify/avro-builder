module Avro
  module Builder
    module Types
      class FixedType < NamedType

        dsl_attribute :size

        def serialize(reference_state)
          super(reference_state, overrides: serialized_attributes)
        end

        def to_h(reference_state)
          super(reference_state, overrides: serialized_attributes)
        end

        def validate!
          super
          missing!(:size)
        end

        private

        def serialized_attributes
          { size: size }
        end
      end
    end
  end
end
