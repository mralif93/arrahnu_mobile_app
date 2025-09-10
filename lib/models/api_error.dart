enum ApiErrorType {
  networkError,
  clientError,
  serverError,
  parseError,
  timeoutError,
  unknown,
}

class ApiError {
  final int statusCode;
  final String message;
  final ApiErrorType type;
  final Map<String, dynamic>? details;

  ApiError({
    required this.statusCode,
    required this.message,
    required this.type,
    this.details,
  });

  // Check if error is retryable
  bool get isRetryable {
    switch (type) {
      case ApiErrorType.networkError:
      case ApiErrorType.timeoutError:
      case ApiErrorType.serverError:
        return true;
      case ApiErrorType.clientError:
        return statusCode == 408 || statusCode == 429; // Timeout or rate limit
      default:
        return false;
    }
  }

  // Check if error requires authentication
  bool get requiresAuth {
    return statusCode == 401 || statusCode == 403;
  }

  // Get user-friendly error message
  String get userMessage {
    switch (type) {
      case ApiErrorType.networkError:
        return 'No internet connection. Please check your network and try again.';
      case ApiErrorType.timeoutError:
        return 'Request timed out. Please try again.';
      case ApiErrorType.clientError:
        if (statusCode == 401) {
          return 'Session expired. Please login again.';
        } else if (statusCode == 403) {
          return 'Access denied. You don\'t have permission to perform this action.';
        } else if (statusCode == 404) {
          return 'The requested resource was not found.';
        } else if (statusCode == 422) {
          return 'Invalid data provided. Please check your input and try again.';
        } else if (statusCode == 429) {
          return 'Too many requests. Please wait a moment and try again.';
        }
        return message;
      case ApiErrorType.serverError:
        return 'Server error occurred. Please try again later.';
      case ApiErrorType.parseError:
        return 'Failed to process server response. Please try again.';
      default:
        return message;
    }
  }

  @override
  String toString() {
    return 'ApiError(statusCode: $statusCode, message: $message, type: $type)';
  }
}
