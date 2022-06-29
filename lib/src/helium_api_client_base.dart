import 'package:helium_api_client/src/model/hotspots.dart';
import 'package:helium_api_client/src/model/oracle_prices.dart';
import 'package:helium_api_client/src/model/transactions.dart';

import 'common.dart';
import 'request.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// A client for the Helium Blockchain API.
///
/// For information about the API itself, see:
/// https://docs.helium.com/api/blockchain/introduction
class HeliumBlockchainClient {
  /// Stable, scalable production service. Connected to mainnet.
  static const String STABLE_URL = 'https://api.helium.io';

  /// Beta, scalable endpoint for new features and tests. Currently connected
  /// to mainnet. This endpoint is used for feature dvelopment. Submitted
  /// transactions may get dropped.
  static const String BETA_URL = 'https://api.helium.wtf';

  final Uri _base;

  /// Operations on the Hotspots API. (https://docs.helium.com/api/blockchain/hotspots)
  late final HeliumHotspotClient hotspots;

  /// Operations on the Transactions API. (https://docs.helium.com/api/blockchain/transactions)
  late final HeliumTransactionsClient transactions;

  /// Operations on the Oracle Prices API. (https://docs.helium.com/api/blockchain/oracle-prices)
  late final HeliumOraclePricesClient prices;

  /// Creates a new client for the Helium Blockchain API.
  ///
  /// The client uses the Stable API endpoint by default. To use a different
  /// API endpoint, specify [baseUrl]. For example, to use the Beta API, set
  /// [baseUrl] to [BETA_URL].
  HeliumBlockchainClient({
    String baseUrl = STABLE_URL,
  }) : _base = Uri.parse(baseUrl) {
    hotspots = HeliumHotspotClient._(this);
    prices = HeliumOraclePricesClient._(this);
    transactions = HeliumTransactionsClient._(this);
  }

  /// Gets the page of results following the given page.
  ///
  /// Check [hasNextPage] on the response object before calling this method.
  Future<HeliumPagedResponse<T>> getNextPage<T>(
      final HeliumPagedResponse<T> response) async {
    return _doPagedRequest(response._getNextPageRequest());
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

    final T data;

    try {
      data = req.extractResponse(result);
    } catch (e) {
      throw HeliumException('Unable to parse response: "${e.toString()}"',
          uri: uri, cause: e, body: resp.body);
    }

    return HeliumResponse<T>._(
      data: data,
    );
  }

  Future<HeliumPagedResponse<T>> _doPagedRequest<T>(
      final HeliumPagedRequest<T> req) async {
    final uri = req.getUri(_base);
    final resp = await _do(uri);
    final Map<String, dynamic> result = json.decode(resp.body);
    final cursor = result['cursor'] as String?;

    final T data;

    try {
      data = req.extractResponse(result);
    } catch (e) {
      throw HeliumException('Unable to parse response: "${e.toString()}"',
          uri: uri, cause: e, body: resp.body);
    }

    return HeliumPagedResponse<T>._(
      request: req,
      data: data,
      cursor: cursor,
    );
  }

  Future<http.Response> _do<T>(final Uri uri) async {
    final http.Response resp;

    try {
      resp = await http
          .get(uri, headers: {'User-Agent': '$PACKAGE_URL:$PACKAGE_VERSION'});
    } catch (e) {
      throw HeliumException('Network error', uri: uri, cause: e);
    }

    if (resp.statusCode >= 400) {
      throw HeliumException(
        'HTTP error (${resp.statusCode} ${resp.reasonPhrase})',
        uri: uri,
        httpStatusCode: resp.statusCode,
        httpStatusReason: resp.reasonPhrase,
      );
    }

    if (resp.statusCode >= 300) {
      throw HeliumException(
        'Unexpected HTTP redirect (${resp.statusCode})',
        uri: uri,
        httpStatusCode: resp.statusCode,
        httpStatusReason: resp.reasonPhrase,
      );
    }

    return resp;
  }
}

