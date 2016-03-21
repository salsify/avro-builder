# avro-builder changelog

## v0.3.0
- Add support for nested records. This includes the ability to reference a
  previously defined record as a type.

## v0.2.0
- Add support for `:union` type.
- Make `fixed` syntax more flexible. Both `fixed :f, 7` and `fixed :f, size: 7`
  are now supported and equivalent.

## v0.1.0
- Initial release
