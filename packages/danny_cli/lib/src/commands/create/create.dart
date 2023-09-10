import 'dart:async';
import 'dart:io';

import 'package:ansi_styles/ansi_styles.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../command.dart';
import '../../mason.dart' as mason;
import '../../process.dart' as process;
import '../../utils.dart';
import 'templates/project_bundle.dart';

/// {@template create_command}
/// `danny create` command.
/// {@endtemplate}
class CreateCommand extends DannyCommand {
  /// {@macro create_command}
  CreateCommand({super.logger}) {
    argParser
      ..addOption(
        'output-dir',
        abbr: 'o',
        help: 'The directory where to generate the new project.',
        defaultsTo: '.',
      )
      ..addOption(
        'description',
        help: 'The description passed to the CommandRunner.',
      );
  }

  @override
  String get description => 'Create a wilde project.';

  @override
  String get name => 'create';

  @override
  String get invocation => 'danny create <project-name>';

  @override
  FutureOr<void> run() async {
    final outputDir = argResults['output-dir'] as String;
    final projectName = _validateProjectName(argResults.rest);
    final description = argResults['description'] ?? 'The $name CLI.';

    await mason.generate(
      bundle: projectBundle,
      target: Directory(outputDir),
      vars: <String, dynamic>{
        'name': projectName,
        'description': description,
      },
    );

    await process.run(dartPubGetCommand(), workingDirectory: outputDir);

    final outputDirAbsolute = p.normalize(Directory(outputDir).absolute.path);
    logger
      ..success(
        'Created $projectName at $outputDirAbsolute.',
        style: AnsiStyles.green.bold.call,
      )
      ..info('')
      ..info('To start run:')
      ..info('')
      ..info('  cd $outputDirAbsolute')
      ..info('  danny build')
      ..info('  danny activate')
      ..info('  $projectName -h')
      ..info('');
  }

  String _validateProjectName(List<String> args) {
    if (args.isEmpty) {
      throw UsageException(
        'No option specified for the project name.',
        usage,
      );
    }

    if (args.length > 1) {
      throw UsageException('Multiple project names specified.', usage);
    }

    final name = args.first;
    if (!name.isValidDartPackageName) {
      throw UsageException(
        '"$name" is not a valid dart package name.\n\n'
        'See https://dart.dev/tools/pub/pubspec#name for more information.',
        usage,
      );
    }

    return name;
  }
}
