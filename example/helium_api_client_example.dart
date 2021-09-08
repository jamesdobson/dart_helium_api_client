import 'package:helium_api_client/helium_api_client.dart';

void main() async {
  var client = HeliumClient();
  var resp = await client.hotspots.getRewards(
    '11yXFNu9Je9gvVfyuA8jS8z6faNcZW7kPwPApWYThTk416LGmU',
    DateTime(2021, 9, 7),
    DateTime(2021, 9, 8),
  );

  var rewards = resp.data;

  while (resp.hasNextPage) {
    resp = await client.getNextPage(resp);
    rewards.addAll(resp.data);
  }

  for (final r in rewards) {
    print(r.toJson());
  }
}
