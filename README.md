# dart codecov generator

generate coverage for dart projects.

This project automatically runs a test file,
runs `collect_coverage`, and uses `format_coverage` to format the results as LCOV

## Installation
Depends on the following utilities:

- coverage.dart (`pub global activate coverage`),
- genhtml (part of lcov),
- lsof (standard unix utility)

```
pub global activate --source git git@github.com:johnpryan/dart_codecov_generator.git
```

## Using

```
pub global activate --source git git@github.com:johnpryan/dart_codecov_generator.git
```

use generator to convert the json into LCOV:

```
dart_codecov_generator --no-gen-html test/kitchen_test.dart
```

this will output a `.lcov` file

(OPTIONAL) you can also generate HTML if you have `lcov` installed (`brew install lcov` on a mac):

```
dart_codecov_generator test/kitchen_test.dart
```
