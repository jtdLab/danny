import 'package:args/command_runner.dart';
import 'package:danny_cli/src/exception.dart';
import 'package:test/test.dart';

Matcher isUsageException({String? message}) {
  var matcher = isA<UsageException>();

  if (message != null) {
    matcher = matcher.having((e) => e.message, 'message', message);
  }

  return matcher;
}

Matcher throwsUsageException({String? message}) {
  return throwsA(isUsageException(message: message));
}

Matcher isDannyException({String? message}) {
  var matcher = isA<DannyException>();

  if (message != null) {
    matcher = matcher.having((e) => e.message, 'message', message);
  }

  return matcher;
}

Matcher throwsDannyException({String? message}) {
  return throwsA(isDannyException(message: message));
}
