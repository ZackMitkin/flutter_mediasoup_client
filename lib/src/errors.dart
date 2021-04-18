class InvalidStateError implements Exception {
  final String message;

  InvalidStateError(this.message);

  @override
  String toString() {
    return message;
  }
}
