import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubspec/pubspec.dart';

import 'exception.dart';
import 'models/command_config.dart';

/// Gets the terminal width for the current environment.
int get terminalWidth {
  return stdout.hasTerminal ? stdout.terminalColumns : 80;
}

/// The `dart pub get` command.
List<String> dartPubGetCommand() => ['dart', 'pub', 'get'];

/// The `dart format <path> --fix` command.
List<String> dartFormatFix({String path = '.'}) =>
    ['dart', 'format', path, '--fix'];

/// The `dart pub global activate --source path <path>` command.
List<String> dartPubGlobalActivateSourcePath({String path = '.'}) => [
      'dart',
      'pub',
      'global',
      'activate',
      '--source',
      'path',
      path,
    ];

/// Resolves the project at [dir].
///
/// This recursivly looks up in parent directory if no `pubspec.yaml` is found
/// in current directory.
Future<({Directory rootDir, PubSpec pubspec})> resolveProject(
  Directory dir,
) async {
  File? findPubspec(Directory start) {
    final pubspec = File(p.join(start.path, 'pubspec.yaml'));
    if (pubspec.existsSync()) {
      return pubspec;
    } else {
      final parent = start.parent;
      return parent.path == start.path ? null : findPubspec(parent);
    }
  }

  final pubspecFile = findPubspec(Directory.current);
  if (pubspecFile == null) {
    throw DannyException('Could not find a pubspec.yaml.');
  }

  late final PubSpec pubspec;
  try {
    pubspec = await PubSpec.loadFile(pubspecFile.path);
  } catch (_) {
    throw DannyException('Could not parse pubspec.yaml.');
  }

  if (pubspec.executables.isEmpty) {
    throw DannyException(
      'Missing executable in pubspec.yaml. '
      'Did you forget to register it? '
      ' '
      'executables: '
      '  foo:',
    );
  }
  if (pubspec.executables.length > 1) {
    throw DannyException('Multiple executables in pubspec.yaml.');
  }

  final rootDir = pubspecFile.parent;
  final commandsDir = Directory(p.join(rootDir.path, 'commands'));
  if (!commandsDir.existsSync()) {
    throw DannyException(
      'No "commands" directory found. '
      'Make sure to run this command on a danny project.',
    );
  }

  return (rootDir: rootDir, pubspec: pubspec);
}

