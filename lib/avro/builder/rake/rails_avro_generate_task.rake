require 'avro/builder/rake/avro_generate_task'
Avro::Builder::Rake::AvroGenerateTask.new(dependencies: %i(environment))
