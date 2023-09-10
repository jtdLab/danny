import 'dart:async';

import 'package:args/args.dart';

import '../{{#pathSegments}}../{{/pathSegments}}runner.dart';

const description = '{{description}}';
{{#hasCustomArgParser}}
// TODO: add flags/options
final argParser = ArgParser();
{{/hasCustomArgParser}}
FutureOr<Type> run(ArgResults globalResults, ArgResults argResults) async {
  // TODO: implement
}
