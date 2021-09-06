DateTime heliumTimestampFromJson(String value) {
  return DateTime.parse(value);
}

String heliumTimestampToJson(DateTime value) {
  return value.toIso8601String();
}
