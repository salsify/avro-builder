module Avro
  module Builder

    class Record < Avro::Builder::Types::RecordType
      include Avro::Builder::Types::TopLevel
    end
  end
end
