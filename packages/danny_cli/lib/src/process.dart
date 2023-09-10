import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:process/process.dart';

/// Used inside tests to stubb the current zones [ProcessManager] instance.
///
/// For example:
///
/// ```dart
/// runZoned(
///   () {
///     // code
///   },
///   zoneValues: {
///     processManagerZoneKey: MockProcessManager(),
///   },
/// );
/// ```
@visibleForTesting
const processManagerZoneKey = #processManager;

ProcessManager get _processManager =>
    Zone.current[processManagerZoneKey] as ProcessManager? ??
    const LocalProcessManager();

/// Runs [command] in [workingDirectory].
///
/// Should be used in place of `dart:io`'s [Process.run].
Future<ProcessResult> run(
  List<String> command, {
  String? workingDirectory,
}) =>
    _processManager.run(
      command,
      workingDirectory: workingDirectory,
      runInShell: true,
    );
