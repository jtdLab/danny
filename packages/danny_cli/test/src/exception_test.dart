import 'package:danny_cli/src/exception.dart';
import 'package:test/test.dart';

void main() {
  group('BranchCommandConfig', () {
    test('toString', () {
      const msg = 'test message';
      final exception = DannyException(msg);
      expect(exception.toString(), msg);
    });
  });
}
