import 'hotspots.dart';
import 'transactions.dart';
import 'request.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HeliumClient {
  static const String STABLE_URL = 'https://api.helium.io';
  static const String BETA_URL = 'https://api.helium.wtf';

  final Uri _base;

  /// Operations on the Hotspots API. (https://docs.helium.com/api/blockchain/hotspots)
  late final HeliumHotspotClient hotspots;

  /// Operations on the Transactions API. (https://docs.helium.com/api/blockchain/transactions)
  late final HeliumTransactionsClient transactions;

  HeliumClient({
    baseUrl = STABLE_URL,
  }) : _base = Uri.parse(baseUrl) {
    hotspots = HeliumHotspotClient(this);
    transactions = HeliumTransactionsClient(this);
  }

  Future<HeliumResponse<T>> _doRequest<T>(final HeliumRequest<T> req) async {
    final uri = req.getUri(_base);
    final resp = await http.get(uri);
    final Map<String, dynamic> result = json.decode(resp.body);

    if (result.containsKey('cursor')) {
      throw StateError(
          '`_doRequest` received a paged response, use `_doPagedRequest` instead.');
    }

    return HeliumResponse<T>(
      data: req.extractResponse(result),
    );
  }

  Future<HeliumPagedResponse<T>> _doPagedRequest<T>(
      final HeliumPagedRequest<T> req) async {
    final uri = req.getUri(_base);
    final resp = await http.get(uri);
    final Map<String, dynamic> result = json.decode(resp.body);
    final cursor = result['cursor'] as String?;

    return HeliumPagedResponse<T>(
      request: req,
      data: req.extractResponse(result),
      cursor: cursor,
    );
  }

  Future<HeliumPagedResponse<T>> getNextPage<T>(
      final HeliumPagedResponse<T> response) async {
    return _doPagedRequest(response._getNextPageRequest());
  }

  /*
  Future<List<D>> readAll<D>(final HeliumPagedResponse<List<D>> response) async {

  };
  */
}

class HeliumResponse<T> {
  final T data;

  HeliumResponse({
    required this.data,
  });
}

class HeliumPagedResponse<T> extends HeliumResponse<T> {
  final HeliumPagedRequest<T> _request;
  final String? _cursor;

  HeliumPagedResponse(
      {required data, required HeliumPagedRequest<T> request, String? cursor})
      : _request = request,
        _cursor = cursor,
        super(data: data);

  bool get hasNextPage => _cursor != null;

  HeliumPagedRequest<T> _getNextPageRequest() {
    final c = _cursor;

    if (c == null) {
      throw StateError(
          '`getNextPageRequest` must not be called when `hasNextPage` is false.');
    }

    return _request.withCursor(c);
  }
}

/// Operations on the Hotspots API.
/// https://docs.helium.com/api/blockchain/hotspots
class HeliumHotspotClient {
  final HeliumClient _client;

  HeliumHotspotClient(this._client);

  /// Lists known hotspots as registered on the blockchain.
  ///
  /// The [filterModes] parameter can be used to filter hotspots by how they
  /// were added to the blockchain.
  Future<HeliumPagedResponse<List<HeliumHotspot>>> listHotspots(
      {Set<HeliumHotspotFilterMode> filterModes = const {}}) async {
    return _client._doPagedRequest(HeliumPagedRequest(
      path: (filterModes.isNotEmpty)
          ? '/v1/hotspots?filter_modes=${filterModes.map((e) => e.value).join(',')}'
          : '/v1/hotspots',
      extractResponse: (json) => HeliumRequest.mapDataList(
          json, (hotspot) => HeliumHotspot.fromJson(hotspot)),
    ));
  }

  /// Fetches the hotspot with the given address.
  ///
  /// [address] is the B58 address of the hotspot.
  Future<HeliumResponse<HeliumHotspot>> getHotspotForAddress(
      String address) async {
    return _client._doRequest(HeliumRequest(
      path: '/v1/hotspots/$address',
      extractResponse: (json) => HeliumHotspot.fromJson(json['data']),
    ));
  }

  /// Fetches the hotspots which map to the given 3-word animal name.
  ///
  /// The name must be all lower-case with dashes between the words, e.g.
  /// 'tall-plum-griffin'. Because of collisions in the Angry Purple Tiger
  /// algorithm, the given name might map to more than one hotspot.
  Future<HeliumResponse<List<HeliumHotspot>>> getHotspotsForName(
      String name) async {
    return _client._doRequest(HeliumRequest(
      path: '/v1/hotspots/name/$name',
      extractResponse: (json) => HeliumRequest.mapDataList(
          json, (hotspot) => HeliumHotspot.fromJson(hotspot)),
    ));
  }

  /// Fetches the hotspots which mach a search term in the [query] parameter.
  ///
  /// The [query] parameter needs to be at least one character, with 3 or more
  /// recommended.
  Future<HeliumResponse<List<HeliumHotspot>>> searchHotspotsForName(
      String query) async {
    if (query.isEmpty) {
      throw ArgumentError.value(query, 'query',
          'The `query` parameter must be at least one character in length.');
    }

    return _client._doRequest(HeliumRequest(
      path: '/v1/hotspots/name?search=$query',
      extractResponse: (json) => HeliumRequest.mapDataList(
          json, (hotspot) => HeliumHotspot.fromJson(hotspot)),
    ));
  }

