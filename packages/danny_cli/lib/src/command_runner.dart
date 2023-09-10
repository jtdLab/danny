import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import 'commands/activate/activate.dart';
import 'commands/build/build.dart';
import 'commands/create/create.dart';
import 'commands/list/list.dart';
import 'commands/new/new.dart';
import 'logging.dart';
import 'utils.dart';
import 'version.dart';

/// The package name.
const packageName = 'danny_cli';

/// The executable name.
const executableName = 'danny';

/// {@template danny_command_runner}
/// A [CommandRunner] for the Danny CLI.
/// {@endtemplate}
class DannyCommandRunner extends CommandRunner<void> {
  /// {@macro danny_command_runner}
  DannyCommandRunner({
    Logger? logger,
  })  : _logger = logger ?? Logger(),
        super(
          executableName,
          'A Command-Line Interface to develop wilde command-line apps.',
          usageLineLength: terminalWidth,
        ) {
    argParser
      ..addFlag(
        'version',
        abbr: 'v',
        help: 'Print the current version.',
        negatable: false,
      )
      ..addFlag(
        'verbose',
        help: 'Enable verbose logging.',
        negatable: false,
      );

    addCommand(ActivateCommand(logger: _logger));
    addCommand(BuildCommand(logger: _logger));
    addCommand(CreateCommand(logger: _logger));
    addCommand(ListCommand(logger: _logger));
    addCommand(NewCommand(logger: _logger));
  }

  final Logger _logger;

  @override
  String get invocation => 'danny <command>';

  @override
  Future<void> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults['version'] == true) {
      _logger.info(packageVersion);
      return;
    }
    if (topLevelResults['verbose'] == true) {
      _logger.level = Level.verbose;
    }

    _logger.detail('[meta] $packageName $packageVersion');
    return super.runCommand(topLevelResults);
  }
}
