import "package:test/test.dart";

import "../lib/vm.dart" as vmLib;

@TestOn('vm')


main() {
  group('sayHello', () {
    test('returns the correct string', () {
      expect(vmLib.sayHello('steve'), equals('hello steve'));
    });
  });
}
