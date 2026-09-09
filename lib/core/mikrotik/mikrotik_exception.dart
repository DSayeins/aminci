class MikroTikException implements Exception {
  const MikroTikException({this.statusCode, required this.message});

  final int? statusCode;
  final String message;

  @override
  String toString() => statusCode != null
      ? 'MikroTikException($statusCode): $message'
      : 'MikroTikException: $message';
}