  /// Fetches the hotspots which are within a given number of metres from the
  /// given [lat] and [lon] coordinates.
  ///
  /// The [lat] and [lon] coordinates are measured in degrees.
  /// The [distance] is measured in metres.
  Future<HeliumPagedResponse<List<HeliumHotspot>>> searchHotspotsByDistance(
      double lat, double lon, int distance) async {
    return _client._doPagedRequest(HeliumPagedRequest(
      path:
          '/v1/hotspots/location/distance?lat=$lat&lon=$lon&distance=$distance',
      extractResponse: (json) => HeliumRequest.mapDataList(
          json, (hotspot) => HeliumHotspot.fromJson(hotspot)),
    ));
  }

  /// Fetches the hotspots which are within a given geographic boundary
  /// indicated by its south-western and north-eastern coordinates.
  ///
  /// The south-western corner of the box is given by lat/lon pair
  /// [swlat] and [swlon].
  /// The north-eastern corner of the box is given by lat/lon pair
  /// [nelat] and [nelon].
  Future<HeliumPagedResponse<List<HeliumHotspot>>> searchHotspotsByBox(
      double swlat, double swlon, double nelat, double nelon) async {
    return _client._doPagedRequest(HeliumPagedRequest(
      path:
          '/v1/hotspots/location/box?swlat=$swlat&swlon=$swlon&nelat=$nelat&nelon=$nelon',
      extractResponse: (json) => HeliumRequest.mapDataList(
          json, (hotspot) => HeliumHotspot.fromJson(hotspot)),
    ));
  }

  /// Fetches the hotspots which are in the given h3 index.
  ///
  /// The supported h3 indices are currently limited to resolution 8.
  Future<HeliumPagedResponse<List<HeliumHotspot>>> searchHotspotsByH3Index(
      String h3index) async {
    return _client._doPagedRequest(HeliumPagedRequest(
      path: '/v1/hotspots/hex/$h3index',
      extractResponse: (json) => HeliumRequest.mapDataList(
          json, (hotspot) => HeliumHotspot.fromJson(hotspot)),
    ));
  }

  /// Lists all blockchain transactions in which the given hotspot was involved.
  ///
  /// [address] is the B58 address of the hotspot.
  /// [filterTypes] is a list of transaction types to retrieve. If empty, all
  /// transactions are listed.
  Future<HeliumPagedResponse<List<HeliumTransaction>>> listHotspotActivity(
      String address,
      {Set<HeliumTransactionType> filterTypes = const {}}) async {
    return _client._doPagedRequest(HeliumPagedRequest(
      path: (filterTypes.isEmpty)
          ? '/v1/hotspots/$address/activity'
          : '/v1/hotspots/$address/activity?filter_types=${filterTypes.map((e) => e.value).join(',')}',
      extractResponse: (json) => HeliumRequest.mapDataList(
          json, (hotspot) => HeliumTransaction.fromJson(hotspot)),
    ));
  }

  /// Counts transactions that indicate activity for a hotspot.
  ///
  /// The results are a map keyed by the transation types given in
  /// [filterTypes] with the value for each key being the count of transactions
  /// of that type. If [filterTypes] is omitted, all types are reported,
  /// including ones with a count of zero.
  ///
  /// [address] is the B58 address of the hotspot.
  Future<HeliumResponse<Map<HeliumTransactionType, int>>>
      getHotspotActivityCounts(String address,
          {Set<HeliumTransactionType> filterTypes = const {}}) async {
    return _client._doPagedRequest(
      HeliumPagedRequest(
          path: (filterTypes.isEmpty)
              ? '/v1/hotspots/$address/activity/count'
              : '/v1/hotspots/$address/activity/count?filter_types=${filterTypes.map((e) => e.value).join(',')}',
          extractResponse: (json) {
            final data = json['data'] as Map<String, dynamic>;
            return data.map((key, value) =>
                MapEntry(HeliumTransactionType.get(key), value as int));
          }),
    );
  }

  /// Returns the list of hotspots that are currently elected to the concensus
  /// group.
  Future<HeliumResponse<List<HeliumHotspot>>>
      getCurrentlyElectedHotspots() async {
    return _client._doRequest(HeliumRequest(
      path: '/v1/hotspots/elected',
      extractResponse: (json) => HeliumRequest.mapDataList(
          json, (hotspot) => HeliumHotspot.fromJson(hotspot)),
    ));
  }

  /// Returns rewards for a given hotspot per reward block the hotspot is in,
  /// for a given timeframe.
  ///
  /// The block that contains the [maxTime] timestamp is excluded from the
  /// result.
  /// [address] is the B58 address of the hotspot.
  Future<HeliumPagedResponse<List<HeliumHotspotReward>>> getRewards(
      String address, DateTime minTime, DateTime maxTime) async {
    return _client._doPagedRequest(HeliumPagedRequest(
      path:
          '/v1/hotspots/$address/rewards?min_time=${minTime.toUtc().toIso8601String()}&max_time=${maxTime.toUtc().toIso8601String()}',
      extractResponse: (json) => HeliumRequest.mapDataList(
          json, (reward) => HeliumHotspotReward.fromJson(reward)),
    ));
  }
}

/// Operations on the Transactions API.
/// https://docs.helium.com/api/blockchain/transactions
class HeliumTransactionsClient {
  final HeliumClient _client;

  HeliumTransactionsClient(this._client);

  /// Fetches the transaction for a given hash.
  Future<HeliumResponse<HeliumTransaction>> getTransaction(String hash) async {
    return _client._doRequest(HeliumRequest(
      path: '/v1/transactions/$hash',
      extractResponse: (json) => HeliumTransaction.fromJson(json['data']),
    ));
  }
}

class HeliumException implements Exception {
  final String message;

  const HeliumException([this.message = 'HeliumException']);

  @override
  String toString() => message;
}
