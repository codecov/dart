import 'dart:html';

import 'package:test/test.dart';

import '../lib/browser.dart' as browserLib;

@TestOn('browser')


main() {
  group('sayHello', () {
    setUp(() {
      browserLib.setUp();
    });

    test('returns the correct string', () {
      browserLib.sayHello('steve');
      expect(browserLib.container.text, equals('hello steve'));
    });
  });
}
