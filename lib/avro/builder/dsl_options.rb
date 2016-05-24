module Avro
  module Builder

    # This module provides methods for defining options that can be
    # set via the DSL on various objects.
    #
    # These attributes can only be set as options, and not as method in
    # DSL block.
    #
    # The methods generated for DSL options are combined getter/setters
    # of the form:
    #
    #   option(value = nil)
    #
    # When a value is provided the option is set, and when it is nil the
    # current value is returned.
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
          if block_given?
            define_method(name, &block)
          else
            define_accessor(name)
          end
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

        def define_accessor(name)
          ivar = :"@#{name}"
          define_method(name) do |value = nil|
            value ? instance_variable_set(ivar, value) : instance_variable_get(ivar)
          end
        end
      end
    end
  end
end
