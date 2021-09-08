import 'package:helium_api_client/helium_api_client.dart';

void main() async {
  var address =
      '11yXFNu9Je9gvVfyuA8jS8z6faNcZW7kPwPApWYThTk416LGmU'; // acidic red mouse
  //'11cxkqa2PjpJ9YgY9qK3Njn4uSFu6dyK9xV8XE4ahFSqN1YN2db'; // tall plum griffin
  var client = HeliumClient();
  var hotspotResp = await client.hotspots.getHotspotForAddress(address);

  print('Current:');
  print('\tHotspot: ${hotspotResp.data.name}');
  print('\tLocation: ${hotspotResp.data.location}');
  print('\tLocation Hex: ${hotspotResp.data.locationHex}');
  print('\tGPS: ${hotspotResp.data.lat}°N / ${hotspotResp.data.lng}°E');
  print('\tCountry: ${hotspotResp.data.geocode.longCountry}');
  print('\tState: ${hotspotResp.data.geocode.longState}');
  print('\tCity: ${hotspotResp.data.geocode.longCity}');
  print('\tElevation: ${hotspotResp.data.elevation} m');
  print('\tGain: ${hotspotResp.data.gain / 10} dBi');
  print('');
  print('===== Location History =====');

  var resp = await client.hotspots.listHotspotActivity(
    address,
    filterTypes: {
      HeliumTransactionType.ASSERT_LOCATION_V1,
      HeliumTransactionType.ASSERT_LOCATION_V2,
    },
  );

  displayLocationAssertions(resp.data);

  while (resp.hasNextPage) {
    resp = await client.getNextPage(resp);
    displayLocationAssertions(resp.data);
  }
}

void displayLocationAssertions(List<HeliumTransaction> transactions) {
  for (final txn in transactions) {
    if (txn is HeliumTransactionAssertLocationV1) {
      print('[${txn.height}] v1 Record:');
      print('\tLocation: ${txn.location}');
      print('\tGPS: ${txn.lat}°N / ${txn.lng}°E');
      print('\tTime: ${txn.time}');
    } else if (txn is HeliumTransactionAssertLocationV2) {
      print('[${txn.height}] v2 Record:');
      print('\tLocation: ${txn.location}');
      print('\tGPS: ${txn.lat}°N / ${txn.lng}°E');
      print('\tElevation: ${txn.elevation} m');
      print('\tGain: ${txn.gain / 10} dBi');
      print('\tTime: ${txn.time}');
    }
  }
}
