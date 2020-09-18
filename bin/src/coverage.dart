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
const String tempCoverageDirPath = '__temp_coverage';
Directory coverageDir = new Directory('coverage');

class Coverage {
  static Future<Coverage> merge(List<Coverage> coverages) async {
    if (coverages.length == 0) throw new ArgumentError('Cannot merge an empty list of coverages.');
    Coverage merged = new Coverage(null);
    merged._tempCoverageDir = coverageDir;

    Logger log = new Logger('dcg');
    bool exists = await Directory(coverageDir.path).exists();
    log.shout('coverageDir: ${coverageDir.path} | ${exists}');
    log.shout('coverages: ${coverages}');

    for (int i = 0; i < coverages.length; i++) {
      log.shout('coverage: ${coverages[i]}, i: ${i}');

      if (await coverages[i].coverageFile.exists()) {
        File coverageFile = coverages[i].coverageFile;
        String base = path.basename(coverageFile.path);
        log.shout('Renaming: ${coverageFile.path} to ${coverageDir.path}/$base');
        coverageFile.rename('${coverageDir.path}/$i-$base');

        bool fileExists = await File('${coverageDir.path}/$i-$base').exists();
      }
    }

    log.shout('Found ${coverageDir.listSync().length} files in ${coverageDir.path}');
    return merged;
  }

  Test test;
  File lcovOutput;
  File coverageFile;
  Directory _tempCoverageDir;
  Coverage(this.test) {
    _coverageCount++;
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
    Directory _tempCoverageDir = new Directory('${coverageDir.path}/${_coverageCount}');
    await _tempCoverageDir.create(recursive: true);

    ProcessResult pr = await Process.run('pub', [
      'run',
      'test',
      '--coverage',
      '${coverageDir.path}/{$_coverageCount}',
    ]);
    log.info('Coverage collected');

    test.kill();
    log.shout(pr.stdout);

    log.shout('the dir ${_tempCoverageDir.path} exists?: ${await _tempCoverageDir.exists()}');

    Directory testDir = new Directory('${_tempCoverageDir.path}/test');
    log.shout('the dir ${testDir.path} exists?: ${await testDir.exists()}');
    List<FileSystemEntity> entities = new Directory('${_tempCoverageDir.path}').listSync();

    log.shout('entities: ${entities}');
    if (entities.length == 1 && entities[0] is File) {
      coverageFile = entities[0] as File;
    }

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
