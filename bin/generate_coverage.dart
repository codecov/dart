library dart_codecov_generator.bin.generate_coverage;

import 'src/executable.dart' as executable;


void main(List<String> args) {
  print('Warning: `pub run dart_codecov_generator:generate_coverage` is deprecated.');
  print('Use `pub run dart_codecov_generator` instead.\n');
  executable.main(args);
}