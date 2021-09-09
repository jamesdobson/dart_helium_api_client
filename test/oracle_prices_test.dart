import 'package:helium_api_client/helium_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('Oracle Prices API Integration Tests', () {
    final client = HeliumClient();

    test('Get the current oracle price', () async {
      var resp = await client.prices.getCurrentOraclePrice();

      expect(resp.data.block, greaterThan(0));
      expect(resp.data.price, greaterThan(0));
      expect(resp.data.timestamp.isBefore(DateTime.now()), isTrue);
    });

    test('Get the current and some historic oracle prices', () async {
      var resp = await client.prices.getCurrentAndHistoricalOraclePrices();
      var prices = resp.data;

      expect(resp.hasNextPage, isTrue);
      resp = await client.getNextPage(resp);
      prices.addAll(resp.data);

      // Verify that the oracle prices API orders the prices from newest to
      // oldest.
      var laterPrice = prices.first;
      for (final price in prices.skip(1)) {
        expect(price.block, lessThan(laterPrice.block));
        expect(price.timestamp.isBefore(laterPrice.timestamp), isTrue);
        expect(price.price, greaterThan(0));
      }
    });
  });
}
