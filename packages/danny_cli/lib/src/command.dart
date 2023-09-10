import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:meta/meta.dart';

import 'logging.dart';

/// {@template danny_command}
/// The base class for all danny commands.
/// {@endtemplate}
abstract class DannyCommand extends Command<void> {
  /// {@macro danny_command}
  DannyCommand({Logger? logger}) : logger = logger ?? Logger();

  /// [ArgResults] which can be overriden for testing.
  @visibleForTesting
  ArgResults? argResultOverrides;

  /// [ArgResults] for this command.
  @override
  ArgResults get argResults => argResultOverrides ?? super.argResults!;

  /// [Logger] for this command.
  final Logger logger;
}
