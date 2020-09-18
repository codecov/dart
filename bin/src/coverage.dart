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
import 'package:path/path.dart' as path;

import 'env.dart';
import 'test.dart' show Test, BrowserTest, VmTest;


int _coverageCount = 0;
const int _defaultObservatoryPort = 8444;
const String _tempCoverageDirPath = '__temp_coverage';
Directory coverageDir = new Directory('coverage');

void _mergeCoveragePayloads(Map dest, Map source) {
  dest['coverage'].addAll(source['coverage']);
}


class Coverage {
  static Future<Coverage> merge(List<Coverage> coverages) async {
    if (coverages.length == 0) throw new ArgumentError('Cannot merge an empty list of coverages.');
    Coverage merged = new Coverage(null);
    merged._tempCoverageDir = coverageDir;

    Logger log = new Logger('dcg');
    for (int i = 1; i < coverages.length; i++) {
      Directory entityDir = new Directory('${coverages[i]._tempCoverageDir}/test');
      log.shout('EntityDir: ${entityDir}');
      List<FileSystemEntity> entities = entityDir.listSync();
      log.shout('Entities ${entities}');
      for (FileSystemEntity entity in entities) {
        if (entity is File) {
          String base = path.basename(entity.path);
          entity.rename('$coverageDir/$base');
        }
      }
    }
    log.shout('Found ${coverageDir.listSync().length} files in ${coverageDir.path}');
    return merged;
  }

  Test test;
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

    ProcessResult pr = await Process.run('pub', [
      'run',
      'test',
      '--coverage',
      _tempCoverageDir.path,
    ]);
    log.info('Coverage collected');

    test.kill();
    log.shout(pr.stdout);

    if (pr.exitCode == 0) {
      log.shout('Coverage collected.');
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
    List<String> args = [
      'run',
      'coverage:format_coverage',
      '--lcov',
      '--packages=.packages',
      '-i',
      '${_tempCoverageDir.path}/',
      '-o',
      lcovOutput.path,
    ];
    log.shout('THESE ARE ARGS');
    log.shout(args);

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
