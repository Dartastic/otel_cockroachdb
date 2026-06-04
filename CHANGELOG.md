# Changelog

## [0.1.0-beta.1] - 2026-06-04

### Added

- Initial release.
- `tracedCockroachDB<T>(...)` — wraps a otel_cockroachdb call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutCockroachDBInstrumentation()` / `Async()`.
