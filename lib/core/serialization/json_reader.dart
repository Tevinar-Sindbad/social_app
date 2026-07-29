/// Typed helpers for reading validated values from decoded JSON maps.
class JsonReader {
  const JsonReader._();

  static const String _defaultSource = 'JSON payload';

  /// Reads a required string field from [json].
  ///
  /// Throws a [FormatException] when [field] is missing or is not a string.
  static String readString(
    Map<String, dynamic> json,
    String field, {
    String source = _defaultSource,
  }) {
    final value = json[field];
    if (value is! String) {
      throw FormatException('$source has invalid "$field" field');
    }
    return value;
  }

  /// Reads a required non-empty string field from [json].
  ///
  /// Throws a [FormatException] when [field] is missing, is not a string, or
  /// is empty.
  static String readNonEmptyString(
    Map<String, dynamic> json,
    String field, {
    String source = _defaultSource,
  }) {
    final value = readString(
      json,
      field,
      source: source,
    );

    if (value.isEmpty) {
      throw FormatException('$source has invalid "$field" field');
    }

    return value;
  }

  /// Reads an optional string field from [json].
  ///
  /// Returns `null` when the field is absent or explicitly null.
  /// Throws a [FormatException] when the field exists but is not a string.
  static String? readNullableString(
    Map<String, dynamic> json,
    String field, {
    String source = _defaultSource,
  }) {
    final value = json[field];
    if (value == null) {
      return null;
    }
    if (value is! String) {
      throw FormatException('$source has invalid "$field" field');
    }
    return value;
  }

  /// Reads a required object field from [json].
  ///
  /// Throws a [FormatException] when [field] is missing or is not a JSON
  /// object.
  static Map<String, dynamic> readObject(
    Map<String, dynamic> json,
    String field, {
    String source = _defaultSource,
  }) {
    final value = json[field];
    if (value is! Map<String, dynamic>) {
      throw FormatException('$source has invalid "$field" field');
    }
    return value;
  }

  /// Converts [value] to a JSON object map.
  ///
  /// Throws a [FormatException] when [value] is not a JSON object.
  static Map<String, dynamic> asObject(
    dynamic value,
    String field, {
    String source = _defaultSource,
  }) {
    if (value is! Map<String, dynamic>) {
      throw FormatException('$source has invalid "$field" field');
    }
    return value;
  }

  /// Reads a required integer-like field from [json].
  ///
  /// Numeric JSON values are accepted as long as they can be represented as an
  /// integer. Throws a [FormatException] when [field] is missing or not
  /// numeric.
  static int readInt(
    Map<String, dynamic> json,
    String field, {
    String source = _defaultSource,
  }) {
    final value = json[field];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    throw FormatException('$source has invalid "$field" field');
  }

  /// Reads a required list field from [json].
  ///
  /// Throws a [FormatException] when [field] is missing or is not a JSON
  /// array.
  static List<dynamic> readList(
    Map<String, dynamic> json,
    String field, {
    String source = _defaultSource,
  }) {
    final value = json[field];
    if (value is! List<dynamic>) {
      throw FormatException('$source has invalid "$field" field');
    }
    return value;
  }

  /// Reads a required list of strings field from [json].
  ///
  /// Throws a [FormatException] when [field] is missing, is not a JSON array,
  /// or contains at least one non-string item.
  static List<String> readStringList(
    Map<String, dynamic> json,
    String field, {
    String source = _defaultSource,
  }) {
    final value = readList(json, field, source: source);

    for (final item in value) {
      if (item is! String) {
        throw FormatException('$source has invalid "$field" field');
      }
    }

    return value.cast<String>();
  }

  /// Reads a required ISO-8601 date-time field from [json].
  ///
  /// Throws a [FormatException] when [field] is missing, is not a string, or
  /// cannot be parsed by [DateTime.parse].
  static DateTime readDateTime(
    Map<String, dynamic> json,
    String field, {
    String source = _defaultSource,
  }) {
    final value = readString(json, field, source: source);

    try {
      return DateTime.parse(value).toLocal();
    } on FormatException {
      throw FormatException('$source has invalid "$field" field');
    }
  }
}
