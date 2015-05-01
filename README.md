# dart codecov generator

generate coverage for dart projects.

This project automatically runs a test file,
runs `collect_coverage`, and uses `format_coverage` to format the results as LCOV

## Installation
Depends on the following utilities:

- coverage.dart (`pub global activate coverage`),
- genhtml (`brew install lcov` on a mac)
- lsof (standard unix utility)

```
pub global activate --source git git@github.com:johnpryan/dart_codecov_generator.git
```

## Using

```
pub global activate --source git git@github.com:johnpryan/dart_codecov_generator.git
```
then

```
generate_coverage test/my_test.dart
```
