// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_cockroachdb/otel_cockroachdb.dart';
import 'package:test/test.dart';

void main() {
  group('otel_cockroachdb', () {
    test('suppression toggles in zone', () async {
      expect(cockroachDBInstrumentationSuppressed(), isFalse);
      await runWithoutCockroachDBInstrumentationAsync(() async {
        expect(cockroachDBInstrumentationSuppressed(), isTrue);
      });
      expect(cockroachDBInstrumentationSuppressed(), isFalse);
    });

    test('CockroachDBResult fields default null', () {
      const r = CockroachDBResult();
      expect(r.statusCode, isNull);
    });
  });
}
