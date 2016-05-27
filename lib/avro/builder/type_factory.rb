module Avro
  module Builder

    # This concern is used by classes that create new Type instances.
    module TypeFactory

      NAMED_TYPES = %w(enum fixed record).map(&:freeze).to_set.freeze
      COMPLEX_TYPES = %w(array enum fixed map record union).map(&:freeze).to_set.freeze
      BUILTIN_TYPES = Avro::Schema::PRIMITIVE_TYPES.union(COMPLEX_TYPES).freeze

      private

      # Return a new Type instance
      def create_builtin_type(avro_type_name, field:, cache:)
        name = avro_type_name.to_s.downcase
        if Avro::Schema::PRIMITIVE_TYPES.include?(name)
          Avro::Builder::Types::Type.new(name, field: field, cache: cache)
        elsif field.nil? && NAMED_TYPES.include?(name)
          Avro::Builder.const_get(name.capitalize).new(cache: cache)
        elsif COMPLEX_TYPES.include?(name)
          Avro::Builder::Types.const_get("#{name.capitalize}Type").new(field: field, cache: cache)
        else
          raise "Invalid builtin type: #{avro_type_name}"
        end
      end

      # Return a new Type instance, including propagating internal state
      # and setting attributes via the DSL
      def create_and_configure_builtin_type(avro_type_name,
                                            field: nil,
                                            cache: nil,
                                            internal: {},
                                            options: {},
                                            &block)
        create_builtin_type(avro_type_name, field: field, cache: cache).tap do |type|
          type.configure_options(internal.merge(options))
          type.cache!
          type.instance_eval(&block) if block_given?
        end
      end

      def builtin_type?(avro_type_name)
        BUILTIN_TYPES.include?(avro_type_name.to_s)
      end
    end
  end
end
