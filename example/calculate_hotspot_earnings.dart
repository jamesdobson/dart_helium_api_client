import 'package:helium_api_client/helium_api_client.dart';

final String address = '11yXFNu9Je9gvVfyuA8jS8z6faNcZW7kPwPApWYThTk416LGmU';
final DateTime endTime = DateTime(2022, 1, 1);
final DateTime startTime = DateTime(2021, 1, 1);
const int PRICE_RESOLUTION = 100000000;

void main() async {
  final client = HeliumClient();
  final rewards = <HeliumHotspotReward>[];
  var resp = await client.hotspots.getRewards(address, startTime, endTime);

  rewards.addAll(resp.data);
  print('Retrieved ${rewards.length}...');

  while (resp.hasNextPage) {
    resp = await client.getNextPage(resp);
    rewards.addAll(resp.data);
    print('Retrieved ${rewards.length}...');
  }

  var sumUSD = BigInt.zero;
  var sumHNT = BigInt.zero;

  print(
      'Block,Timestamp,Reward (HNT),HNT Price in hundred-millionths of USD,Approx reward in USD');
  for (final r in rewards) {
    final resp = await client.prices.getOraclePrice(r.block);
    final hntPrice = resp.data.price;
    final usdAmount = hntPrice / PRICE_RESOLUTION * r.amount / PRICE_RESOLUTION;

    print(
      '${r.block},${timestampForCSV(r.timestamp)},${r.amount},$hntPrice,${usdAmount.toStringAsFixed(2)}',
    );

    final hntPriceBones = BigInt.from(hntPrice);
    final hntAmount = BigInt.from(r.amount);
    sumHNT += hntAmount;
    sumUSD += hntAmount * hntPriceBones;
  }

  final resolution = BigInt.from(PRICE_RESOLUTION);
  final resolutionSquared = resolution * resolution;

  print(
      'Total earnings: ${(sumHNT / resolution).toStringAsFixed(3)} HNT (\$${(sumUSD / resolutionSquared).toStringAsFixed(2)})');
}

String timestampForCSV(DateTime t) {
  return '${t.year}-${pad(t.month)}-${pad(t.day)} ${pad(t.hour)}:${pad(t.minute)}:${pad(t.second)}';
}

String pad(int value, [int width = 2]) {
  return value.toString().padLeft(width, '0');
}
