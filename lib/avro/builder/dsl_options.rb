module Avro
  module Builder

    # This module provides methods for defining options that can be
    # set via the DSL on various objects.
    #
    # These attributes can only be set as options via the private
    # #attribute= methods, and not as methods in DSL block.
    #
    # When a DSL option is defined, the class also keeps track of the
    # option names.
    module DslOptions
      def self.included(base)
        base.extend ClassMethods
      end

      def dsl_option?(name)
        self.class.dsl_option_names.include?(name.to_sym)
      end

      module ClassMethods
        # A DSL option is only settable as an option, not as method in a block.
        def dsl_option(name, &block)
          add_option_name(name)
          define_private_writer(name)
          define_reader(name, &block)
        end

        def dsl_option_names
          @dsl_option_names ||=
            if superclass.respond_to?(:dsl_option_names)
              superclass.dsl_option_names.dup
            else
              Set.new
            end
        end

        private

        def add_option_name(name)
          dsl_option_names << name
        end

        def define_private_writer(name)
          attr_writer(name)
          private("#{name}=")
        end

        # Define a accessor method that raises an error if called as a writer.
        # If the optional block is specified then it is evaluated as the reader.
        def define_reader(name, &block)
          if block_given?
            define_method(name) do |value = nil|
              value ? unsupported_block_attribute(name, avro_type_name) : instance_eval(&block)
            end
          else
            define_method(name) do |value = nil|
              value ? unsupported_block_attribute(name, avro_type_name) : instance_variable_get("@#{name}")
            end
          end
        end
      end

      private

      def unsupported_block_attribute(attribute, type)
        raise UnsupportedBlockAttributeError.new(attribute: attribute,
                                                 type: type)
      end
    end
  end
end
