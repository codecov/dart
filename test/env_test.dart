@TestOn('vm')
library codecov.test.env_test;

import 'package:test/test.dart';

import '../bin/src/coverage.dart';
import '../bin/src/env.dart';
import '../bin/src/executable.dart';
import '../bin/src/test.dart';
import '../bin/generate_coverage.dart';

void main() {
  group('Environment', () {
    test('should default --html and --lcov to true', () {
      setupEnv([]);
      expect(env.html, isTrue);
      expect(env.lcov, isTrue);
    });
  });
}
