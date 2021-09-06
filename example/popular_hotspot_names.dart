import 'dart:collection';

import 'package:helium_api_client/helium_api_client.dart';

/// Finds all hotspots that map to the same name as at least one other hotspot.
void main() async {
  final client = HeliumClient();
  final tally = HashMap<String, int>();
  var response = await client.hotspots.listHotspots();

  addToTally(tally, response.data);

  while (response.hasNextPage) {
    response = await client.getNextPage(response);
    addToTally(tally, response.data);
  }

  print('Done reading API.');

  var collisions = tally.entries.where((e) => e.value > 1);

  for (final collision in collisions) {
    print('${collision.key}: ${collision.value}');
  }

  print('Done.');
}

void addToTally(Map<String, int> tally, List<HeliumHotspot> hotspots) {
  print(
      'Processing ${hotspots.length} records (${tally.length} unique hotspot names so far)');
  for (final hotspot in hotspots) {
    tally.update(hotspot.name, (count) => count + 1, ifAbsent: () => 1);
  }
}
