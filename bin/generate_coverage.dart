import "dart:io";
import "dart:async";
import "dart:convert";
import "package:args/args.dart";

main(List<String> arguments) async {
  var parser = new ArgParser();
  parser.addFlag('gen-html', defaultsTo: true);
  var results = parser.parse(arguments);
  var genHtml = results['gen-html'];
  arguments = results.rest;

  if (arguments.length < 1) {
    print("No test file given. Please specify a test file.");
    exit(1);
  }

  var file = arguments[0];
  print('collecting coverage for $file');

  Process testProcess;
  try {
    testProcess = await attemptToRunTests(file);
  } catch (e) {
    var port = await pidOfPort();
    print('Tests may have failed or a process with PID $port may be occupying :8444\n\n$e');
    exit(1);
  }

  var tmpFolder = 'tmp_coverage';
  var dir = await new Directory(tmpFolder).create(recursive: true);

  print('running coverage');
  await Process.run(
      'collect_coverage', ['--port=8444', '-o', '$tmpFolder/coverage.json', '--resume-isolates']);

  print('formatting coverage');
  await Process.run('format_coverage', [
    '-l',
    '--package-root=packages',
    '-i',
    '$tmpFolder/coverage.json',
    '-o',
    'lcov_coverage.lcov'
  ]);

  if (genHtml) {
    print('generating html');
    await Process.run('genhtml', ['-o', 'lcov_report', 'lcov_coverage.lcov']);
  }


  if (genHtml) {
    print('Coverage generated. Open lcov_report/index.html');
  } else {
    print('Coverage generated.  Results saved to lcov_coverage.lcov');
  }
  dir.delete(recursive: true);
  testProcess.kill();
  exit(0);
}

// attempts to run tests with the default observe port, 8444
Future<Process> attemptToRunTests(String file) {
  var completer = new Completer<Process>();
  Process.start('dart', ['--observe=8444', file]).then((Process p) {
    p.stdout.transform(UTF8.decoder).takeWhile((_) => !completer.isCompleted).listen((data) {
      var failed = new RegExp(r"Some tests failed.");
      if (failed.hasMatch(data)) {
        completer.completeError("Some tests failed.");
      }
      var passed = new RegExp(r"All tests passed!");
      if (passed.hasMatch(data)) {
        completer.complete(p);
      }
    });
  }).catchError((e) {
    completer.completeError("error running tests: $e");
  });
  return completer.future;
}

Future<String> pidOfPort() {
  return Process
  .run('lsof', ['-i', ':8444', '-t'])
  .then((ProcessResult pr) => (pr.stdout as String).replaceAll('\n', ''));
}