/// A response from the Helium API.
class HeliumResponse<T> {
  /// The response data.
  final T data;

  HeliumResponse._({
    required this.data,
  });
}

/// A one-page response from the Helium API.
///
/// To retrieve the next page, pass this to the
/// [HeliumBlockchainClient.getNextPage] method.
class HeliumPagedResponse<T> extends HeliumResponse<T> {
  final HeliumPagedRequest<T> _request;
  final String? _cursor;

  HeliumPagedResponse._(
      {required data, required HeliumPagedRequest<T> request, String? cursor})
      : _request = request,
        _cursor = cursor,
        super._(data: data);

  /// True if there is another page of results; false otherwise.
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
///
/// https://docs.helium.com/api/blockchain/hotspots
class HeliumHotspotClient {
  final HeliumBlockchainClient _client;

  HeliumHotspotClient._(this._client);

  /// Lists known hotspots as registered on the blockchain.
  ///
  /// The [modeFilter] parameter can be used to filter hotspots by how they
  /// were added to the blockchain.
  Future<HeliumPagedResponse<List<HeliumHotspot>>> getAll(
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
  Future<HeliumResponse<HeliumHotspot>> get(String address) async {
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
  Future<HeliumResponse<List<HeliumHotspot>>> getByName(String name) async {
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
  Future<HeliumResponse<List<HeliumHotspot>>> findByName(String query) async {
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
  Future<HeliumPagedResponse<List<HeliumHotspot>>> getByDistance(
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
  Future<HeliumPagedResponse<List<HeliumHotspot>>> getByBox(
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
  Future<HeliumPagedResponse<List<HeliumHotspot>>> getByH3Index(
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
  Future<HeliumPagedResponse<List<HeliumTransaction>>> getActivity(
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
  Future<HeliumResponse<Map<HeliumTransactionType, int>>> getActivityCounts(
      String address,
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
      getElections(String address) async {
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
      getPoCReceipts(String address) async {
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
///
/// https://docs.helium.com/api/blockchain/oracle-prices
class HeliumOraclePricesClient {
  final HeliumBlockchainClient _client;

  HeliumOraclePricesClient._(this._client);

  /// Gets the current Oracle Price and at which block it took effect.
  Future<HeliumResponse<HeliumOraclePrice>> getCurrent() async {
    return _client._doRequest(HeliumRequest(
      path: '/v1/oracle/prices/current',
      extractResponse: (json) => HeliumOraclePrice.fromJson(json['data']),
    ));
  }

  /// Gets the current and historical Oracle Prices and at which block they
  /// took effect.
  Future<HeliumPagedResponse<List<HeliumOraclePrice>>>
      getCurrentAndHistoric() async {
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
  Future<HeliumResponse<HeliumOraclePriceStats>> getStats(
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
  Future<HeliumResponse<HeliumOraclePrice>> getByBlock(int block) async {
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
      getAllActivity({
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
  Future<HeliumPagedResponse<List<HeliumTransactionPriceOracleV1>>> getActivity(
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
  Future<HeliumResponse<List<HeliumOraclePricePrediction>>> getPredicted() {
    return _client._doRequest(HeliumPagedRequest(
      path: '/v1/oracle/predictions',
      extractResponse: (json) => HeliumRequest.mapDataList(
          json, (p) => HeliumOraclePricePrediction.fromJson(p)),
    ));
  }
}

/// Operations on the Transactions API.
///
/// https://docs.helium.com/api/blockchain/transactions
class HeliumTransactionsClient {
  final HeliumBlockchainClient _client;

  HeliumTransactionsClient._(this._client);

  /// Fetches the transaction for a given hash.
  Future<HeliumResponse<HeliumTransaction>> get(String hash) async {
    return _client._doRequest(HeliumRequest(
      path: '/v1/transactions/$hash',
      extractResponse: (json) => HeliumTransaction.fromJson(json['data']),
    ));
  }
}
