library dart_codecov_generator.bin.src.executable;

import 'dart:io';

import 'package:logging/logging.dart';

import 'coverage.dart';
import 'env.dart' show env, setupEnv;
import 'test.dart';


void print_log(LogRecord record) {
  if (env.verbose || record.level >= Level.SEVERE) {
    print(record.message);
    if (record.error != null) {
      print(record.error);
    }
    if (record.stackTrace != null) {
      print(record.stackTrace);
    }
  }
}


main(List<String> args) async {
  setupEnv(args);
  bool htmlSuccess = false;
  bool lcovSuccess = false;

  Logger log = new Logger('dcg');
  log.onRecord.listen(print_log);
  log.shout('Generating coverage...');

  log.info('Environment:');
  log.info('\treportOn - ${env.reportOn}');
  log.info('\thtml - ${env.html}');
  log.info('\tlcov - ${env.lcov}');
  log.info('\tverbose - ${env.verbose}');

  if (!env.html && !env.lcov) {
    log.severe('You must enable HTML and/or lcov output.');
    exit(1);
  }

  if (env.filePaths.length <= 0) {
    log.severe('No test file given. Please specify at least one test file.');
    exit(1);
  }

  List<String> testFiles = [];

  env.filePaths.forEach((String filePath) {
    if (FileSystemEntity.isDirectorySync(filePath)) {
      List<FileSystemEntity> children = new Directory(filePath).listSync(recursive: true);
      testFiles.addAll(children.where((FileSystemEntity e) => e is File && !((Uri.parse(e.path)).pathSegments.contains('packages'))).map((FileSystemEntity e) => e.path));
    } else if (FileSystemEntity.isFileSync(filePath)) {
      testFiles.add(filePath);
    }
  });

  log.info('Test Files:');
  testFiles.forEach((String filePath) {
    log.info('\t$filePath');
    if (!FileSystemEntity.isFileSync(filePath)) {
      log.severe('Given test file does not exist: ${new File(filePath).absolute.path}');
      exit(1);
    }
    if (!filePath.endsWith('.dart') && !filePath.endsWith('.html')) {
      log.severe('Given test file is invalid: ${new File(filePath).absolute.path}');
      exit(1);
    }
  });

  List<Coverage> coverages = [];
  for (int i = 0; i < testFiles.length; i++) {
    Test test = await Test.parse(testFiles[i]);
    Coverage coverage = new Coverage(test);
    await coverage.collect();
    coverages.add(coverage);
  }

  Coverage coverage = await Coverage.merge(coverages);
  coverages.forEach((cov) => cov.cleanUp());
  if (await coverage.format()) {
  } else {
    exit(1);
  }
  if (env.lcov) {
    coverage.lcovOutput.copySync('coverage.lcov');
    lcovSuccess = true;
  }
  if (env.html) {
    htmlSuccess = await coverage.generateHtml();
    if (!htmlSuccess) {
      exit(1);
    }
  }
  coverage.cleanUp();

  log.shout('\nCoverage generated!');
  if (lcovSuccess) {
    log.shout('\tlcov:  \tcoverage.lcov');
  }
  if (htmlSuccess) {
    log.shout('\treport:\tcoverage_report/index.html');
  }
}