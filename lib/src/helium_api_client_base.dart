import 'dart:io';

import 'package:helium_api_client/src/model/hotspots.dart';
import 'package:helium_api_client/src/model/oracle_prices.dart';
import 'package:helium_api_client/src/model/transactions.dart';

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

  /// Operations on the Oracle Prices API. (https://docs.helium.com/api/blockchain/oracle-prices)
  late final HeliumOraclePricesClient prices;

  HeliumClient({
    String baseUrl = STABLE_URL,
  }) : _base = Uri.parse(baseUrl) {
    hotspots = HeliumHotspotClient(this);
    prices = HeliumOraclePricesClient(this);
    transactions = HeliumTransactionsClient(this);
  }

  Future<http.Response> _do<T>(final Uri uri) async {
    final resp;

    try {
      resp = await http.get(uri);
    } on IOException catch (e) {
      throw HeliumException('Network error', uri: uri, cause: e);
    }

    if (resp.statusCode >= 400) {
      throw HeliumException(
          'HTTP error (${resp.statusCode} ${resp.reasonPhrase})',
          uri: uri);
    }

    if (resp.statusCode >= 300) {
      throw HeliumException('Unexpected HTTP redirect (${resp.statusCode})',
          uri: uri);
    }

    return resp;
  }

  Future<HeliumResponse<T>> _doRequest<T>(final HeliumRequest<T> req) async {
    final uri = req.getUri(_base);
    final resp = await _do(uri);
    final Map<String, dynamic> result = json.decode(resp.body);

    if (result.containsKey('cursor')) {
      throw HeliumException(
          '`_doRequest` received a paged response, use `_doPagedRequest` instead.',
          uri: uri);
    }

    return HeliumResponse<T>(
      data: req.extractResponse(result),
    );
  }

  Future<HeliumPagedResponse<T>> _doPagedRequest<T>(
      final HeliumPagedRequest<T> req) async {
    final uri = req.getUri(_base);
    final resp = await _do(uri);
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
  /// The response data.
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
  /// The [modeFilter] parameter can be used to filter hotspots by how they
  /// were added to the blockchain.
  Future<HeliumPagedResponse<List<HeliumHotspot>>> listHotspots(
      {Set<HeliumHotspotMode> modeFilter = const {}}) async {
    return _client._doPagedRequest(HeliumPagedRequest(
      path: '/v1/hotspots',
      parameters: {
        'filter_modes': modeFilter.map((e) => e.value),
      },
      extractResponse: (json) =>
          HeliumRequest.mapDataList(json, (h) => HeliumHotspot.fromJson(h)),
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
      extractResponse: (json) =>
          HeliumRequest.mapDataList(json, (h) => HeliumHotspot.fromJson(h)),
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
      path: '/v1/hotspots/name',
      parameters: {
        'search': query,
      },
      extractResponse: (json) =>
          HeliumRequest.mapDataList(json, (h) => HeliumHotspot.fromJson(h)),
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
      path: '/v1/hotspots/location/distance',
      parameters: {
        'lat': lat,
        'lon': lon,
        'distance': distance,
      },
      extractResponse: (json) =>
          HeliumRequest.mapDataList(json, (h) => HeliumHotspot.fromJson(h)),
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
      path: '/v1/hotspots/location/box',
      parameters: {
        'swlat': swlat,
        'swlon': swlon,
        'nelat': nelat,
        'nelon': nelon,
      },
      extractResponse: (json) =>
          HeliumRequest.mapDataList(json, (h) => HeliumHotspot.fromJson(h)),
    ));
  }

  /// Fetches the hotspots which are in the given H3 index.
  ///
  /// The supported H3 indices are currently limited to resolution 8.
  Future<HeliumPagedResponse<List<HeliumHotspot>>> searchHotspotsByH3Index(
      String h3index) async {
    return _client._doPagedRequest(HeliumPagedRequest(
      path: '/v1/hotspots/hex/$h3index',
      extractResponse: (json) =>
          HeliumRequest.mapDataList(json, (h) => HeliumHotspot.fromJson(h)),
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
      path: '/v1/hotspots/$address/activity',
      parameters: {
        'filter_types': filterTypes.map((e) => e.value),
      },
      extractResponse: (json) =>
          HeliumRequest.mapDataList(json, (h) => HeliumTransaction.fromJson(h)),
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
          path: '/v1/hotspots/$address/activity/count',
          parameters: {
            'filter_types': filterTypes.map((e) => e.value),
          },
          extractResponse: (json) {
            final data = json['data'] as Map<String, dynamic>;
            return data.map((key, value) =>
                MapEntry(HeliumTransactionType.get(key), value as int));
          }),
    );
  }

  /// Lists the consensus group transactions in which the given hotspot was
  /// involved.
  ///
  /// [address] is the B58 address of the hotspot.
  Future<HeliumPagedResponse<List<HeliumTransactionConsensusGroupV1>>>
      listHotspotElections(String address) async {
    return _client._doPagedRequest(HeliumPagedRequest(
      path: '/v1/hotspots/$address/elections',
      extractResponse: (json) => HeliumRequest.mapDataList(
          json, (t) => HeliumTransactionConsensusGroupV1.fromJson(t)),
    ));
  }

  /// Returns the list of hotspots that are currently elected to the concensus
  /// group.
  Future<HeliumResponse<List<HeliumHotspot>>>
      getCurrentlyElectedHotspots() async {
    return _client._doRequest(HeliumRequest(
      path: '/v1/hotspots/elected',
      extractResponse: (json) =>
          HeliumRequest.mapDataList(json, (h) => HeliumHotspot.fromJson(h)),
    ));
  }

  /// Lists the challenge (receipts) in which the given hotspot is a
  /// challenger, challengee, or witness.
  ///
  /// [address] is the B58 address of the hotspot.
  Future<HeliumPagedResponse<List<HeliumTransactionPoCReceiptsV1>>>
      listHotspotChallenges(String address) async {
    return _client._doPagedRequest(HeliumPagedRequest(
      path: '/v1/hotspots/$address/challenges',
      extractResponse: (json) => HeliumRequest.mapDataList(
          json, (t) => HeliumTransactionPoCReceiptsV1.fromJson(t)),
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
      path: '/v1/hotspots/$address/rewards',
      parameters: {
        'min_time': minTime,
        'max_time': maxTime,
      },
      extractResponse: (json) => HeliumRequest.mapDataList(
          json, (r) => HeliumHotspotReward.fromJson(r)),
    ));
  }

  /// Returns the total rewards earned for a given hotspot over a given time
  /// range.
  ///
  /// The block that contains the [maxTime] timestamp is excluded from the
  /// result.
  /// [address] is the B58 address of the hotspot.
  Future<HeliumResponse<HeliumHotspotRewardTotal>> getRewardTotal(
      String address, DateTime minTime, DateTime maxTime) async {
    return _client._doRequest(HeliumRequest(
      path: '/v1/hotspots/$address/rewards/sum',
      parameters: {
        'min_time': minTime,
        'max_time': maxTime,
      },
      extractResponse: (json) =>
          HeliumHotspotRewardTotal.fromJson(json['data']),
    ));
  }

  /// Retrieves the list of witnesses for a given hotspot over about the last
  /// 5 days of blocks.
  ///
  /// [address] is the B58 address of the hotspot.
  Future<HeliumResponse<List<HeliumHotspot>>> getWitnesses(String address) {
    return _client._doRequest(HeliumRequest(
      path: '/v1/hotspots/$address/witnesses',
      extractResponse: (json) =>
          HeliumRequest.mapDataList(json, (h) => HeliumHotspot.fromJson(h)),
    ));
  }

  /// Retrieves the list of hotspots the given hotspot witnessed over about the
  /// last 5 days of blocks.
  ///
  /// [address] is the B58 address of the hotspot.
  Future<HeliumResponse<List<HeliumHotspot>>> getWitnessed(String address) {
    return _client._doRequest(HeliumRequest(
      path: '/v1/hotspots/$address/witnessed',
      extractResponse: (json) =>
          HeliumRequest.mapDataList(json, (h) => HeliumHotspot.fromJson(h)),
    ));
  }
}

