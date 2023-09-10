import 'dart:async';
import 'dart:io';

import 'package:ansi_styles/ansi_styles.dart';

import '../../command.dart';
import '../../exception.dart';
import '../../process.dart' as process;
import '../../utils.dart';

/// {@template activate_command}
/// `danny activate` command.
/// {@endtemplate}
class ActivateCommand extends DannyCommand {
  /// {@macro activate_command}
  ActivateCommand({super.logger});

  @override
  String get description => 'Activate a build locally.';

  @override
  String get name => 'activate';

  @override
  String get invocation => 'danny activate';

  @override
  FutureOr<void> run() async {
    final project = await resolveProject(Directory.current);
    final pubspec = project.pubspec;
    final rootDir = project.rootDir;
    final name = pubspec.executables.keys.first;

    final activateResult = await process.run(
      dartPubGlobalActivateSourcePath(),
      workingDirectory: rootDir.path,
    );

    if (activateResult.exitCode != 0) {
      final stdout = activateResult.stdout;
      final stderr = activateResult.stderr;
      throw DannyException(
        'Failed to activate!\n'
        '\n'
        '$stdout\n'
        '\n'
        '$stderr',
      );
    }

    logger
      ..success(
        'Activated successfully!',
        style: AnsiStyles.green.bold.call,
      )
      ..info('')
      ..info('To use the new CLI run:')
      ..info('')
      ..info('  $name --help')
      ..info('');
  }
}
