# frozen_string_literal: true

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
        self.class.dsl_option?(name)
      end

      module ClassMethods

        # Defines a private writer with #{dsl_name}= to set an attribute stored in the
        # instance variable @#{name}.
        def dsl_option(name, dsl_name:)
          add_option_name(name)
          add_attribute_name(dsl_name)
          aliased_writer = "#{dsl_name}="
          define_method(aliased_writer) do |value|
            instance_variable_set("@#{name}", value)
          end
          private(aliased_writer)
        end

        def dsl_option?(name)
          if own_dsl_option_names.include?(name.to_sym)
            true
          elsif superclass.respond_to?(:dsl_option?)
            superclass.dsl_option?(name)
          else
            false
          end
        end

        def add_option_name(name)
          own_dsl_option_names << name
        end

        private

        def own_dsl_option_names
          @own_dsl_option_names ||= Set.new
        end
      end
    end
  end
end
