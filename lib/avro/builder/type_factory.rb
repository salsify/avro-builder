module Avro
  module Builder

    # This concern is used by classes that create new Type instances.
    module TypeFactory

      COMPLEX_TYPES = Set.new(%w(array enum fixed map record union).map(&:freeze)).freeze
      BUILTIN_TYPES = Avro::Schema::PRIMITIVE_TYPES.union(COMPLEX_TYPES).freeze

      private

      # Return a new Type instance
      def create_builtin_type(type_name)
        name = type_name.to_s.downcase
        case
        when Avro::Schema::PRIMITIVE_TYPES.include?(name)
          Avro::Builder::Types::Type.new(name)
        when COMPLEX_TYPES.include?(name)
          Avro::Builder::Types.const_get("#{name.capitalize}Type").new
        else
          raise "Invalid builtin type: #{type_name}"
        end
      end

      # Return a new Type instance, including propagating internal state
      # and setting attributes via the DSL
      def create_and_configure_builtin_type(type_name,
                                            field: nil,
                                            builder: nil,
                                            internal: {},
                                            options: {},
                                            &block)
        create_builtin_type(type_name).tap do |type|
          type.field = field
          type.builder = builder
          type.configure_options(internal.merge(options))
          type.instance_eval(&block) if block_given?
        end
      end

      def builtin_type?(type_name)
        BUILTIN_TYPES.include?(type_name.to_s)
      end
    end
  end
end
