module Avro
  module Builder

    # This module provides methods for defining attributes that can be
    # set  via the DSL on various objects.
    #
    # The methods generated for DSL attributes are combined getter/setters
    # of the form:
    #
    #   attribute(value = nil)
    #
    # When value is provided the attribute is set, and when it is nil the
    # current value is returned.
    #
    # When a DSL attribute is defined, the class also keeps track of the
    # attribute names.
    module DslAttributes
      def self.included(base)
        base.extend ClassMethods
        base.delegate :dsl_attribute_names, to: :class
      end

      module ClassMethods
        def dsl_attributes(*names)
          names.each do |name|
            dsl_attribute_names << name
            ivar = :"@#{name}"
            define_method(name) do |value = nil|
              value ? instance_variable_set(ivar, value) : instance_variable_get(ivar)
            end
          end
        end

        # If a block is specified then it is used to define the
        # combined getter/setter method for the DSL attribute.
        def dsl_attribute(name, &block)
          if block_given?
            dsl_attribute_names << name
            define_method(name, &block)
          else
            dsl_attributes(name)
          end
        end

        def dsl_attribute_names
          @dsl_attribute_names ||=
            if superclass.respond_to?(:dsl_attribute_names)
              superclass.dsl_attribute_names.dup
            else
              Set.new
            end
        end
      end
    end
  end
end
