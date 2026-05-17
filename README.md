# otel_cockroachdb

Dartastic OpenTelemetry bridge for CockroachDB (distributed SQL).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_cockroachdb/otel_cockroachdb.dart';

await tracedCockroachDB<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return CockroachDBCallResult(value: r, result: CockroachDBResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutCockroachDBInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
