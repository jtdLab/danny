import 'dart:io';

import 'package:danny_cli/src/command_runner.dart';
import 'package:danny_cli/src/logging.dart';

void main(List<String> arguments) async {
  final logger = Logger();
  try {
    await DannyCommandRunner(logger: logger).run(arguments);
  } catch (e) {
    logger.err(e.toString());
    exitCode = 1;
  }
}
