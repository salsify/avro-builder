module Avro
  module Builder
    class Railtie < Rails::Railtie

      initializer 'salsify_avro.avro_builder_load_path' do
        Avro::Builder.add_load_path("#{Rails.root}/avro/dsl")
      end

      rake_tasks do
        load File.expand_path('../rake/rails_avro_generate_task.rake', __FILE__)
      end
    end
  end
end
