# avro-builder changelog

## v0.9.0
- Add rake task to generate Avro JSON schema files for all DSL files under a
  configurable root directory.
- Add Railtie to configure `#{Rails.root}/avro/dsl` as a load path, and define
  `avro:generate` rake task.

## v0.8.0
- Add `Avro::Builder::SchemaStore` to load DSL files and return schema objects.

## v0.7.0
- Only allow `type_name` and `type_namespace` options for naming named types
  defined inline.
- Only allow first argument to set name, and `namespace` option for top-level
  types.
- Only allow `aliases` attribute to set aliases for top-level types.

## v0.6.0
- Support recursive definitions.
- Coerce aliases to be represented as an array.
- Only allow name and namespace to be set via options, not via a block, for
  record, enum, and fixed types.
- Allow `doc` and `aliases` to be set on both a field and a type defined inline
  for the field. To set these attributes on the inline type `type_doc` and 
  `type_aliases` must be used in the DSL.

## v0.5.0
- Support references to named types that are defined inline.
- Raise an error for duplicate definitions with the same fullname.

## v0.4.0
- Add validation for required DSL attributes that are not specified.
- Allow name to be configured via a block for top-level record, enum, and fixed
  types.

## v0.3.2
- Fix a bug that allowed the partial matching of filenames.
- Fix a bug that prevented namespace from being specified as an option on
  records.
- Fix a bug that prevented loading references qualified by namespace.
- Do not attempt to import schema files for builtin types.

## v0.3.1
- A `null` default should automatically be added for optional fields to match
  the `:null` first member of the union.

## v0.3.0
- Add support for nested records. This includes the ability to reference a
  previously defined record as a type.

## v0.2.0
- Add support for `:union` type.
- Make `fixed` syntax more flexible. Both `fixed :f, 7` and `fixed :f, size: 7`
  are now supported and equivalent.

## v0.1.0
- Initial release
