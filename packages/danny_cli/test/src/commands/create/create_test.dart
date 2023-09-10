import 'dart:io';

import 'package:args/args.dart';
import 'package:danny_cli/src/command_runner.dart';
import 'package:danny_cli/src/commands/commands.dart';
import 'package:danny_cli/src/commands/create/templates/project_bundle.dart';
import 'package:danny_cli/src/logging.dart';
import 'package:danny_cli/src/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../matchers.dart';
import '../../../mock_env.dart';
import '../../../mocks.dart';
import '../../../utils.dart';

const expectedUsage = [
  'Create a wilde project.',
  '',
  'Usage: danny create <project-name>',
  '-h, --help           Print this usage information.',
  '-o, --output-dir     The directory where to generate the new project.',
  '                     (defaults to ".")',
  '    --description    The description passed to the CommandRunner.',
  '',
  'Run "danny help" to see global options.',
];

void main() {
  group('danny create', () {
    setUpAll(() {
      registerFallbackValue(FakeDirectoryGeneratorTarget());
      registerFallbackValue(FakeMasonBundle());
    });

    late Logger logger;
    late CreateCommand command;
    late ArgResults argResults;

    setUp(() {
      logger = MockLogger();
      argResults = MockArgResults();
      command = CreateCommand(
        logger: logger,
      )..argResultOverrides = argResults;
    });

    test(
      'help',
      overridePrint((printLogs) async {
        final commandRunner = DannyCommandRunner();

        await commandRunner.run(['create', '--help']);
        expect(printLogs, equals(expectedUsage));

        printLogs.clear();

        await commandRunner.run(['create', '-h']);
        expect(printLogs, equals(expectedUsage));
      }),
    );

    group('throws UsageException', () {
      test(
        'when project name is missing',
        overridePrint((printLogs) async {
          final commandRunner = DannyCommandRunner();
          expect(
            () => commandRunner.run(['create']),
            throwsUsageException(
              message: 'No option specified for the project name.',
            ),
          );
        }),
      );

      group('when project name is invalid', () {
        test(
          '(contains spaces)',
          overridePrint((printLogs) async {
            final commandRunner = DannyCommandRunner();
            const projectName = 'my app';

            expect(
              () => commandRunner.run(['create', projectName]),
              throwsUsageException(
                message: '"$projectName" is not a valid dart package name.\n\n'
                    'See https://dart.dev/tools/pub/pubspec#name for more information.',
              ),
            );
          }),
        );

        test(
          '(contains uppercase)',
          overridePrint((printLogs) async {
            final commandRunner = DannyCommandRunner();
            const projectName = 'My_app';

            expect(
              () => commandRunner.run(['create', projectName]),
              throwsUsageException(
                message: '"$projectName" is not a valid dart package name.\n\n'
                    'See https://dart.dev/tools/pub/pubspec#name for more information.',
              ),
            );
          }),
        );

        test(
          '(invalid characters present)',
          overridePrint((printLogs) async {
            final commandRunner = DannyCommandRunner();
            const projectName = '.-@_my_app_*';

            expect(
              () => commandRunner.run(['create', projectName]),
              throwsUsageException(
                message: '"$projectName" is not a valid dart package name.\n\n'
                    'See https://dart.dev/tools/pub/pubspec#name for more information.',
              ),
            );
          }),
        );
      });

      test(
        'when multiple project names are provided',
        overridePrint((printLogs) async {
          final commandRunner = DannyCommandRunner();
          expect(
            () => commandRunner.run(['create', 'foo', 'bar']),
            throwsUsageException(
              message: 'Multiple project names specified.',
            ),
          );
        }),
      );
    });

    test(
      'creates a project successfully.',
      withMockEnv((manager) async {
        final generator = MockMasonGenerator();
        final generatorBuilder = MockMasonGeneratorBuilder();
        when(() => generatorBuilder(any())).thenAnswer((_) async => generator);
        generatorOverrides = generatorBuilder.call;
        const outputDir = 'some/path';
        const description = 'A cool CLI';
        const projectName = 'cool';
        when(() => argResults['output-dir']).thenReturn(outputDir);
        when(() => argResults['description']).thenReturn(description);
        when(() => argResults.rest).thenReturn([projectName]);

        await command.run();

        final path = switch (Platform.isWindows) {
          true => r'C:\some\path',
          false => '/some/path',
        };
        verifyInOrder([
          () => generatorBuilder(projectBundle),
          () => generator.generate(
                any(),
                vars: <String, dynamic>{
                  'name': projectName,
                  'description': description,
                },
                fileConflictResolution: FileConflictResolution.overwrite,
              ),
          () => manager.run(
                ['dart', 'pub', 'get'],
                workingDirectory: outputDir,
                runInShell: true,
              ),
          () => logger.success(
                'Created $projectName at $path.',
                style: any(named: 'style'),
              ),
          () => logger.info(''),
          () => logger.info('To start run:'),
          () => logger.info(''),
          () => logger.info('  cd $path'),
          () => logger.info('  danny build'),
          () => logger.info('  danny activate'),
          () => logger.info('  $projectName -h'),
          () => logger.info(''),
        ]);
      }),
    );
  });
}
