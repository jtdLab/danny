<p align="center">
<img src="https://raw.githubusercontent.com/jtdlab/danny/main/assets/logo.png" height="125" alt="danny logo" />
</p>

<p align="center">
<a href="https://pub.dev/packages/danny_cli"><img src="https://img.shields.io/pub/v/danny_cli.svg" alt="Pub"></a>
<a href="https://github.com/jtdlab/danny/actions"><img src="https://github.com/jtdlab/danny/workflows/danny_cli/badge.svg" alt="danny"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://github.com/jtdlab/danny"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge" alt="Powered by Mason"></a>
</p>

A Command-Line Interface to develop wilde file-based command-line apps.

> #### Danny Wilde:
>
> 1. Protagonist in a great [tv series](https://en.wikipedia.org/wiki/The_Persuaders!) from the 70s.

## Quick Start

```sh
# 🎯 Activate from https://pub.dev
dart pub global activate danny_cli

# 🚀 Create a project
danny create greet

# 📦 Build the project
danny build

# 🔨 Activate the project locally
danny activate

# Use the new CLI
greet -h
```

---

## Table of Contents

- [Quick Start](#quick-start)
- [Table of Contents](#table-of-contents)
- [Overview](#overview)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Motivation](#motivation-)
  - [Prerequisites](#prerequisites-)
  - [Project Structure](#project-structure)
  - [CommandRunner](#commandrunner)
  - [Command](#command)
- [Create Project](#create-project)
- [Add Commands](#add-commands)
- [List Commands](#list-commands)
- [Build Project](#build-project)
- [Activate Project Locally](#activate-project-locally)

## Overview

### Installation

```sh
# 🎯 Activate from https://pub.dev
dart pub global activate danny_cli
```

### Usage

```sh
A Command-Line Interface to develop wilde command-line apps.

Usage: danny <command>

Global options:
-h, --help       Print this usage information.
-v, --version    Print the current version.
    --verbose    Enable verbose logging.

Available commands:
  activate   Activate a build locally.
  build      Create a build.
  create     Create a wilde project.
  list       List the commands of a project.
  new        Create a new command.

Run "danny help <command>" for more information about a command.
```

### Motivation 🧠

Frequently, during Dart/Flutter project development, specific project-related tooling requirements arise. In good cases this results in the creation of shell scripts placed in a `tool` directory, in less optimally cases, the task is only retained in developers' minds.
This package aims to simplify the process of writing tooling CLI(s) for Dart/Flutter projects using the Dart language.

### Prerequisites 📝

Each danny project relies on the [args](https://pub.dev/packages/args) package, so it's essential for developers to possess a fundamental understanding of how it functions.

### Project Structure

A basic danny project structure looks like this:

```
commands/
  <command-1>.dart
  <command-2>.dart
  <branch-command-1>/
    <nested-command-1>.dart
    <nested-command-2>.dart
pubspec.yaml
runner.dart
```

The `pubspec.yaml` exposes the executable of the CLI.

Inside the `commands` directory [Command](https://pub.dev/documentation/args/latest/command_runner/Command-class.html)s are defined in a file-based way.

The `runner.dart` configures the [CommandRunner](https://pub.dev/documentation/args/latest/command_runner/CommandRunner-class.html) hosting the commands.

### CommandRunner

The `runner.dart` allows developers to configure the [CommandRunner](https://pub.dev/documentation/args/latest/command_runner/CommandRunner-class.html) of the CLI.

```dart
import 'package:args/args.dart';

// Required
typedef Type = void;

// Required
const description = 'The cool CLI.';

// Optional
const usageLineLength = 100;

// Optional
const suggestionDistanceLimit = 4;

// Optional
Future<Type?> run(
  Iterable<String> args,
  Future<Type?> Function(Iterable<String> args) run,
) async {
  // ...
}

// Optional
Future<Type?> runCommand(
  ArgResults topLevelResults,
  Future<Type?> Function(ArgResults topLevelResults) runCommand,
) async {
  // ...
}
```

The code above shows the contents of a `runner.dart`.
It must expose a `Type` and a `description` at the top-level.

`Type`: The type of the [CommandRunner](https://pub.dev/documentation/args/latest/command_runner/CommandRunner-class.html) and all [Command](https://pub.dev/documentation/args/latest/command_runner/Command-class.html)s.

`description`: The [description](https://pub.dev/documentation/args/latest/command_runner/CommandRunner/description.html) of the CLI.

`usageLineLength`: The usage line length of the CLI. (optional)

`suggestionDistanceLimit`: The suggestion distance limit of the CLI. (optional)

`run`: The [run](https://pub.dev/documentation/args/latest/command_runner/CommandRunner/run.html)-method of the CLI. (Notice how it uses `Type` defined in `runner.dart`, and gets the run-method from super class passed to it) (optional)

`runCommand`: The [runCommand](https://pub.dev/documentation/args/latest/command_runner/CommandRunner/runCommand.html)-method of the CLI. (Notice how it uses `Type` defined in `runner.dart`, and gets the runCommand-method from super class passed to it) (optional)

### Command

A `<name>.dart` (command file) allows developers to implement a [Command](https://pub.dev/documentation/args/latest/command_runner/Command-class.html) of the CLI.

```dart
import 'dart:async';

import 'package:args/args.dart';

import '../runner.dart';

// Required
const description = 'My cool command.';

// Optional
const category = 'Foo';

// Optional
const invocation = 'cool [args]';

// Optional
const usageFooter = 'oooxxxooo';

// Optional
final argParser = ArgParser()
      ..addFlag(
        'foo',
        help: 'The foo flag.',
      )
      ..addOption(
        'bar',
        help: 'The bar option.',
      );

// Required
FutureOr<Type> run(ArgResults globalResults, ArgResults argResults) {
  final foo = argResults['foo'] as bool? ?? false;
  final bar = argResults['bar'] as String? ?? 'Baz';

  // ...
}
```

The code above shows the contents of a command file.
The `description`, and `run`-method must be available at the top-level of the file while, `category`, `invocation`, `usageFooter` and `argParser` are optional.

`description`: The [description](https://pub.dev/documentation/args/latest/command_runner/Command/description.html) of the command.

`run`: The [run](https://pub.dev/documentation/args/latest/command_runner/Command/run.html)-method of the command. (Notice how it uses `Type` defined in `runner.dart`, and gets [ArgResults](https://pub.dev/documentation/args/latest/args/ArgResults-class.html) holding the parsed command-line arguments passed to it)

`category`: The [category](https://pub.dev/documentation/args/latest/command_runner/Command/category.html) of the command. (optional)

`invocation`: The [invocation](https://pub.dev/documentation/args/latest/command_runner/Command/invocation.html) of the command. (optional)

`usageFooter`: The [usageFooter](https://pub.dev/documentation/args/latest/command_runner/Command/usageFooter.html) of the command. (optional)

`argParser`: The [argParser](https://pub.dev/documentation/args/latest/command_runner/Command/argParser.html) of the command. Allows developers to define options and flags of the command. (optional)

## Create Project

The `create` command allows developers to create a new project.

```sh
Create a wilde project.

Usage: danny create <project-name>
-h, --help           Print this usage information.
-o, --output-dir     The directory where to generate the new project.
                     (defaults to ".")
    --description    The description passed to the CommandRunner.

Run "danny help" to see global options.
```

## Add Commands

The `add` command allows developers to add new commands to a project.
If the new command includes parameters or flags, it is necessary to provide the `arg-parser` flag.

```sh
Create a new command.

Usage: danny new "foo bar baz"
-h, --help           Print this usage information.
    --arg-parser     Whether the command has a custom ArgParser.
    --description    The description of the command.

Run "danny help" to see global options.
```

## List Commands

The `list` command shows all available commands of a project.

```sh
List the commands of a project.

Usage: danny list
-h, --help    Print this usage information.

Run "danny help" to see global options.
```

## Build Project

The `build` command produces a `runner.danny.dart` at the project root containing the ready to use [CommandRunner](https://pub.dev/documentation/args/latest/command_runner/CommandRunner-class.html) and [Command](https://pub.dev/documentation/args/latest/command_runner/Command-class.html)s based on `runner.dart` and the commands defined inside `commands` directory.

```sh
Create a build.

Usage: danny build
-h, --help    Print this usage information.

Run "danny help" to see global options.
```

## Activate Project Locally

The `activate` command makes the executable of the project available locally,
using `dart pub global activate` under the hood.

```sh
Activate a build locally.

Usage: danny activate
-h, --help    Print this usage information.

Run "danny help" to see global options.
```