/// Returns a list of [CommandConfig] based on sub-directories and files in `/commands` directory
/// inside [rootDir].
///
/// A `.dart` file is parsed to a [LeafCommandConfig].
///
/// If the file contains a custom ArgParser definition either via
/// `final argParser` or `ArgParser get argParser` `hasCustomArgParser` is set
/// to `true`.
///
/// Required [BranchCommandConfig]s are parsed from parent directories of the
/// leafs.
///
/// Summary:
///
/// ```dart
/// // friendly/hello.dart
/// const description = 'Share a friendly hello.';
///
/// final argParser = ArgParser()
///   ..addOption(
///     'name',
///     defaultsTo: 'Jonas',
///   );
///
/// FutureOr<Type> run(ArgResults argResults) async {
///   final name = argResults['name'] as String;
///
///   print('Hello $name :)');
/// }
/// ```
///
/// Results in:
///
/// ```dart
/// BranchCommandConfig(
///   name: 'friendly',
///   path: '',
///   subCommands: [
///     LeafCommandConfig(
///       name: 'hello',
///       path: 'friendly',
///       hasCustomArgParser: true,
///     ),
///   ],
/// );
/// ```
List<CommandConfig> parseCommandConfigs(Directory rootDir) {
  final commandsDir = Directory(p.join(rootDir.path, 'commands'));

  final commandFiles = commandsDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((e) => e.path.endsWith('.dart'));

  final leafConfigs = <CommandConfig>[];
  for (final commandFile in commandFiles) {
    final path = normalize(
      p.dirname(p.relative(commandFile.path, from: commandsDir.path)),
    );

    final commandFileLines = commandFile.readAsLinesSync();
    leafConfigs.add(
      LeafCommandConfig(
        name: normalize(p.basenameWithoutExtension(commandFile.path)),
        path: path == '.' ? '' : path,
        hasCustomCategory: commandFileLines.any(
          (e) =>
              e.startsWith('dynamic category') ||
              e.startsWith('String category') ||
              e.startsWith('final dynamic category') ||
              e.startsWith('final String category') ||
              e.startsWith('const dynamic category') ||
              e.startsWith('const String category') ||
              e.startsWith('final category') ||
              e.startsWith('var category') ||
              e.startsWith('const category') ||
              e.startsWith('dynamic get category') ||
              e.startsWith('String get category'),
        ),
        hasCustomInvocation: commandFileLines.any(
          (e) =>
              e.startsWith('dynamic invocation') ||
              e.startsWith('String invocation') ||
              e.startsWith('final dynamic invocation') ||
              e.startsWith('final String invocation') ||
              e.startsWith('const dynamic invocation') ||
              e.startsWith('const String invocation') ||
              e.startsWith('final invocation') ||
              e.startsWith('var invocation') ||
              e.startsWith('const invocation') ||
              e.startsWith('dynamic get invocation') ||
              e.startsWith('String get invocation'),
        ),
        hasCustomUsageFooter: commandFileLines.any(
          (e) =>
              e.startsWith('dynamic usageFooter') ||
              e.startsWith('String usageFooter') ||
              e.startsWith('String? usageFooter') ||
              e.startsWith('final dynamic usageFooter') ||
              e.startsWith('final String usageFooter') ||
              e.startsWith('final String? usageFooter') ||
              e.startsWith('const dynamic usageFooter') ||
              e.startsWith('const String usageFooter') ||
              e.startsWith('const String? usageFooter') ||
              e.startsWith('final usageFooter') ||
              e.startsWith('var usageFooter') ||
              e.startsWith('const usageFooter') ||
              e.startsWith('dynamic get usageFooter') ||
              e.startsWith('String get usageFooter') ||
              e.startsWith('String? get usageFooter'),
        ),
        hasCustomArgParser: commandFileLines.any(
          (e) =>
              e.startsWith('dynamic argParser') ||
              e.startsWith('ArgParser argParser') ||
              e.startsWith('final dynamic argParser') ||
              e.startsWith('final ArgParser argParser') ||
              e.startsWith('final argParser') ||
              e.startsWith('var argParser') ||
              e.startsWith('dynamic get argParser') ||
              e.startsWith('ArgParser get argParser'),
        ),
      ),
    );
  }

  final result = <CommandConfig>[];
  for (final leafConfig in leafConfigs) {
    if (leafConfig.path == '') {
      result.add(leafConfig);
    } else {
      BranchCommandConfig? currentBranch;
      final segments = leafConfig.path.split('/');

      for (var i = 0; i < segments.length; i++) {
        final path = segments.take(i).join('/');
        final name = segments[i];

        if (currentBranch == null) {
          try {
            currentBranch = result.firstWhere(
              (e) => e.isBranch && e.path == path && e.name == name,
            ) as BranchCommandConfig;
          } catch (_) {
            currentBranch = BranchCommandConfig(
              name: name,
              path: path,
              subCommands: List.empty(growable: true),
            );
            result.add(currentBranch);
          }
        } else {
          try {
            currentBranch = currentBranch.subCommands.firstWhere(
              (e) => e.isBranch && e.path == path && e.name == name,
            ) as BranchCommandConfig;
          } catch (_) {
            final newBranch = BranchCommandConfig(
              name: name,
              path: path,
              subCommands: List.empty(growable: true),
            );
            currentBranch!.subCommands.add(newBranch);
            currentBranch = newBranch;
          }
        }
      }

      currentBranch!.subCommands.add(leafConfig);
    }
  }

  return result;
}

/// Utils for a list of [CommandConfig].
extension CommandConfigListUtils on List<CommandConfig> {
  /// Returns all leafs and branches of this as a flat list.
  List<CommandConfig> flatten() {
    final result = <CommandConfig>[];

    for (final config in this) {
      result.add(config);
      if (config is BranchCommandConfig) {
        result.addAll(config.subCommands.flatten());
      }
    }

    return result;
  }

  /// Returns a flat list of all [LeafCommandConfig]s inside this.
  List<LeafCommandConfig> leafs() =>
      flatten().whereType<LeafCommandConfig>().toList();

  /// Returns this without [config].
  List<CommandConfig> without(CommandConfig config) =>
      List<CommandConfig>.from(this)..remove(config);

  /// Returns a list of commands that have same path and name.
  ///
  /// a/b.dart and a/b/c.dart leads to this returning ["a b"].
  Set<String> duplicates() {
    final result = <String>{};

    final flattened = flatten();
    for (final config in flattened) {
      final others = flattened.without(config);
      if (others.any((e) => e.path == config.path && e.name == config.name)) {
        result.add(config.spaced);
        continue;
      }
    }

    return result;
  }
}

/// Normalizes [path] to posix style.
String normalize(String path) =>
    path.replaceAll(r'C:\', '/').replaceAll(r'\', '/');

/// The regex for a dart package name, i.e. no capital letters.
/// https://dart.dev/guides/language/language-tour#important-concepts
final dartPackageRegExp = RegExp('[a-z_][a-z0-9_]*');

/// Adds utility to [String]s.
extension StringUtils on String {
  /// Whether this is a valid dart package name.
  bool get isValidDartPackageName {
    final match = dartPackageRegExp.matchAsPrefix(this);
    return match != null && match.end == length;
  }
}

/// Adds utility to [CommandConfig]s.
extension CommandConfigUtils on CommandConfig {
  /// The "spaced" string representation of this config.
  ///
  /// path=a/b name=c => spaced='a b c'
  String get spaced =>
      [...path.split('/'), name].where((e) => e.isNotEmpty).join(' ');
}
