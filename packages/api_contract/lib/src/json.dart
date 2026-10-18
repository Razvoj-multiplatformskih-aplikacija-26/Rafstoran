Map<String, Object?> jsonObject(Object? value) => switch (value) {
  final Map<String, Object?> object => object,
  _ => throw FormatException('Expected a JSON object', value),
};

List<Map<String, Object?>> jsonObjects(Map<String, Object?> json, String key) => switch (json[key]) {
  final List<Object?> list => [for (final item in list) jsonObject(item)],
  _ => throw FormatException('Expected "$key" to be a list', json),
};

String jsonString(Map<String, Object?> json, String key) => switch (json[key]) {
  final String value => value,
  _ => throw FormatException('Expected "$key" to be a string', json),
};

String? jsonOptionalString(Map<String, Object?> json, String key) => switch (json[key]) {
  null => null,
  final String value => value,
  _ => throw FormatException('Expected "$key" to be a string', json),
};

int jsonInt(Map<String, Object?> json, String key) => switch (json[key]) {
  final int value => value,
  _ => throw FormatException('Expected "$key" to be an integer', json),
};

int? jsonOptionalInt(Map<String, Object?> json, String key) => switch (json[key]) {
  null => null,
  final int value => value,
  _ => throw FormatException('Expected "$key" to be an integer', json),
};

DateTime jsonInstant(Map<String, Object?> json, String key) => DateTime.parse(jsonString(json, key)).toUtc();

DateTime? jsonOptionalInstant(Map<String, Object?> json, String key) => switch (jsonOptionalString(json, key)) {
  null => null,
  final String value => DateTime.parse(value).toUtc(),
};

String instantToJson(DateTime instant) => instant.toUtc().toIso8601String();
