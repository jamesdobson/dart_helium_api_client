import 'package:helium_api_client/helium_api_client.dart';

void main() async {
  var client = HeliumClient();
  var resp = await client.hotspots.getRewards(
    '112tumH88eJZWup7fH9iVhqyf1NtmtBzwsiTXBFmX4Mehoszmz5V',
    DateTime.parse('2021-08-30'),
    DateTime.parse('2021-09-01'),
  );
  print(resp.data);

  if (resp.hasNextPage) {
    var resp2 = await client.getNextPage(resp);

    print(resp2.data);

    for (var reward in resp2.data) {
      print(reward.amount);
    }
  }

  var resp3 = await client.hotspots.getHotspotForAddress(
      '112tumH88eJZWup7fH9iVhqyf1NtmtBzwsiTXBFmX4Mehoszmz5V');

  print(resp3.data);

  var resp4 = await client.hotspots.getCurrentlyElectedHotspots();

  print(resp4.data);

  var resp5 = await client.hotspots.listHotspots(filterModes: {
    HeliumHotspotFilterMode.LIGHT,
    HeliumHotspotFilterMode.DATA_ONLY
  });

  print('${resp5.data.length} - ${resp5.data.first.name}');

  while (resp5.hasNextPage) {
    resp5 = await client.getNextPage(resp5);
    print('${resp5.data.length} - ${resp5.data.first.name}');
  }

  var resp6 = await client.hotspots.getHotspotsForName('cold-plum-bird');

  print(resp6.data.length);

  for (var hotspot in resp6.data) {
    print('${hotspot.address}: ${hotspot.geocode.longCity}');
  }
}
