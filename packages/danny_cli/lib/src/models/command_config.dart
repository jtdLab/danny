import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// {@template command_config}
/// The configuration of a command.
/// {@endtemplate}
@immutable
sealed class CommandConfig {
  /// {@macro command_config}
  const CommandConfig({
    required this.name,
    required this.path,
    required this.isBranch,
  });

  /// The name of the command
  final String name;

  /// The path of the command. Empty if root.
  final String path;

  /// Whether the command is a branch command.
  final bool isBranch;

  /// Converts a [CommandConfig] to a Map<String, dynamic>
  Map<String, dynamic> toJson();

  @override
  String toString() => toJson().toString();
}

/// {@template branch_command_config}
/// The configuration of a branch command.
/// {@endtemplate}
class BranchCommandConfig extends CommandConfig {
  /// {@macro branch_command_config}
  const BranchCommandConfig({
    required super.name,
    required super.path,
    required this.subCommands,
  }) : super(isBranch: true);

  /// The subcommands of this branch.
  final List<CommandConfig> subCommands;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'isBranch': isBranch,
      'subCommands': subCommands.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is BranchCommandConfig &&
        other.name == name &&
        other.path == path &&
        other.isBranch == isBranch &&
        listEquals(other.subCommands, subCommands);
  }

  @override
  int get hashCode => Object.hash(name, path, isBranch, subCommands);
}

/// {@template leaf_command_config}
/// The configuration of a leaf command.
/// {@endtemplate}
class LeafCommandConfig extends CommandConfig {
  /// {@macro leaf_command_config}
  const LeafCommandConfig({
    required super.name,
    required super.path,
    required this.hasCustomCategory,
    required this.hasCustomInvocation,
    required this.hasCustomUsageFooter,
    required this.hasCustomArgParser,
  }) : super(isBranch: false);

  /// Whether a custom category was specified.
  final bool hasCustomCategory;

  /// Whether a custom invocation was specified.
  final bool hasCustomInvocation;

  /// Whether a custom usage footer was specified.
  final bool hasCustomUsageFooter;

  /// Whether a custom arg parser was specified.
  final bool hasCustomArgParser;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'isBranch': isBranch,
      'hasCustomCategory': hasCustomCategory,
      'hasCustomInvocation': hasCustomInvocation,
      'hasCustomUsageFooter': hasCustomUsageFooter,
      'hasCustomArgParser': hasCustomArgParser,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LeafCommandConfig &&
        other.name == name &&
        other.path == path &&
        other.isBranch == isBranch &&
        other.hasCustomCategory == hasCustomCategory &&
        other.hasCustomInvocation == hasCustomInvocation &&
        other.hasCustomUsageFooter == hasCustomUsageFooter &&
        other.hasCustomArgParser == hasCustomArgParser;
  }

  @override
  int get hashCode => Object.hash(
        name,
        path,
        isBranch,
        hasCustomCategory,
        hasCustomInvocation,
        hasCustomUsageFooter,
        hasCustomArgParser,
      );
}
