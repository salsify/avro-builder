# Avro::Builder

`Avro::Builder` provides a Ruby DSL to create Apache Avro [link] Schemas.

This DSL was created because:
* The Avro IDL [link] is not supported in Ruby.
* The Avro IDL can only be used to defined Protocols.
* Schemas can be extracted as JSON from an IDL Protocol but support
  for imports is still limited.

## Usage

To use `Avro::Builder` define a schema:

```ruby
namespace 'com.example'

fixed :password, 8

enum :user_type, :ADMIN, :REGULAR

record :user do
  required :id, :long
  required :user_name, :string
  required :type, :user_type, default: :REGULAR
  required :pw, :password
  optional :full_name, :string
end
```

The schema definition may be passed as a string or a block to
`Avro::Builder.build`.

This generates the following Avro schema:
```json
{
  "type": "record",
  "name": "user",
  "namespace": "com.example",
  "fields": [
    {
      "name": "id",
      "type": "long"
    },
    {
      "name": "user_name",
      "type": "string"
    },
    {
      "name": "type",
      "type": {
        "name": "user_type",
        "type": "enum",
        "symbols": [
          "ADMIN",
          "REGULAR"
        ],
        "namespace": "com.example"
      },
      "default": "REGULAR"
    },
    {
      "name": "pw",
      "type": {
        "name": "password",
        "type": "fixed",
        "size": 8,
        "namespace": "com.example"
      }
    },
    {
      "name": "full_name",
      "type": [
        "null",
        "string"
      ]
    }
  ]
}
```

## Features
* `fixed` and `enum` fields may be specified inline as part of a record
  or as standalone named types.
* Definitions may b,e imported from other files using `import <filename>`.
* A previously defined record may be referenced in the defintion of another
  record using `extends <record_name>`. This adds off of the fields from
  the referenced record to the current record.

## Limitations

* Only Avro Schemas, not Protocols are supported.
