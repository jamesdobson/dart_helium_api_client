import 'package:helium_api_client/helium_api_client.dart';

void main() async {
  var client = HeliumClient();
  var resp = await client.hotspots.listHotspotActivity(
    '11cxkqa2PjpJ9YgY9qK3Njn4uSFu6dyK9xV8XE4ahFSqN1YN2db',
    filterTypes: {
      HeliumTransactionType.ADD_GATEWAY_V1,
      HeliumTransactionType.ASSERT_LOCATION_V1,
      HeliumTransactionType.ASSERT_LOCATION_V2,
    },
  );

  var transactions = resp.data;

  while (resp.hasNextPage) {
    resp = await client.getNextPage(resp);
    transactions.addAll(resp.data);
  }

  for (final txn in transactions) {
    print('${txn.type}: ${txn.toJson()}');
  }
}
