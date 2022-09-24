class NoSupportException implements Exception {
  String type;
  NoSupportException(
    this.type,
  );

  @override
  String toString() {
    return "This package does not support $type type.";
  }
}
