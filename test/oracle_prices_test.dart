import 'package:helium_api_client/helium_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('Oracle Prices API Integration Tests', () {
    final client = HeliumClient();

    test('Get the current Oracle Price', () async {
      var resp = await client.prices.getCurrentOraclePrice();

      expect(resp.data.block, greaterThan(0));
      expect(resp.data.price, greaterThan(0));
      expect(resp.data.timestamp.isBefore(DateTime.now()), isTrue);
    });

    test('Get the current and some historic Oracle Prices', () async {
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

    test('Validate basic properties of Oracle Price statistics endpoint',
        () async {
      final endTime = DateTime.now();
      final startTime = endTime.subtract(Duration(days: 7));
      var resp = await client.prices.getOraclePriceStats(startTime, endTime);

      expect(resp.data.avg, greaterThan(0));
      expect(resp.data.avg, greaterThanOrEqualTo(resp.data.min));
      expect(resp.data.avg, lessThanOrEqualTo(resp.data.max));

      expect(resp.data.median, greaterThan(0));
      expect(resp.data.median, greaterThanOrEqualTo(resp.data.min));
      expect(resp.data.median, lessThanOrEqualTo(resp.data.max));

      expect(resp.data.max, greaterThan(0));
      expect(resp.data.max, greaterThanOrEqualTo(resp.data.min));

      expect(resp.data.min, greaterThan(0));

      expect(resp.data.stddev, greaterThanOrEqualTo(0));
    });

    test('Verify Oracle Price statistics for a known time period', () async {
      var resp = await client.prices.getOraclePriceStats(
        DateTime.utc(2021, 8, 1),
        DateTime.utc(2021, 8, 31, 23, 59, 59),
      );

      expect(resp.data.avg, closeTo(19.781, 0.001));
      expect(resp.data.max, closeTo(26.0, 0.1));
      expect(resp.data.median, closeTo(20.815, 0.001));
      expect(resp.data.min, closeTo(12.0, 0.1));
      expect(resp.data.stddev, closeTo(3.880, 0.001));
    });

    test('Get the Oracle Price for some known blocks', () async {
      var resp = await client.prices.getOraclePrice(1004127);

      expect(resp.data.price, 2160778750);
      expect(resp.data.block, 1004120);
      expect(resp.data.timestamp, DateTime.utc(2021, 9, 9, 21, 8, 36));

      resp = await client.prices.getOraclePrice(1);

      expect(resp.data.price, isZero);
      expect(resp.data.block, 1);
      expect(resp.data.timestamp.millisecondsSinceEpoch, isZero);
    });

    test('Get first page of Oracle Price transactions from the blockchain',
        () async {
      var resp = await client.prices.listOracleActivity();

      expect(resp.data, isNotEmpty);
      expect(resp.hasNextPage, isTrue);
    });

    test('Get Oracle Price transactions for a known time period', () async {
      final minTime = DateTime.utc(2021, 9, 1);
      final maxTime = DateTime.utc(2021, 9, 1, 1);
      var resp = await client.prices
          .listOracleActivity(minTime: minTime, maxTime: maxTime);
      var txns = resp.data;

      while (resp.hasNextPage) {
        resp = await client.getNextPage(resp);
        txns.addAll(resp.data);
      }

      expect(txns, hasLength(15));
      expect(txns.first.height, 991127);
      expect(txns.first.publicKey,
          '145J6Aye86pKTJrUHREiXu7qqppZBcWY1bvWo8id7ZjxyuainYj');

      // Make the request again, with a limit.
      resp = await client.prices
          .listOracleActivity(minTime: minTime, maxTime: maxTime, limit: 3);
      txns = resp.data;

      while (resp.hasNextPage) {
        resp = await client.getNextPage(resp);
        txns.addAll(resp.data);
      }

      expect(txns, hasLength(3));
      expect(txns.first.height, 991127);
    });
  });
}
