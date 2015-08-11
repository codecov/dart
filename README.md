# Dart Code Coverage Generator
[![Build Status](https://travis-ci.org/codecov/dart.svg?branch=master)](https://travis-ci.org/codecov/dart) [![codecov.io](http://codecov.io/github/codecov/dart/coverage.svg?branch=master)](http://codecov.io/github/codecov/dart?branch=master)

> Generate code coverage for Dart projects. Output can be [lcov](http://ltp.sourceforge.net/coverage/lcov.php) format or an HTML report.

This project includes a `dart_codecov_generator` executable that runs one or many test files and uses the `coverage` package to collect coverage for each file and format the coverage into the desired output format.


## Prerequisites
Depends on the following utilities:

- genhtml (`brew install lcov` on a mac)
- lsof (standard unix utility)


## Installation

Add this to your package's pubspec.yaml file:
```yaml
dependencies:
  coverage: "^0.7.0"
  dart_codecov_generator: "^0.4.0"
```

Install:
```
pub get
```


## Usage
```
pub run dart_codecov_generator
```


## Configuration
By default, this tool runs every test file in the `test/` directory. You can explicitly specify the directories or files like so:
```
pub run dart_codecov_generator test/my_test.dart
```

### Options
- `--report-on`: Which directories or files to report coverage on. For example, `--report-on=lib/`.

### Flags
- `--html`: Whether or not to generate the HTML report. Defaults to true.
- `--lcov`: Whether or not to generate the .lcov file. Defaults to true.
- `--verbose`: Toggle verbose output to stdout.
