import 'dart:async';
import 'dart:io';

import 'package:ansi_styles/ansi_styles.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../command.dart';
import '../../exception.dart';
import '../../mason.dart' as mason;
import '../../utils.dart';
import 'templates/command_bundle.dart';

/// {@template new_command}
/// `danny new` command.
/// {@endtemplate}
class NewCommand extends DannyCommand {
  /// {@macro new_command}
  NewCommand({super.logger}) {
    argParser
      ..addFlag(
        'arg-parser',
        help: 'Whether the command has a custom ArgParser.',
        negatable: false,
      )
      ..addOption(
        'description',
        help: 'The description of the command.',
      );
  }

  @override
  String get description => 'Create a new command.';

  @override
  String get name => 'new';

  @override
  String get invocation => 'danny new "foo bar baz"';

  @override
  FutureOr<void> run() async {
    final segments = _validateSegments(argResults.rest);
    final name = segments.last;
    final pathSegments = segments.take(segments.length - 1);
    final argParser = argResults['arg-parser'] ?? false;
    final description = argResults['description'] ?? 'The $name command.';

    final project = await resolveProject(Directory.current);
    final rootDir = project.rootDir;

    final commandConfigs = parseCommandConfigs(rootDir);

    final flattened = commandConfigs.flatten();
    // check command that will get added or associated branches already exist
    for (var i = 0; i < segments.length; i++) {
      final subSegments = segments.take(i).toList();
      final path = subSegments.isEmpty ? '' : normalize(p.joinAll(subSegments));
      final name = segments[i];

      final index =
          flattened.indexWhere((e) => e.path == path && e.name == name);
      if (index != -1) {
        final duplicate = flattened[index];
        throw DannyException('Duplicate command: "${duplicate.spaced}".');
      }
    }

    final commandsDir = Directory(p.join(rootDir.path, 'commands'));
    final outputDir = p.joinAll([commandsDir.path, ...pathSegments]);

    await mason.generate(
      bundle: commandBundle,
      target: Directory(outputDir),
      vars: <String, dynamic>{
        'name': name,
        'pathSegments': pathSegments,
        'description': description,
        'hasCustomArgParser': argParser,
      },
    );

    logger.success(
      'Created new command "${segments.join(' ')}" at '
      '${p.join(outputDir, '$name.dart')}.',
      style: AnsiStyles.green.bold.call,
    );
  }

  List<String> _validateSegments(List<String> args) {
    if (args.isEmpty) {
      throw UsageException(
        'No option specified for the command.',
        usage,
      );
    }

    if (args.length > 1) {
      throw UsageException('Multiple commands specified.', usage);
    }

    final segmentsString = args.first;
    final segments = segmentsString.replaceAll('"', '').split(' ');

    final failedSegments = <String>[];
    for (final segment in segments) {
      if (!RegExp(r'^[a-z]+$').hasMatch(segment)) {
        failedSegments.add(segment);
      }
    }

    if (failedSegments.isNotEmpty) {
      throw UsageException(
        'Command names must only contain lowercase letters (a-z).'
        '\n'
        'But got $failedSegments.',
        usage,
      );
    }

    return segments;
  }
}
