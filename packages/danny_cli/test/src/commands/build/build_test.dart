import 'dart:io';

import 'package:args/args.dart';
import 'package:danny_cli/src/command_runner.dart';
import 'package:danny_cli/src/commands/build/templates/command_runner_bundle.dart';
import 'package:danny_cli/src/commands/commands.dart';
import 'package:danny_cli/src/logging.dart';
import 'package:danny_cli/src/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../../../matchers.dart';
import '../../../mock_env.dart';
import '../../../mocks.dart';
import '../../../utils.dart';

const expectedUsage = [
  'Create a build.',
  '',
  'Usage: danny build',
  '-h, --help    Print this usage information.',
  '',
  'Run "danny help" to see global options.',
];

void main() {
  group('danny build', () {
    setUpAll(() {
      registerFallbackValue(FakeDirectoryGeneratorTarget());
      registerFallbackValue(FakeMasonBundle());
    });

    late Logger logger;
    late BuildCommand command;
    late ArgResults argResults;

    setUp(() {
      logger = MockLogger();
      argResults = MockArgResults();
      command = BuildCommand(
        logger: logger,
      )..argResultOverrides = argResults;
    });

    test(
      'help',
      overridePrint((printLogs) async {
        final commandRunner = DannyCommandRunner();

        await commandRunner.run(['build', '--help']);
        expect(printLogs, equals(expectedUsage));

        printLogs.clear();

        await commandRunner.run(['build', '-h']);
        expect(printLogs, equals(expectedUsage));
      }),
    );

    test(
      'throws DannyException when any command exists that would lead to '
      'duplicate command at run-time',
      withMockFs(
        () async {
          final root = Directory.current.path;
          await d.dir('commands', [
            d.file('friendly.dart', friendlyDart),
            d.dir('friendly', [
              d.file('hello.dart', friendlyHelloDart),
            ]),
          ]).create(root);
          await d.file('pubspec.yaml', pubspecYaml).create(root);
          await d.file('runner.dart', runnerDart).create(root);

          await expectLater(
            command.run,
            throwsDannyException(
              message: [
                'Duplicate command(s):',
                '',
                '"friendly"',
              ].join('\n'),
            ),
          );
        },
      ),
    );

    test(
      'generates a build successfully.',
      withMockEnv((manager) async {
        final generator = MockMasonGenerator();
        final generatorBuilder = MockMasonGeneratorBuilder();
        when(() => generatorBuilder(any())).thenAnswer((_) async => generator);
        generatorOverrides = generatorBuilder.call;
        await createProject();

        await command.run();

        final rootPath = switch (Platform.isWindows) {
          true => r'C:\',
          false => '/',
        };
        verifyInOrder([
          () => generatorBuilder(commandRunnerBundle),
          () => generator.generate(
                any(),
                vars: <String, dynamic>{
                  'name': defaultProjectName,
                  'commands': [
                    {
                      'name': 'hello',
                      'path': '',
                      'isBranch': false,
                      'hasCustomCategory': false,
                      'hasCustomInvocation': false,
                      'hasCustomUsageFooter': false,
                      'hasCustomArgParser': false,
                    },
                    {
                      'name': 'friendly',
                      'path': '',
                      'isBranch': true,
                      'subCommands': [
                        {
                          'name': 'hello',
                          'path': 'friendly',
                          'isBranch': false,
                          'hasCustomCategory': false,
                          'hasCustomInvocation': false,
                          'hasCustomUsageFooter': false,
                          'hasCustomArgParser': true,
                        },
                      ],
                    },
                  ],
                  'hasBranchCommand': true,
                  'hasCommandWithArgParser': true,
                  'hasUsageLineLength': true,
                  'hasSuggestionDistanceLimit': true,
                  'hasRun': true,
                  'hasRunCommand': true,
                },
                fileConflictResolution: FileConflictResolution.overwrite,
              ),
          () => manager.run(
                ['dart', 'pub', 'get'],
                workingDirectory: rootPath,
                runInShell: true,
              ),
          () => manager.run(
                ['dart', 'format', '.', '--fix'],
                workingDirectory: rootPath,
                runInShell: true,
              ),
          () => logger.success(
                'Build completed!',
                style: any(named: 'style'),
              ),
          () => logger.info(''),
          () => logger.info('To activate the executable locally run:'),
          () => logger.info(''),
          () => logger.info('  danny activate'),
          () => logger.info(''),
        ]);
      }),
    );
  });
}

const friendlyDart = '''
import 'dart:async';

import 'package:args/args.dart';

import '../runner.dart';

const description = 'Be friendly.';

FutureOr<Type> run(ArgResults argResults) {
  // ignore: avoid_print
  print(':)');
}
''';
