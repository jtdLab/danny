import 'dart:io';

import 'package:mason/mason.dart';
import 'package:meta/meta.dart';

export 'package:mason/mason.dart' hide Logger, Progress;

/// Function that builds a [MasonGenerator] from a [MasonBundle] which can
/// be overriden for testing.
@visibleForTesting
Future<MasonGenerator> Function(MasonBundle)? generatorOverrides;

/// Generates files specified in [bundle] based on the provided
/// [target] and [vars].
///
/// Returns the generated files.
Future<List<GeneratedFile>> generate({
  required MasonBundle bundle,
  required Directory target,
  Map<String, dynamic> vars = const <String, dynamic>{},
}) async {
  final generator =
      await (generatorOverrides ?? MasonGenerator.fromBundle)(bundle);
  return generator.generate(
    DirectoryGeneratorTarget(target),
    vars: vars,
    fileConflictResolution: FileConflictResolution.overwrite,
  );
}
