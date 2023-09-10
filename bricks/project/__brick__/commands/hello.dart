import 'dart:async';

import 'package:args/args.dart';

import '../runner.dart';

const description = 'Share a hello.';

FutureOr<Type> run(ArgResults globalResults, ArgResults argResults) {
  // ignore: avoid_print
  print('Hello!');
}
