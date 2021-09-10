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
    return _createRequestUri(base, path, parameters.entries);
  }

  static Uri _createRequestUri(
      Uri base, String path, Iterable<MapEntry<String, dynamic>> parameters) {
    var basePath = base.path;

    if (basePath.endsWith('/')) {
      basePath = basePath.substring(0, -1);
    }

    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    return base.replace(
      path: '$basePath/$path',
      queryParameters: _convertParameters(parameters),
    );
  }

  static Map<String, dynamic>? _convertParameters(
      Iterable<MapEntry<String, dynamic>> parameters) {
    final result = Map.fromEntries(
      parameters
          .where((e) => e.value != null) // ignore null parameters
          .map((e) => MapEntry(e.key, _convertParameter(e.value)))
          .where((e) => e.value.isNotEmpty), // ignore empty strings
    );

    if (result.isEmpty) {
      return null;
    }

    return result;
  }

  static String _convertParameter(dynamic value) {
    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    } else if (value is Iterable<String>) {
      return value.join(',');
    }

    return value.toString();
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

    return HeliumRequest._createRequestUri(base, path, params);
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
