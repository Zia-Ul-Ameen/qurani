// lib/core/errors/failures.dart

sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  final int? statusCode;
  const NetworkFailure(super.message, {this.statusCode});

  @override
  String toString() => 'NetworkFailure($message, statusCode: $statusCode)';
}

class ParseFailure extends Failure {
  const ParseFailure(super.message);

  @override
  String toString() => 'ParseFailure($message)';
}

class AudioFailure extends Failure {
  const AudioFailure(super.message);

  @override
  String toString() => 'AudioFailure($message)';
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);

  @override
  String toString() => 'StorageFailure($message)';
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);

  @override
  String toString() => 'NotFoundFailure($message)';
}

class DownloadFailure extends Failure {
  const DownloadFailure(super.message);

  @override
  String toString() => 'DownloadFailure($message)';
}
