class HeliumRequest<D> {
  final String path;
  final Map<String, dynamic> parameters;
  final D Function(Map<String, dynamic>) extractResponse;

  HeliumRequest({
    required this.path,
    this.parameters = const {},
    required this.extractResponse,
  });

  Uri getUri(Uri base) {
    return base.resolve(_appendParameters(path, parameters.entries));
  }

  String _appendParameters(
      String path, Iterable<MapEntry<String, dynamic>> params) {
    var hasParameter = path.contains('?');
    final buf = StringBuffer(path);

    for (final p in params) {
      final v = p.value;

      if (v == null) {
        continue;
      }

      buf.write((hasParameter) ? '&' : '?');
      hasParameter = true;

      buf.write(p.key);
      buf.write('=');

      if (v is DateTime) {
        buf.write(v.toUtc().toIso8601String());
      } else if (v is Iterable<String>) {
        buf.writeAll(v, ',');
      } else {
        buf.write(v.toString());
      }
    }

    return buf.toString();
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
    Map<String, dynamic> parameters = const {},
    required D Function(Map<String, dynamic>) extractResponse,
    this.cursor,
  }) : super(
          path: path,
          extractResponse: extractResponse,
          parameters: parameters,
        );

  @override
  Uri getUri(Uri base) {
    var params = parameters.entries;

    if (cursor != null) {
      params = params.followedBy({'cursor': cursor}.entries);
    }

    return base.resolve(_appendParameters(path, params));
  }

  HeliumPagedRequest<D> withCursor(final String cursor) {
    return HeliumPagedRequest(
      path: path,
      extractResponse: extractResponse,
      parameters: parameters,
      cursor: cursor,
    );
  }
}
