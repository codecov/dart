@TestOn('browser')
library dart_codecov_generator.test.browser_test;

import 'dart:html';

import 'package:test/test.dart';
import 'package:unittest/html_config.dart';

useHtmlConfiguration(true);

bool _dummyCoverage() => true;

void main() {
  group('Browser Test', () {
    test('should support importing dart:html', () {
      var elem = new DivElement();
      expect(elem is DivElement, isTrue);
    });

    test('should report coverage for browser tests', () async {
      expect(_dummyCoverage(), isTrue);
    });
  });
}
