import 'dart:io';

import 'package:args/args.dart';
import 'package:danny_cli/src/command_runner.dart';
import 'package:danny_cli/src/commands/commands.dart';
import 'package:danny_cli/src/commands/new/templates/command_bundle.dart';
import 'package:danny_cli/src/logging.dart';
import 'package:danny_cli/src/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../matchers.dart';
import '../../../mock_env.dart';
import '../../../mocks.dart';
import '../../../utils.dart';

const expectedUsage = [
  'Create a new command.',
  '',
  'Usage: danny new "foo bar baz"',
  '-h, --help           Print this usage information.',
  '    --arg-parser     Whether the command has a custom ArgParser.',
  '    --description    The description of the command.',
  '',
  'Run "danny help" to see global options.',
];

void main() {
  group('danny new', () {
    setUpAll(() {
      registerFallbackValue(FakeDirectoryGeneratorTarget());
      registerFallbackValue(FakeMasonBundle());
    });

    late Logger logger;
    late NewCommand command;
    late ArgResults argResults;

    setUp(() {
      logger = MockLogger();
      argResults = MockArgResults();
      command = NewCommand(
        logger: logger,
      )..argResultOverrides = argResults;
    });

    test(
      'help',
      overridePrint((printLogs) async {
        final commandRunner = DannyCommandRunner();

        await commandRunner.run(['new', '--help']);
        expect(printLogs, equals(expectedUsage));

        printLogs.clear();

        await commandRunner.run(['new', '-h']);
        expect(printLogs, equals(expectedUsage));
      }),
    );

    group('throws UsageException', () {
      test(
        'when command is missing',
        overridePrint((printLogs) async {
          final commandRunner = DannyCommandRunner();
          expect(
            () => commandRunner.run(['new']),
            throwsUsageException(
              message: 'No option specified for the command.',
            ),
          );
        }),
      );

      test(
        'when command names are invalid',
        overridePrint((printLogs) async {
          final commandRunner = DannyCommandRunner();
          expect(
            () => commandRunner.run(['new', '"+-+32!@ a_b c-d e:f"']),
            throwsUsageException(
              message:
                  'Command names must only contain lowercase letters (a-z).'
                  '\n'
                  'But got [+-+32!@, a_b, c-d, e:f].',
            ),
          );
        }),
      );

      test(
        'when multiple commands are provided',
        overridePrint((printLogs) async {
          final commandRunner = DannyCommandRunner();
          expect(
            () => commandRunner.run(['new', '"a"', '"b"']),
            throwsUsageException(
              message: 'Multiple commands specified.',
            ),
          );
        }),
      );
    });

    test(
      'throws DannyException when new command would lead to duplicate '
      'command at run-time (leaf)',
      withMockFs(() async {
        await createProject();
        when(() => argResults.rest).thenReturn(['"friendly"']);
        await expectLater(
          command.run,
          throwsDannyException(
            message: 'Duplicate command: "friendly".',
          ),
        );
      }),
    );

    test(
      'throws DannyException when new command would lead to duplicate '
      'command at run-time (branch)',
      withMockFs(() async {
        await createProject();
        when(() => argResults.rest).thenReturn(['"hello foo"']);
        await expectLater(
          command.run,
          throwsDannyException(
            message: 'Duplicate command: "hello".',
          ),
        );
      }),
    );

    test(
      'creates a new command successfully.',
      withMockFs(() async {
        final generator = MockMasonGenerator();
        final generatorBuilder = MockMasonGeneratorBuilder();
        when(() => generatorBuilder(any())).thenAnswer((_) async => generator);
        generatorOverrides = generatorBuilder.call;
        await createProject();
        const description = 'Some description.';
        when(() => argResults['description']).thenReturn(description);
        when(() => argResults['arg-parser']).thenReturn(true);
        when(() => argResults.rest).thenReturn(['"foo bar baz"']);

        await command.run();

        final path = switch (Platform.isWindows) {
          true => r'C:\commands\foo\bar\baz.dart',
          false => '/commands/foo/bar/baz.dart',
        };
        verifyInOrder([
          () => generatorBuilder(commandBundle),
          () => generator.generate(
                any(),
                vars: <String, dynamic>{
                  'name': 'baz',
                  'pathSegments': ['foo', 'bar'],
                  'description': description,
                  'hasCustomArgParser': true,
                },
                fileConflictResolution: FileConflictResolution.overwrite,
              ),
          () => logger.success(
                'Created new command "foo bar baz" at $path.',
                style: any(named: 'style'),
              ),
        ]);
      }),
    );
  });
}
