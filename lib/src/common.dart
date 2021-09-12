/// Represents a runtime error from the Helium API client.
class HeliumException implements Exception {
  /// The error message.
  final String message;

  /// The [Uri] that was being accessed, if any.
  final Uri? uri;

  /// The thrown object that caused this exception, if any.
  final Object? cause;

  /// The HTTP response body causing this exception, if any.
  final String? body;

  const HeliumException(this.message, {this.uri, this.body, this.cause});

  @override
  String toString() {
    final buf = StringBuffer(message);

    if (uri != null) {
      buf.write(' (uri: "');
      buf.write(uri);
      buf.write('")');
    }

    if (cause != null) {
      buf.write(' (cause: "');
      buf.write(cause.toString());
      buf.write('")');
    }

    if (body != null) {
      buf.write('\nResponse Body:\n');
      buf.write(body);
      buf.write('\n---End of Response Body---\n\n');
    }

    return buf.toString();
  }
}
