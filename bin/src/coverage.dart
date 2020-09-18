// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library dart_codecov_generator.bin.src.coverage;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

import 'env.dart';
import 'test.dart' show Test, BrowserTest, VmTest;


int _coverageCount = 0;
const int _defaultObservatoryPort = 8444;
const String _tempCoverageDirPath = '__temp_coverage';


void _mergeCoveragePayloads(Map dest, Map source) {
  dest['coverage'].addAll(source['coverage']);
}


class Coverage {
  static Future<Coverage> merge(List<Coverage> coverages) async {
    if (coverages.length == 0) throw new ArgumentError('Cannot merge an empty list of coverages.');
    Coverage merged = new Coverage(null);

    Logger log = new Logger('dcg');
    log.shout('did it');
    log.shout(coverage[0].collectionOutput);
    log.shout(await coverages[0].collectionOutput.readAsString());
    Map mergedJson = json.decode(await coverages[0].collectionOutput.readAsString());
    for (int i = 1; i < coverages.length; i++) {
      Map coverageJson = json.decode(await coverages[i].collectionOutput.readAsString());
      _mergeCoveragePayloads(mergedJson, coverageJson);
    }

    merged.collectionOutput = new File('${merged._tempCoverageDir.path}/coverage.json');
    merged.collectionOutput.createSync();
    merged.collectionOutput.writeAsStringSync(json.encode(mergedJson));
    return merged;
  }

  Test test;
  File collectionOutput;
  File lcovOutput;
  Directory _tempCoverageDir;
  Coverage(this.test) : _tempCoverageDir = new Directory('$_tempCoverageDirPath${_coverageCount++}') {
    _tempCoverageDir.create();
  }

  Future<bool> collect() async {
    Logger log = new Logger('dcg');
    bool testSuccess = await test.run();
    if (!testSuccess) {
      try {
        log.info(await test.process.stderr.transform(utf8.decoder).join(''));
      } catch(e) {}
      log.severe('Testing failed.');
      test.kill();
      return false;
    }
    int port = test is BrowserTest ? (test as BrowserTest).observatoryPort : _defaultObservatoryPort;

    log.shout('Collecting coverage...');
    log.shout('Test if temp directory exists');
    bool dirExists = await Directory(_tempCoverageDir.path).exists();
    log.shout('Directory: ${dirExists}');
    collectionOutput = new File('${_tempCoverageDir.path}/coverage.json');
    log.shout(collectionOutput.path);
    log.shout('File exists?');
    bool fileExists = await File(collectionOutput.path).exists();
    log.shout('File: ${fileExists}');
    ProcessResult pr = await Process.run('pub', [
      'run',
      'test',
      '--coverage',
      _tempCoverageDir.path,
    ]);
    log.info('Coverage collected');

    test.kill();

    log.info(pr.stdout);
    if (pr.exitCode == 0) {
      log.info('Coverage collected.');
      return true;
    } else {
      log.shout(pr.stderr);
      log.severe('Coverage collection failed.');
      return false;
    }
  }

  Future<bool> format() async {
    Logger log = new Logger('dcg');
    log.info('Formatting coverage...');
    lcovOutput = new File('${_tempCoverageDir.path}/coverage.lcov');
    List args = [
      'run',
      'coverage:format_coverage',
      '-l',
      '--package-root=packages',
      '-i',
      collectionOutput.path,
      '-o',
      lcovOutput.path,
    ];
    if (env.reportOn != null) {
      args.addAll(env.reportOn.map((r) => '--report-on=$r'));
    }
    if (env.verbose) {
      args.add('--verbose');
    }
    ProcessResult pr = await Process.run('pub', args);

    log.info(pr.stdout);
    if (pr.exitCode == 0) {
      log.info('Coverage formatted.');
      return true;
    } else {
      log.info(pr.stderr);
      log.severe('Coverage formatting failed.');
      return false;
    }
  }

  Future<bool> generateHtml() async {
    Logger log = new Logger('dcg');
    log.info('Generating HTML...');
    ProcessResult pr = await Process.run('genhtml', ['-o', 'coverage_report', lcovOutput.path]);

    log.info(pr.stdout);
    if (pr.exitCode == 0) {
      log.info('HTML generated.');
      return true;
    } else {
      log.info(pr.stderr);
      log.severe('HTML generation failed.');
      return false;
    }
  }

  void cleanUp() {
    if (test != null) {
      test.cleanUp();
    }
    _tempCoverageDir.deleteSync(recursive: true);
  }
}
