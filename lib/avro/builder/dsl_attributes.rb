module Avro
  module Builder

    # This module provides methods for defining attributes that can be
    # set via the DSL on various objects.
    #
    # The methods generated for DSL attributes are combined getter/setters
    # of the form:
    #
    #   attribute(value = nil)
    #
    # When a value is provided the attribute is set, and when it is nil the
    # current value is returned.
    #
    # When a DSL attribute is defined, the class also keeps track of the
    # attribute names.
    module DslAttributes
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # If a block is specified then it is used to define the
        # combined getter/setter method for the DSL attribute.
        def dsl_attribute(name, &block)
          if block_given?
            add_attribute_name(name)
            define_method(name, &block)
            alias_writer(name)
          else
            dsl_attributes(name)
          end
        end

        def dsl_attributes(*names)
          raise 'a block can only be specified with dsl_attribute' if block_given?

          names.each do |name|
            add_attribute_name(name)
            define_accessor(name)
          end
        end

        def dsl_attribute_alias(new_name, old_name)
          alias_method(new_name, old_name)
          alias_writer(new_name)
          add_attribute_name(new_name)
        end

        def dsl_attribute_names
          @dsl_attribute_names ||=
            if superclass.respond_to?(:dsl_attribute_names)
              superclass.dsl_attribute_names.dup
            else
              Set.new
            end
        end

        def add_attribute_name(name)
          dsl_attribute_names << name
          add_option_name(name)
        end

        private

        def define_accessor(name)
          ivar = :"@#{name}"
          define_method(name) do |value = nil|
            value.nil? ? instance_variable_get(ivar) : instance_variable_set(ivar, value)
          end
          alias_writer(name)
        end

        # The writer (name=) method is used to set attributes via options.
        def alias_writer(name)
          writer = "#{name}="
          alias_method(writer, name)
          private(writer)
        end
      end

      def dsl_attribute?(name)
        self.class.dsl_attribute_names.include?(name.to_sym)
      end
    end
  end
end
