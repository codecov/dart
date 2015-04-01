import "dart:io";
import "dart:async";
import "dart:convert";

main(List<String> args) async {
  if (args.length < 1) {
    print("No test file given. Please specify a test file.");
    exit(1);
  }
  var file = args[0];
  print('collecting coverage for $file');

  Process testProcess;
  try {
    testProcess = await attemptToRunTests(file);
  } catch (e) {
    var port = await pidOfPort();
    print('failed.  A process with PID $port is occupying :8444');
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

  print('generating html');
  await Process.run('genhtml', ['-o', 'lcov_report', 'lcov_coverage.lcov']);

  print('Coverge generated. Open lcov_report/index.html');
  dir.delete(recursive: true);
  testProcess.kill();
  exit(0);
}

// attempts to run tests with the default observe port, 8444
Future<Process> attemptToRunTests(String file) {
  var completer = new Completer<bool>();
  Process.start('dart', ['--observe=8444', file]).then((Process p) {
    p.stdout.transform(UTF8.decoder).takeWhile((_) => !completer.isCompleted).listen((data) {
      var failed = new RegExp(r"SocketException");
      if (failed.hasMatch(data)) {
        completer.completeError("SocketException");
      }
      var passed = new RegExp(r"unittest-suite-success");
      if (passed.hasMatch(data)) {
        completer.complete(p);
      }
    });
  });
  return completer.future;
}

Future<String> pidOfPort() {
  return Process
  .run('lsof', ['-i', ':8444', '-t'])
  .then((ProcessResult pr) => (pr.stdout as String).replaceAll('\n', ''));
}
