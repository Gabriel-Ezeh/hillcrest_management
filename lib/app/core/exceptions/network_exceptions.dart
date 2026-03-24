/// A base class for all network-related exceptions.
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}

/// Thrown when the user provides incorrect credentials (401 Unauthorized).
class InvalidCredentialsException extends NetworkException {
  InvalidCredentialsException({String? message})
      : super(message ?? 'Invalid username or password. Please try again.');
}

/// Thrown when a network request times out.
class TimeoutException extends NetworkException {
  TimeoutException({String? message})
      : super(message ?? 'The connection timed out. Please check your internet connection and try again.');
}

/// Thrown when a user with the given identifier already exists.
class UserAlreadyExistsException extends NetworkException {
  UserAlreadyExistsException()
      : super('An account with this email or username already exists.');
}

/// A generic exception for other client-side errors (e.g., 400 Bad Request).
class ClientException extends NetworkException {
  ClientException({String? message})
      : super(message ?? 'An error occurred on the client. Please try again later.');
}

/// A generic exception for server-side errors (e.g., 500 Internal Server Error).
class ServerException extends NetworkException {
  ServerException({String? message})
      : super(message ?? 'Our servers are experiencing issues. Please try again later.');
}

/// A generic exception for unexpected errors.
class UnexpectedException extends NetworkException {
  UnexpectedException({String? message})
      : super(message ?? 'An unexpected error occurred. Please try again.');
}

/// Thrown when a user with the given phone number already exists.
class PhoneNumberAlreadyExistsException extends NetworkException {
  PhoneNumberAlreadyExistsException()
      : super('An account with this phone number already exists.');
}

class EmailAlreadyExistsException extends NetworkException {
  EmailAlreadyExistsException()
      : super('An account with this email already exists.');
}

class DataFetchingException implements Exception {
  final String message;

  DataFetchingException({this.message = 'Failed to fetch data'});

  @override
  String toString() => message;
}
