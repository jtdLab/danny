// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal

import 'dart:async';
{{^hasUsageLineLength}}import 'dart:io';{{/hasUsageLineLength}}

{{#hasCommandWithArgParser}}{{#hasRunCommand}}import 'package:args/args.dart';{{/hasRunCommand}}{{/hasCommandWithArgParser}}{{^hasCommandWithArgParser}}{{#hasRunCommand}}import 'package:args/args.dart';{{/hasRunCommand}}{{/hasCommandWithArgParser}}{{#hasCommandWithArgParser}}{{^hasRunCommand}}import 'package:args/args.dart';{{/hasRunCommand}}{{/hasCommandWithArgParser}}
import 'package:args/command_runner.dart';

{{#commands}}{{> command_import }}
{{/commands}}import 'runner.dart' as runner;

class {{name.pascalCase()}}CommandRunner extends CommandRunner<runner.Type> {
  {{name.pascalCase()}}CommandRunner()
      : super(
          '{{name}}',
          runner.description,
          {{#hasUsageLineLength}}usageLineLength: runner.usageLineLength,{{/hasUsageLineLength}}{{^hasUsageLineLength}}usageLineLength: stdout.hasTerminal ? stdout.terminalColumns : 80,{{/hasUsageLineLength}}
          {{#hasSuggestionDistanceLimit}}suggestionDistanceLimit: runner.suggestionDistanceLimit,{{/hasSuggestionDistanceLimit}}
        ) {
{{#commands}}{{^isBranch}}    addCommand({{name.pascalCase()}}Command());{{/isBranch}}{{#isBranch}}    addCommand(
      _BranchCommand(
        '{{name}}',
        [
          {{#subCommands}}{{> sub_commands }}
          {{/subCommands}}
        ],
      ),
    );{{/isBranch}}
{{/commands}}
  }

{{#hasRun}}  @override
  Future<void> run(Iterable<String> args) => runner.run(args, super.run);{{/hasRun}}

{{#hasRunCommand}}  @override
  Future<void> runCommand(ArgResults topLevelResults) => runner.runCommand(topLevelResults, super.runCommand);{{/hasRunCommand}}
}
{{#commands}}
{{> command }}
{{/commands}}
{{#hasBranchCommand}}class _BranchCommand extends Command<runner.Type> {
  _BranchCommand(this.name, List<Command<runner.Type>> subCommands) {
    for (final subCommand in subCommands) {
      addSubcommand(subCommand);
    }
  }

  @override
  final String name;

  @override
  String get description => 'The $name branch command.';
}{{/hasBranchCommand}}
