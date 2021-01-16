// @dart=2.9

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

library codecov.bin.generate_coverage;

import 'src/executable.dart' as executable;


void main(List<String> args) {
  print('Warning: `pub run codecov:generate_coverage` is deprecated.');
  print('Use `pub run codecov` instead.\n');
  executable.main(args);
}
