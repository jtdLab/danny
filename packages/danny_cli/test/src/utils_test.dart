import 'dart:io';

import 'package:danny_cli/src/models/command_config.dart';
import 'package:danny_cli/src/utils.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../matchers.dart';
import '../mock_env.dart';
import '../utils.dart';

void main() {
  group('resolveProject', () {
    test(
      'looks up recursivly',
      withMockFs(() async {
        final dir = Directory.current.path;
        await d.file('pubspec.yaml', pubspecYaml).create(dir);
        await d.dir('commands').create(dir);
        await expectLater(
          resolveProject(Directory(p.join(dir, 'nested'))),
          completes,
        );
      }),
    );

    test(
      'throws when no pubspec.yaml is found after reaching root',
      withMockFs(() async {
        final dir = Directory.current;
        await expectLater(
          resolveProject(dir),
          throwsDannyException(message: 'Could not find a pubspec.yaml.'),
        );
      }),
    );

    test(
      'throws when the pubspec.yaml has no executables',
      withMockFs(() async {
        final dir = Directory.current;
        await d.file('pubspec.yaml', '''
name: greet_cli

environment:
  sdk: ^3.0.0

dependencies:
  args: ^2.4.2
''').create(dir.path);
        await expectLater(
          resolveProject(dir),
          throwsDannyException(
            message: 'Missing executable in pubspec.yaml. '
                'Did you forget to register it? '
                ' '
                'executables: '
                '  foo:',
          ),
        );
      }),
    );

    test(
      'throws when the pubspec.yaml has multiple executables',
      withMockFs(() async {
        final dir = Directory.current;
        await d.file('pubspec.yaml', '''
name: greet_cli

environment:
  sdk: ^3.0.0

executables:
  greet:
  cool:

dependencies:
  args: ^2.4.2
''').create(dir.path);
        await expectLater(
          resolveProject(dir),
          throwsDannyException(
            message: 'Multiple executables in pubspec.yaml.',
          ),
        );
      }),
    );

    test(
      'throws when pubspec.yaml can not be parsed',
      withMockFs(() async {
        final dir = Directory.current;
        await d.file('pubspec.yaml', '#123abc*').create(dir.path);
        await expectLater(
          resolveProject(dir),
          throwsDannyException(
            message: 'Could not parse pubspec.yaml.',
          ),
        );
      }),
    );

    test(
      'throws when commands directory is missing',
      withMockFs(() async {
        final dir = Directory.current;
        await d.file('pubspec.yaml', pubspecYaml).create(dir.path);
        await expectLater(
          resolveProject(dir),
          throwsDannyException(
            message: 'No "commands" directory found. '
                'Make sure to run this command on a danny project.',
          ),
        );
      }),
    );
  });

  group('parseCommandConfigs', () {
    test(
      'can parse deep nested commands',
      withMockFs(() async {
        final dir = Directory.current;
        await d.dir('commands', [
          d.dir('friendly', [
            d.dir('funny', [
              d.file('hello.dart', friendlyFunnyHelloDart),
              d.file('bye.dart', friendlyFunnyByeDart),
            ]),
          ]),
        ]).create(dir.path);
        expect(
          parseCommandConfigs(dir),
          [
            const BranchCommandConfig(
              name: 'friendly',
              path: '',
              subCommands: [
                BranchCommandConfig(
                  name: 'funny',
                  path: 'friendly',
                  subCommands: [
                    LeafCommandConfig(
                      name: 'hello',
                      path: 'friendly/funny',
                      hasCustomCategory: false,
                      hasCustomInvocation: true,
                      hasCustomUsageFooter: false,
                      hasCustomArgParser: true,
                    ),
                    LeafCommandConfig(
                      name: 'bye',
                      path: 'friendly/funny',
                      hasCustomCategory: true,
                      hasCustomInvocation: false,
                      hasCustomUsageFooter: true,
                      hasCustomArgParser: false,
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      }),
    );
  });
}

const friendlyFunnyHelloDart = r'''
import 'dart:async';

import 'package:args/args.dart';

import '../../../runner.dart';

const description = 'Share a friendly funny hello.';

final argParser = ArgParser()
  ..addOption(
    'name',
    defaultsTo: 'Jonas',
  );

final dynamic invocation = 'swaggy';

FutureOr<Type> run(ArgResults argResults) async {
  final name = argResults['name'] as String;

  // ignore: avoid_print
  print('Hello $name :) ._.');
}
''';

const friendlyFunnyByeDart = '''
import 'dart:async';

import 'package:args/args.dart';

import '../../../runner.dart';

const description = 'Say bye.';

const category = 'swaggy';

String get usageFooter => 'footer';

FutureOr<Type> run(ArgResults argResults) async {
  final name = argResults['name'] as String;

  // ignore: avoid_print
  print('Bye');
}
''';
