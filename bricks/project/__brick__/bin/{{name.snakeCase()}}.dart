import 'dart:io';

import '../runner.danny.dart';

void main(List<String> args) async {
  try {
    await {{name.pascalCase()}}CommandRunner().run(args);
  } catch (e) {
    stderr.write(e.toString());
    exitCode = 1;
  }
}
