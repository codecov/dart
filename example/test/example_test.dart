import 'package:test/test.dart';

import '../lib/example.dart';

main() {
  group('sayHello', () {
    test('returns the correct string', () {
      expect(sayHello('steve'), equals('hello steve'));
    });
  });
}
