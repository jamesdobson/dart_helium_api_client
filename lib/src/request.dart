class HeliumRequest<D> {
  String path;
  D Function(Map<String, dynamic>) extractResponse;

  HeliumRequest({
    required this.path,
    required this.extractResponse,
  });

  Uri getUri(Uri base) {
    return base.resolve(path);
  }

  static List<T> mapDataList<T>(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) f) {
    return (json['data'] as List).map((e) => f(e)).toList();
  }
}

class HeliumPagedRequest<D> extends HeliumRequest<D> {
  final String? cursor;

  HeliumPagedRequest({
    required String path,
    required D Function(Map<String, dynamic>) extractResponse,
    this.cursor,
  }) : super(path: path, extractResponse: extractResponse);

  @override
  Uri getUri(Uri base) {
    final hasParameters = path.contains('?');

    return base.resolve(_appendCursor(path, hasParameters));
  }

  String _appendCursor(String str, bool hasParameters) {
    if (cursor != null) {
      if (hasParameters) {
        str += '&cursor=$cursor';
      } else {
        str += '?cursor=$cursor';
      }
    }

    return str;
  }

  HeliumPagedRequest<D> withCursor(final String cursor) {
    return HeliumPagedRequest(
        path: path, extractResponse: extractResponse, cursor: cursor);
  }
}
