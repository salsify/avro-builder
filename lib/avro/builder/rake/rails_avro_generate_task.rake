# frozen_string_literal: true

require 'avro/builder/rake/avro_generate_task'
Avro::Builder::Rake::AvroGenerateTask.new(dependencies: [:environment])
