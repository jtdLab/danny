import 'package:build_verify/build_verify.dart';
import 'package:test/test.dart';

void main() {
  test(
    'ensure_build',
    () async => expectBuildClean(
      packageRelativeDirectory: 'packages/danny_cli',
    ),
    timeout: const Timeout.factor(2),
  );
}
