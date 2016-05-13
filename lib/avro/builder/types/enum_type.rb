module Avro
  module Builder
    module Types
      class EnumType < NamedType

        dsl_attribute :doc

        dsl_attribute :symbols do |*values|
          # Define symbols explicitly to support values as a splat or single array
          if !values.empty?
            @symbols = values.flatten
          else
            @symbols
          end
        end

        def serialize(reference_state)
          super(reference_state, overrides: serialized_attributes)
        end

        def to_h(reference_state)
          super(reference_state, overrides: serialized_attributes)
        end

        def validate!
          super
          missing!(:symbols)
        end

        private

        def serialized_attributes
          { symbols: symbols, doc: doc }
        end
      end
    end
  end
end
