import 'dart:async';
import 'dart:io';

import 'package:ansi_styles/ansi_styles.dart';
import 'package:path/path.dart' as p;

import '../../command.dart';
import '../../exception.dart';
import '../../mason.dart' as mason;
import '../../models/command_config.dart';
import '../../process.dart' as process;
import '../../utils.dart';
import 'templates/command_runner_bundle.dart';

/// {@template build_command}
/// `danny build` command.
/// {@endtemplate}
class BuildCommand extends DannyCommand {
  /// {@macro build_command}
  BuildCommand({super.logger});

  @override
  String get description => 'Create a build.';

  @override
  String get name => 'build';

  @override
  String get invocation => 'danny build';

  @override
  FutureOr<void> run() async {
    final project = await resolveProject(Directory.current);
    final pubspec = project.pubspec;
    final rootDir = project.rootDir;
    final name = pubspec.executables.keys.first;
    final runnerFile = File(p.join(rootDir.path, 'runner.dart'));

    final commandConfigs = parseCommandConfigs(rootDir);

    final duplicates = commandConfigs.duplicates();
    if (duplicates.isNotEmpty) {
      throw DannyException(
        [
          'Duplicate command(s):',
          '',
          for (final duplicate in duplicates) ...[
            '"$duplicate"',
          ],
        ].join('\n'),
      );
    }

    final runnerFileLines = runnerFile.readAsLinesSync();
    await mason.generate(
      bundle: commandRunnerBundle,
      target: rootDir,
      vars: <String, dynamic>{
        'name': name,
        'commands': commandConfigs.map((e) => e.toJson()).toList(),
        'hasBranchCommand': commandConfigs.any((e) => e is BranchCommandConfig),
        'hasCommandWithArgParser': commandConfigs.leafs().any(
              (e) => e.hasCustomArgParser,
            ),
        'hasUsageLineLength': runnerFileLines.any(
          (e) =>
              e.startsWith('dynamic usageLineLength') ||
              e.startsWith('int usageLineLength') ||
              e.startsWith('int? usageLineLength') ||
              e.startsWith('final dynamic usageLineLength') ||
              e.startsWith('final int usageLineLength') ||
              e.startsWith('final int? usageLineLength') ||
              e.startsWith('const dynamic usageLineLength') ||
              e.startsWith('const int usageLineLength') ||
              e.startsWith('const int? usageLineLength') ||
              e.startsWith('final usageLineLength') ||
              e.startsWith('var usageLineLength') ||
              e.startsWith('const usageLineLength') ||
              e.startsWith('dynamic get usageLineLength') ||
              e.startsWith('int get usageLineLength') ||
              e.startsWith('int? get usageLineLength'),
        ),
        'hasSuggestionDistanceLimit': runnerFileLines.any(
          (e) =>
              e.startsWith('dynamic suggestionDistanceLimit') ||
              e.startsWith('int suggestionDistanceLimit') ||
              e.startsWith('final dynamic suggestionDistanceLimit') ||
              e.startsWith('final int suggestionDistanceLimit') ||
              e.startsWith('const dynamic suggestionDistanceLimit') ||
              e.startsWith('const int suggestionDistanceLimit') ||
              e.startsWith('final suggestionDistanceLimit') ||
              e.startsWith('var suggestionDistanceLimit') ||
              e.startsWith('const suggestionDistanceLimit') ||
              e.startsWith('dynamic get suggestionDistanceLimit') ||
              e.startsWith('int get suggestionDistanceLimit'),
        ),
        'hasRun': runnerFileLines.any(
          (e) =>
              e.startsWith('Future<Type> run(') ||
              e.startsWith('Future<Type?> run('),
        ),
        'hasRunCommand': runnerFileLines.any(
          (e) =>
              e.startsWith('Future<Type> runCommand(') ||
              e.startsWith('Future<Type?> runCommand('),
        ),
      },
    );

    await process.run(dartPubGetCommand(), workingDirectory: rootDir.path);
    await process.run(dartFormatFix(), workingDirectory: rootDir.path);

    logger
      ..success(
        'Build completed!',
        style: AnsiStyles.green.bold.call,
      )
      ..info('')
      ..info('To activate the executable locally run:')
      ..info('')
      ..info('  danny activate')
      ..info('');
  }
}
