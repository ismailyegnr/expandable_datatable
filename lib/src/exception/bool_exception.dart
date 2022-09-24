class BoolParsingException implements Exception {
  @override
  String toString() {
    return "Could not parse string as boolean.";
  }
}
