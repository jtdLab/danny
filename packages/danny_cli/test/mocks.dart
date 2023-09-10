import 'dart:io';

import 'package:args/args.dart';
import 'package:danny_cli/src/logging.dart';
import 'package:danny_cli/src/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:process/process.dart';

class MockArgResults extends Mock implements ArgResults {}

class MockMasonGenerator extends Mock implements MasonGenerator {
  MockMasonGenerator() {
    when(
      () => this.generate(
        any(),
        vars: any(named: 'vars'),
        fileConflictResolution: FileConflictResolution.overwrite,
      ),
    ).thenAnswer((_) async => []);
  }
}

// ignore: one_member_abstracts
abstract class _MasonGeneratorBuilder {
  Future<MasonGenerator> call(MasonBundle bundle);
}

class MockMasonGeneratorBuilder extends Mock
    implements _MasonGeneratorBuilder {}

class MockLogger extends Mock implements Logger {}

class MockProcessManager extends Mock implements ProcessManager {
  MockProcessManager() {
    when(
      () => run(
        any(),
        workingDirectory: any(named: 'workingDirectory'),
        environment: any(named: 'environment'),
        includeParentEnvironment: any(named: 'includeParentEnvironment'),
        runInShell: any(named: 'runInShell'),
        stdoutEncoding: any(named: 'stdoutEncoding'),
        stderrEncoding: any(named: 'stderrEncoding'),
      ),
    ).thenAnswer((_) async => ProcessResult(0, 0, 'stdout', 'stderr'));
  }
}

class FakeDirectoryGeneratorTarget extends Fake
    implements DirectoryGeneratorTarget {}

class FakeMasonBundle extends Fake implements MasonBundle {}
