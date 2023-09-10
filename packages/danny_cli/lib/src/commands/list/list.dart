import 'dart:async';
import 'dart:io';

import '../../command.dart';
import '../../utils.dart';

/// {@template list_command}
/// `danny list` command.
/// {@endtemplate}
class ListCommand extends DannyCommand {
  /// {@macro list_command}
  ListCommand({super.logger});

  @override
  String get description => 'List the commands of a project.';

  @override
  String get name => 'list';

  @override
  String get invocation => 'danny list';

  @override
  FutureOr<void> run() async {
    final project = await resolveProject(Directory.current);
    final pubspec = project.pubspec;
    final rootDir = project.rootDir;
    final name = pubspec.executables.keys.first;

    final commandConfigs = parseCommandConfigs(rootDir);
    for (final leafCommandConfig in commandConfigs.leafs()) {
      logger.info([name, leafCommandConfig.spaced].join(' '));
    }
  }
}
