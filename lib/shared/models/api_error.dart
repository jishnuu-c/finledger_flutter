class FieldError {
  final String field;
  final String message;

  const FieldError({
    required this.field,
    required this.message,
  });

  factory FieldError.fromJson(Map<String, dynamic> json) {
    return FieldError(
      field: json['field'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'field': field,
    'message': message,
  };

  @override
  String toString() => '$field: $message';
}

class ApiError implements Exception {
  final DateTime? timestamp;
  final int status;
  final String code;
  final String message;
  final String? path;
  final List<FieldError> fieldErrors;

  const ApiError({
    this.timestamp,
    required this.status,
    required this.code,
    required this.message,
    this.path,
    this.fieldErrors = const [],
  });

  factory ApiError.fromJson(Map<String, dynamic> json, {int? fallbackStatus}) {
    DateTime? parsedTimestamp;
    if (json['timestamp'] != null) {
      if (json['timestamp'] is String) {
        parsedTimestamp = DateTime.tryParse(json['timestamp'] as String);
      } else if (json['timestamp'] is int) {
        parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int);
      }
    }

    final rawFieldErrors = json['fieldErrors'];
    final List<FieldError> errors = [];
    if (rawFieldErrors is List) {
      for (final item in rawFieldErrors) {
        if (item is Map<String, dynamic>) {
          errors.add(FieldError.fromJson(item));
        }
      }
    }

    return ApiError(
      timestamp: parsedTimestamp,
      status: json['status'] is int ? json['status'] as int : (fallbackStatus ?? 500),
      code: json['code'] as String? ?? 'ERROR',
      message: json['message'] as String? ?? 'An unexpected error occurred',
      path: json['path'] as String?,
      fieldErrors: errors,
    );
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp?.toIso8601String(),
    'status': status,
    'code': code,
    'message': message,
    'path': path,
    'fieldErrors': fieldErrors.map((e) => e.toJson()).toList(),
  };

  /// Returns user-friendly message, appending field-level errors if present
  String get displayMessage {
    if (fieldErrors.isEmpty) {
      return message;
    }
    final details = fieldErrors.map((e) => '${e.field}: ${e.message}').join('\n');
    return '$message:\n$details';
  }

  @override
  String toString() => 'ApiError(status: $status, code: $code, message: $message, path: $path, fieldErrors: $fieldErrors)';
}
