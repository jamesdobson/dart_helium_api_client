import 'dart:collection';

import 'package:helium_api_client/helium_api_client.dart';

/// The price oracles, as published in the Helium docs.
/// See: https://docs.helium.com/blockchain/oracles/
const PUBLISHED_ORACLES = {
  '13Btezbvbwr9LhKmDQLgBnJUgjhZighEjNPLeu79dqBbmXRwoWm',
  '13CFFcmPtMvNQCpWQRXCTqXPnXtcsibDWVwiQRKpUCt4nqtF7RE',
  '1431WVQvoV7RAJpoLCaBrTKner1Soed4bk69DddcrHUTCWHV6pj',
  '136n9BEbreGUNgXJWtyzkBQcXiNzdMQ5GBoP8L2J6ZReFUAwUjy',
  '14sqAYg1qxzjKTtyHLYZdH6yDtA3KgyoARhWN1cvLZ94dZw5vEc',
  '145J6Aye86pKTJrUHREiXu7qqppZBcWY1bvWo8id7ZjxyuainYj',
  '14t33QjopqCUVr8FXG4sr58FTu5HnPwGBLPrVK1BFXLR3UsnQSn',
  '14EzXp4i1xYA7SNyim6R4J5aXN1yHYKNiPrrJ2WEvoDnxmLgaCg',
  '147yRbowD1krUCC1DhhSMhpFEqnkwb26mHBow5nk9q43AakSHNA',
};

/// Finds all price oracles, when they've been in service, and how many
/// submissions they've made
void main() async {
  final client = HeliumBlockchainClient();
  var resp = await client.prices.listOracleActivity();
  final earliestRecordTimes = HashMap<String, DateTime>();
  final latestRecordTimes = HashMap<String, DateTime>();
  final recordCounts = HashMap<String, int>();

  updateTally(resp.data, earliestRecordTimes, latestRecordTimes, recordCounts);

  while (resp.hasNextPage) {
    resp = await client.getNextPage(resp);

    if (resp.data.isEmpty) {
      continue;
    }

    updateTally(
        resp.data, earliestRecordTimes, latestRecordTimes, recordCounts);
  }

  print('\n\n===== Price Oracle Report =====');

  for (final oracle in recordCounts.keys) {
    final earliest = earliestRecordTimes[oracle]!;
    final latest = latestRecordTimes[oracle]!;

    if (PUBLISHED_ORACLES.contains(oracle)) {
      print('$oracle (KNOWN)');
    } else {
      print(oracle);
    }

    print('    Reports:  ${recordCounts[oracle]}');
    print('    Earliest: $earliest');
    print('    Latest:   $latest');
    print('    Duration: ${latest.difference(earliest)}');
    print('');
  }
}

void updateTally(
  List<HeliumTransactionPriceOracleV1> txns,
  Map<String, DateTime> earliestRecordTimes,
  Map<String, DateTime> latestRecordTimes,
  Map<String, int> recordCounts,
) {
  print('Processing ${txns.length} record(s)... (${txns.first.time})');

  for (final t in txns) {
    recordCounts.update(t.publicKey, (v) => v + 1, ifAbsent: () => 0);
    earliestRecordTimes.update(
        t.publicKey, (v) => v.isAfter(t.time) ? t.time : v,
        ifAbsent: () => t.time);
    latestRecordTimes.update(
        t.publicKey, (v) => v.isBefore(t.time) ? t.time : v,
        ifAbsent: () => t.time);
  }
}
