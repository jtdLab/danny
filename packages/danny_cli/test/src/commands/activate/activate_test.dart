import 'dart:io';

import 'package:args/args.dart';
import 'package:danny_cli/src/command_runner.dart';
import 'package:danny_cli/src/commands/commands.dart';
import 'package:danny_cli/src/logging.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../matchers.dart';
import '../../../mock_env.dart';
import '../../../mocks.dart';
import '../../../utils.dart';

const expectedUsage = [
  'Activate a build locally.',
  '',
  'Usage: danny activate',
  '-h, --help    Print this usage information.',
  '',
  'Run "danny help" to see global options.',
];

void main() {
  group('danny activate', () {
    late Logger logger;
    late ActivateCommand command;
    late ArgResults argResults;

    setUp(() {
      logger = MockLogger();
      argResults = MockArgResults();
      command = ActivateCommand(logger: logger)
        ..argResultOverrides = argResults;
    });

    test(
      'help',
      overridePrint((printLogs) async {
        final commandRunner = DannyCommandRunner();

        await commandRunner.run(['activate', '--help']);
        expect(printLogs, equals(expectedUsage));

        printLogs.clear();

        await commandRunner.run(['activate', '-h']);
        expect(printLogs, equals(expectedUsage));
      }),
    );

    test(
      'throws when "dart pub get" fails',
      withMockEnv((manager) async {
        await createProject();
        when(
          () => manager.run(
            [
              'dart',
              'pub',
              'get',
            ],
            workingDirectory: any(named: 'workingDirectory'),
            runInShell: true,
          ),
        ).thenAnswer((_) async => ProcessResult(0, 1, 'stdout', 'stderr'));

        await expectLater(
          () => command.run(),
          throwsDannyException(
            message: 'Failed to activate!\n'
                '\n'
                'stdout\n'
                '\n'
                'stderr',
          ),
        );
      }),
    );

    test(
      'throws when "dart pub global activate" fails.',
      withMockEnv((manager) async {
        await createProject();
        when(
          () => manager.run(
            [
              'dart',
              'pub',
              'global',
              'activate',
              '--source',
              'path',
              '.',
            ],
            workingDirectory: any(named: 'workingDirectory'),
            runInShell: true,
          ),
        ).thenAnswer((_) async => ProcessResult(0, 1, 'stdout', 'stderr'));

        await expectLater(
          () => command.run(),
          throwsDannyException(
            message: 'Failed to activate!\n'
                '\n'
                'stdout\n'
                '\n'
                'stderr',
          ),
        );
      }),
    );

    test(
      'activates a build successfully.',
      withMockFs(
        withMockEnv((manager) async {
          await createProject();

          await command.run();

          final rootPath = switch (Platform.isWindows) {
            true => r'C:\',
            false => '/',
          };
          expect(Directory('.dart_tool').existsSync(), false);
          expect(File('pubspec.lock').existsSync(), false);
          verifyInOrder([
            () => manager.run(
                  [
                    'dart',
                    'pub',
                    'get',
                  ],
                  workingDirectory: rootPath,
                  runInShell: true,
                ),
            () => manager.run(
                  [
                    'dart',
                    'pub',
                    'global',
                    'activate',
                    '--source',
                    'path',
                    '.',
                  ],
                  workingDirectory: rootPath,
                  runInShell: true,
                ),
            () => logger.success(
                  'Activated successfully!',
                  style: any(named: 'style'),
                ),
            () => logger.info(''),
            () => logger.info('To use the new CLI run:'),
            () => logger.info(''),
            () => logger.info('  $defaultProjectName --help'),
            () => logger.info(''),
          ]);
        }),
      ),
    );
  });
}
