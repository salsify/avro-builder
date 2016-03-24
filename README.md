# Avro::Builder

[![Build Status](https://travis-ci.org/salsify/avro-builder.svg?branch=master)][travis]

[travis]: http://travis-ci.org/salsify/avro-builder

`Avro::Builder` provides a Ruby DSL to create [Apache Avro](https://avro.apache.org/docs/current/) Schemas.

This DSL was created because:
* The [Avro IDL](https://avro.apache.org/docs/current/idl.html) is not supported in Ruby.
* The Avro IDL can only be used to define Protocols.
* Schemas can be extracted as JSON from an IDL Protocol but support
  for imports is still limited.

## Features
* The syntax is designed for ease-of-use.
* Definitions can be imported by name. This includes auto-loading from a configured
  set of paths. This allows definitions to split across files and even reused
  between projects.
* Record definitions can inherit from other record definitions.

## Limitations

* Only Avro Schemas, not Protocols are supported.
* See [Issues](https://github.com/salsify/avro-builder/issues) for functionality
  that has yet to be implemented.
* This is alpha quality code. There may be breaking changes until version 1.0 is
  released.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'avro-builder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install avro-builder

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

This generates the following Avro JSON schema:
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
      ],
      "default": null
    }
  ]
}
```

### Required and Optional

Fields for a record are specified as `required` or `optional`. Optional fields are
implemented as a union in Avro, where `null` is the first type in the union and
the field has a default value of `null`.

### Named Types

`fixed` and `enum` fields may be specified inline as part of a record
or as standalone named types.

```ruby
# Either syntax is supported for specifying the size
fixed :f, 4
fixed :g, size: 8

# Either syntax is supported for specifying symbols
enum :e, :X, :Y, :Z
enum :d, symbols: [:A, :B]

record :my_record_with_named do
  required :f_ref, :f
  required :fixed_inline, :fixed, size: 9
  required :e_ref, :e
  required :enum_inline, :enum, symbols: [:P, :Q]
end
```

### Nested Records

Nested records may be created by referring to the name of the previously
defined record or using the field type `:record`.

```ruby
record :sub_rec do
  required :i, :int
end

record :top_rec do
  required :sub, :sub_rec
end
```

Definining a subrecord inline:

```ruby
record :my_rec do
  required :nested, :record do
    required :s, :string
  end
end
```

Nested record types defined without an explicit name are given a generated
name based on the name of the field and record that they are nested within.
In the example above, the nested record type would have the generated name
`__my_rec_nested_record`:

```json
{
  "type": "record",
  "name": "my_rec",
  "fields": [
    {
      "name": "nested",
      "type": {
        "type": "record",
        "name": "__my_rec_nested_record",
        "fields": [
          {
            "name": "s",
            "type": "string"
          }
        ]
      }
    }
  ]
}
```

### Unions

A union may be specified within a record using `required` and `optional` with
the `:union` type:

```ruby
record :my_record_with_unions do
  required :req_union, :union, types: [:string, :int]
  optional :opt_union, :union, types: [:float, :long]
end
```

For an optional union, `null` is automatically added as the first type for
the union and the field defaults to `null`.

### Auto-loading and Imports

Specify paths to search for definitions:

```ruby
Avro::Builder.add_load_path('/path/to/dsl/files')
```

Undefined references are automatically loaded from a file with the same name.
The load paths are searched for `.rb` file with a matching name.

Files may also be explicitly imported using `import <filename>`.

### Extends

A previously defined record may be referenced in the definition of another
record using `extends <record_name>`. This adds all of the fields from
the referenced record to the current record. The current record may override
fields in the record that it extends.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Issues and pull requests are welcome on GitHub at https://github.com/salsify/avro-builder.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

