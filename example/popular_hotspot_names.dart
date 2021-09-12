import 'dart:collection';

import 'package:helium_api_client/helium_api_client.dart';

/// Finds all hotspots that map to the same name as at least one other hotspot.
void main() async {
  final client = HeliumBlockchainClient();
  final tally = HashMap<String, int>();
  var response = await client.hotspots.getAll();

  addToTally(tally, response.data);

  while (response.hasNextPage) {
    response = await client.getNextPage(response);
    addToTally(tally, response.data);
  }

  print('Done reading API.');

  final collisions = tally.entries.where((e) => e.value > 1);
  final reverseCollisions = <int, List<String>>{};

  for (final collision in collisions) {
    reverseCollisions.update(
      collision.value,
      (value) => value + [collision.key],
      ifAbsent: () => [collision.key],
    );
  }

  final sorted = reverseCollisions.keys.toList();

  sorted.sort((a, b) => a.compareTo(b));

  for (final count in sorted) {
    print('\n===== Collisions of $count Hotspot Names =====');
    for (final collision in reverseCollisions[count]!) {
      print(collision);
    }
  }

  print('\nDone.');
}

void addToTally(Map<String, int> tally, List<HeliumHotspot> hotspots) {
  print(
      'Processing ${hotspots.length} records (${tally.length} unique hotspot names so far)');
  for (final hotspot in hotspots) {
    tally.update(hotspot.name, (count) => count + 1, ifAbsent: () => 1);
  }
}