/// Operations on the Oracle Prices API.
/// https://docs.helium.com/api/blockchain/oracle-prices
class HeliumOraclePricesClient {
  final HeliumClient _client;

  HeliumOraclePricesClient(this._client);

  /// Gets the current Oracle Price and at which block it took effect.
  Future<HeliumResponse<HeliumOraclePrice>> getCurrentOraclePrice() async {
    return _client._doRequest(HeliumRequest(
      path: '/v1/oracle/prices/current',
      extractResponse: (json) => HeliumOraclePrice.fromJson(json['data']),
    ));
  }

  /// Gets the current and historical Oracle Prices and at which block they
  /// took effect.
  Future<HeliumPagedResponse<List<HeliumOraclePrice>>>
      getCurrentAndHistoricalOraclePrices() async {
    return _client._doPagedRequest(HeliumPagedRequest(
      path: '/v1/oracle/prices',
      extractResponse: (json) =>
          HeliumRequest.mapDataList(json, (p) => HeliumOraclePrice.fromJson(p)),
    ));
  }

  /// Gets statistics on Oracle Prices.
  ///
  /// [minTime] is the first time to include in stats.
  /// [maxTime] is the last time to include in stats.
  Future<HeliumResponse<HeliumOraclePriceStats>> getOraclePriceStats(
      DateTime minTime, DateTime maxTime) async {
    return _client._doRequest(HeliumRequest(
      path: '/v1/oracle/prices/stats',
      parameters: {
        'min_time': minTime,
        'max_time': maxTime,
      },
      extractResponse: (json) => HeliumOraclePriceStats.fromJson(json['data']),
    ));
  }

