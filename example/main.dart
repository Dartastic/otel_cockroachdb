// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_cockroachdb/otel_cockroachdb.dart';

/// Traces Cockroachdb calls with OpenTelemetry.
///
/// `otel_cockroachdb` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Cockroachdb call in
/// [tracedCockroachDB]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'cockroachdb-example');

  // Traces a Cockroachdb call.
  final cockroachDBId = await tracedCockroachDB<String>(
    operation: 'create',
    invoke: () async {
      // Make the Cockroachdb call here, then report what it returned.
      const id = 'cockroachdb_8f3a2c';
      return const CockroachDBCallResult(
          value: id,
          result: CockroachDBResult(
              cluster: 'example',
              database: 'example',
              schema: 'example',
              table: 'orders',
              statementType: 'active',
              queryText: 'example',
              rowsAffected: 1,
              retries: 1,
              region: 'us-east-1',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedCockroachDB create returned $cockroachDBId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutCockroachDBInstrumentationAsync.
  await runWithoutCockroachDBInstrumentationAsync(
    () => tracedCockroachDB<String>(
      operation: 'create',
      invoke: () async {
        const id = 'cockroachdb_8f3a2c';
        return const CockroachDBCallResult(
            value: id,
            result: CockroachDBResult(
                cluster: 'example',
                database: 'example',
                schema: 'example',
                table: 'orders',
                statementType: 'active',
                queryText: 'example',
                rowsAffected: 1,
                retries: 1,
                region: 'us-east-1',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
