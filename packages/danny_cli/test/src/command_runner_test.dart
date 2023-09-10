import 'package:danny_cli/src/command_runner.dart';
import 'package:danny_cli/src/logging.dart';
import 'package:danny_cli/src/version.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../matchers.dart';
import '../mocks.dart';
import '../utils.dart';

const expectedUsage = [
  'A Command-Line Interface to develop wilde command-line apps.',
  '',
  'Usage: danny <command>',
  '',
  'Global options:',
  '-h, --help       Print this usage information.',
  '-v, --version    Print the current version.',
  '    --verbose    Enable verbose logging.',
  '',
  'Available commands:',
  '  activate   Activate a build locally.',
  '  build      Create a build.',
  '  create     Create a wilde project.',
  '  list       List the commands of a project.',
  '  new        Create a new command.',
  '',
  'Run "danny help <command>" for more information about a command.',
];

void main() {
  group('DannyCommandRunner', () {
    late Logger logger;
    late DannyCommandRunner commandRunner;

    setUp(() {
      logger = MockLogger();
      commandRunner = DannyCommandRunner(
        logger: logger,
      );
    });

    test(
      'help',
      overridePrint((printLogs) async {
        await commandRunner.run(['--help']);
        expect(printLogs, equals(expectedUsage));

        printLogs.clear();

        await commandRunner.run(['-h']);
        expect(printLogs, equals(expectedUsage));
      }),
    );

    group('run', () {
      test('shows usage when invalid option is passed', () async {
        expect(
          commandRunner.run(['--invalid-option']),
          throwsUsageException(
            message: 'Could not find an option named "invalid-option".',
          ),
        );
      });

      test(
        'handles no command',
        overridePrint((printLogs) async {
          await commandRunner.run([]);
          expect(printLogs, equals(expectedUsage));
        }),
      );

      group('--verbose', () {
        test(
          'sets correct log level.',
          overridePrint((printLogs) async {
            await commandRunner.run(['--verbose']);
            verify(() => logger.level = Level.verbose).called(1);
          }),
        );

        test(
          'outputs correct meta info',
          overridePrint((printLogs) async {
            await commandRunner.run(['--verbose']);
            verify(
              () => logger.detail('[meta] danny_cli $packageVersion'),
            ).called(1);
          }),
        );
      });

      group('--version', () {
        test('outputs current version', () async {
          await commandRunner.run(['--version']);
          verify(() => logger.info(packageVersion)).called(1);
        });
      });
    });
  });
}
