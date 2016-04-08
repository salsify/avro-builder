module Avro
  module Builder

    # This concern is used by classes that create new Type instances.
    module TypeFactory

      SPECIFIC_TYPES = Set.new(%w(Array Enum Fixed Map Record Union).map(&:freeze)).freeze

      private

      # Return a new Type instance or nil
      def create_type(type_name)
        case
        when Avro::Schema::PRIMITIVE_TYPES_SYM.include?(type_name.to_sym)
          Avro::Builder::Types::Type.new(type_name)
        else
          type_class_name = "#{type_name.to_s.capitalize}"
          if SPECIFIC_TYPES.include?(type_class_name)
            Avro::Builder::Types.const_get("#{type_class_name}Type").new
          end
        end
      end

      # Return a new Type instance, including propagating internal state
      # and setting attributes via the DSL
      def build_type(type_name, field: nil, builder: nil, internal: {}, options: {}, &block)
        new_type = create_type(type_name)
        new_type.tap do |type|
          type.field = field
          type.builder = builder
          type.configure_options(internal.merge(options))
          type.instance_eval(&block) if block_given?
        end if new_type
      end

    end
  end
end
