import 'dart:async';
import 'dart:io';

import 'package:test_descriptor/test_descriptor.dart' as d;

void Function() overridePrint(void Function(List<String>) fn) {
  return () {
    final printLogs = <String>[];
    final spec = ZoneSpecification(
      print: (_, __, ___, String msg) {
        printLogs.addAll(msg.split('\n'));
      },
    );

    return Zone.current
        .fork(specification: spec)
        .run<void>(() => fn(printLogs));
  };
}

const defaultProjectName = 'greet';

/// Creates a danny project with name [defaultProjectName] and commands
/// `hello` + `friendly hello`.
Future<void> createProject() async {
  final root = Directory.current.path;
  await d.dir('commands', [
    d.file('hello.dart', helloDart),
    d.dir('friendly', [
      d.file('hello.dart', friendlyHelloDart),
    ]),
  ]).create(root);
  await d.file('pubspec.yaml', pubspecYaml).create(root);
  await d.file('runner.dart', runnerDart).create(root);
}

const pubspecYaml = '''
name: ${defaultProjectName}_cli

environment:
  sdk: ^3.0.0

executables:
  $defaultProjectName:

dependencies:
  args: ^2.4.2
''';

const runnerDart = '''
import 'dart:io';

typedef Type = void;

const description = 'A CLI to share greetings.';

int get usageLineLength {
  return stdout.hasTerminal ? stdout.terminalColumns : 80;
}

const suggestionDistanceLimit = 4;

Future<Type> run(
  Iterable<String> args,
  Future<Type> Function(Iterable<String> args) run,
) async {}

Future<Type> runCommand(
  ArgResults topLevelResults,
  Future<Type> Function(ArgResults topLevelResults) runCommand,
) async {}
''';

const helloDart = '''
import 'dart:async';

import 'package:args/args.dart';

import '../runner.dart';

const description = 'Share a hello.';

FutureOr<Type> run(ArgResults argResults) {
  // ignore: avoid_print
  print('Hello!');
}
''';

const friendlyHelloDart = r'''
import 'dart:async';

import 'package:args/args.dart';

import '../../runner.dart';

const description = 'Share a friendly hello.';

final argParser = ArgParser()
  ..addOption(
    'name',
    defaultsTo: 'Jonas',
  );

FutureOr<Type> run(ArgResults argResults) async {
  final name = argResults['name'] as String;

  // ignore: avoid_print
  print('Hello $name :)');
}
''';
