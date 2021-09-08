DateTime heliumTimestampFromJson(String value) {
  return DateTime.parse(value);
}

String heliumTimestampToJson(DateTime value) {
  return value.toIso8601String();
}

DateTime heliumBlockTimeFromJson(int value) {
  return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
}

int heliumBlockTimeToJson(DateTime value) {
  return (value.millisecondsSinceEpoch / 1000).floor();
}
