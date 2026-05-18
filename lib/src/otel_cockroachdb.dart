// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_cockroachdb_suppression.dart';

class CockroachDBResult {
  const CockroachDBResult({
    this.cluster,
    this.database,
    this.schema,
    this.table,
    this.statementType,
    this.queryText,
    this.rowsAffected,
    this.retries,
    this.region,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? cluster;
  final String? database;
  final String? schema;
  final String? table;
  final String? statementType;
  final String? queryText;
  final int? rowsAffected;
  final int? retries;
  final String? region;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class CockroachDBCallResult<T> {
  const CockroachDBCallResult({required this.value, this.result});
  final T value;
  final CockroachDBResult? result;
}

Future<T> tracedCockroachDB<T>({
  required String operation,
  required Future<CockroachDBCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (cockroachDBInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_cockroachdb');
  final span = t.startSpan('cockroachdb $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('db.system.name', 'cockroachdb');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.cluster != null) {
        span.setStringAttribute('cockroach.cluster', res.cluster!);
      }
      if (res.database != null) {
        span.setStringAttribute('db.namespace', res.database!);
      }
      if (res.schema != null) {
        span.setStringAttribute('db.schema', res.schema!);
      }
      if (res.table != null) {
        span.setStringAttribute('db.collection.name', res.table!);
      }
      if (res.statementType != null) {
        span.setStringAttribute('db.operation.name', res.statementType!);
      }
      if (res.queryText != null) {
        span.setStringAttribute('db.query.text', res.queryText!);
      }
      if (res.rowsAffected != null) {
        span.setIntAttribute('db.response.returned_rows', res.rowsAffected!);
      }
      if (res.retries != null) {
        span.setIntAttribute('cockroach.retries', res.retries!);
      }
      if (res.region != null) {
        span.setStringAttribute('cloud.region', res.region!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('cockroachdb.error.code', res.errorCode!);
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
            ErrorResource.errorType.key, res.errorCode ?? 'cockroach.error');
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
