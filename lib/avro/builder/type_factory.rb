module Avro
  module Builder

    # This concern is used by classes that create new Type instances.
    module TypeFactory

      private

      # Return a new Type instance
      def create_type(type_name)
        case
        when Avro::Schema::PRIMITIVE_TYPES_SYM.include?(type_name.to_sym)
          Avro::Builder::Types::Type.new(type_name)
        else
          type_class_name = "#{type_name.to_s.capitalize}Type"
          Avro::Builder::Types.const_get(type_class_name).new
        end
      end

      # Return a new Type instance, including propagating internal state
      # and setting attributes via the DSL
      def build_type(type_name, field: nil, builder: nil, internal: {}, options: {}, &block)
        create_type(type_name).tap do |type|
          type.field = field
          type.builder = builder
          type.configure_options(internal.merge(options))
          type.instance_eval(&block) if block_given?
        end
      end

    end
  end
end
