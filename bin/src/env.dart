library dart_codecov_generator.bin.src.env;

import 'package:args/args.dart';

Env env;

class Env {
  List<String> filePaths;
  bool html;
  bool lcov;
  List<String> reportOn;
  bool verbose;
  Env(this.filePaths, this.reportOn, this.html, this.lcov, this.verbose);
}

void setupEnv(List<String> args) {
  var parser = new ArgParser();
  parser.addOption('report-on', abbr: 'r', allowMultiple: true);
  parser.addFlag('html', defaultsTo: true);
  parser.addFlag('lcov', defaultsTo: true);
  parser.addFlag('verbose', abbr: 'v');
  var results = parser.parse(args);
  List<String> filePaths = results.rest.length > 0 ? results.rest : ['test'];
  env = new Env(filePaths, results['report-on'], results['html'], results['lcov'], results['verbose']);
}