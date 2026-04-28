/// Thrown when an operation would leave an account balance negative.
class InsufficientBalanceException implements Exception {
  final String message;

  InsufficientBalanceException([this.message = 'Insufficient balance']);

  @override
  String toString() => message;
}