  /// Gets the Oracle Price at a specific block and at which block it
  /// initially took effect.
  Future<HeliumResponse<HeliumOraclePrice>> getOraclePrice(int block) async {
    return _client._doRequest(HeliumRequest(
      path: '/v1/oracle/prices/$block',
      extractResponse: (json) => HeliumOraclePrice.fromJson(json['data']),
    ));
  }

  /// Lists the Oracle Price report transactions for all oracle keys.
  ///
  /// [minTime] is the first time to include data for.
  /// [maxTime] is the last time to include data for.
  /// [limit] is the maximum number of items to return.
  Future<HeliumPagedResponse<List<HeliumTransactionPriceOracleV1>>>
      listOracleActivity({
    DateTime? minTime,
    DateTime? maxTime,
    int? limit,
  }) async {
    return _client._doPagedRequest(HeliumPagedRequest(
      path: '/v1/oracle/activity',
      parameters: {
        'min_time': minTime,
        'max_time': maxTime,
        'limit': limit,
      },
      extractResponse: (json) => HeliumRequest.mapDataList(
          json, (p) => HeliumTransactionPriceOracleV1.fromJson(p)),
    ));
  }

  /// Lists the Oracle Price report transactions for the given oracle key.
  ///
  /// [minTime] is the first time to include data for.
  /// [maxTime] is the last time to include data for.
  /// [limit] is the maximum number of items to return.
  Future<HeliumPagedResponse<List<HeliumTransactionPriceOracleV1>>>
      listOracleActivityForOracle(
    String address, {
    DateTime? minTime,
    DateTime? maxTime,
    int? limit,
  }) async {
    return _client._doPagedRequest(HeliumPagedRequest(
      path: '/v1/oracle/$address/activity',
      parameters: {
        'min_time': minTime,
        'max_time': maxTime,
        'limit': limit,
      },
      extractResponse: (json) => HeliumRequest.mapDataList(
          json, (p) => HeliumTransactionPriceOracleV1.fromJson(p)),
    ));
  }

  /// Returns a list of times when the Oracle Price is expected to change.
  ///
  /// The blockchain operates in "block-time" meaning that blocks can come out
  /// at some schedule close to 1 per minute. Oracles report in
  /// "wall-clock-time", meaning they report what they believe the price should
  /// be. If this method returns one or more prices and times, it indicates
  /// that the chain is expected to adjust the price (based on Oracle reports)
  /// no earlier than the indicated time to the returned price.
  ///
  /// A prediction may not be seen in the blockchain if they are close together
  /// (within 10 blocks) since block times may cause the blockchain to skip
  /// to a next predicted price.
  ///
  /// If no predictions are returned, the current HNT Oracle Price is valid
  /// for at least 1 hour.
  Future<HeliumResponse<List<HeliumOraclePricePredictions>>>
      getPredictedOraclePrices() {
    return _client._doRequest(HeliumPagedRequest(
      path: '/v1/oracle/predictions',
      extractResponse: (json) => HeliumRequest.mapDataList(
          json, (p) => HeliumOraclePricePredictions.fromJson(p)),
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
  final Uri? uri;
  final Exception? cause;

  const HeliumException(this.message, {this.uri, this.cause});

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

    return buf.toString();
  }
}
