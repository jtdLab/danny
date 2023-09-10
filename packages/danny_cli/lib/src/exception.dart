/// {@template danny_exception}
/// Base class for all exceptions.
/// {@endtemplate}
class DannyException implements Exception {
  /// {@macro danny_exception}
  DannyException(this.message);

  /// A descriptive message describing the failure.
  final String message;

  @override
  String toString() => message;
}
