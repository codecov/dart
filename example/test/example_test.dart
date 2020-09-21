import "package:codecov_generator_example/example.dart";
import "package:test/test.dart";

main() {
  group('sayHello', () {
    test('returns the correct string', () {
      expect(sayHello('steve'), equals('hello steve'));
    });
  });
}
