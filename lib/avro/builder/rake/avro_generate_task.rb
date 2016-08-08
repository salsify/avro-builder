require 'rake/tasklib'
require 'avro/builder'

module Avro
  module Builder
    module Rake
      class AvroGenerateTask < ::Rake::TaskLib

        attr_accessor :name, :task_namespace, :task_desc, :root,
                      :load_paths, :dependencies

        def initialize(name: :generate, dependencies: [])
          @name = name
          @task_namespace = :avro
          @task_desc = 'Generate Avro schema files from Avro::Builder DSL'
          @load_paths = []
          @root = "#{Rails.root}/avro/dsl" if defined?(Rails)
          @dependencies = dependencies

          yield self if block_given?

          define
        end

        private

        # Define the rake task
        def define
          namespace task_namespace do
            desc task_desc
            task(name.to_sym => dependencies) do
              raise '"root" must be specified for Avro DSL files' unless root
              Avro::Builder.add_load_path(*[root, load_paths].flatten)
              Dir["#{root}/**/*.rb"].each do |dsl_file|
                puts "Generating Avro schema from #{dsl_file}"
                output_file = dsl_file.sub('/dsl/', '/schema/').sub(/\.rb$/, '.avsc')
                schema = Avro::Builder.build(File.read(dsl_file))
                FileUtils.mkdir_p(File.dirname(output_file))
                File.write(output_file, schema.end_with?("\n") ? schema : schema << "\n")
              end
            end
          end
        end
      end
    end
  end
end
