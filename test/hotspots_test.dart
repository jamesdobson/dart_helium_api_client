import 'package:helium_api_client/helium_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('Hotspots API Integration Tests', () {
    final client = HeliumClient();

    /// cheesy-brick-mustang in Brookline, MA
    const CHEESY_BRICK_MUSTANG =
        '112S9jVNn8iRvLpm86DHH2TGczv446YEzmXwNoyxG6xg97wLrda2';

    /// tall-plum-griffin in San Francisco, CA
    const TALL_PLUM_GRIFFIN =
        '11cxkqa2PjpJ9YgY9qK3Njn4uSFu6dyK9xV8XE4ahFSqN1YN2db';

    /// City ID for Brookline, MA
    const BROOKLINE_MA = 'YnJvb2tsaW5lbWFzc2FjaHVzZXR0c3VuaXRlZCBzdGF0ZXM';

    test('List hotspots returns a couple pages of results', () async {
      var resp = await client.hotspots.listHotspots();

      expect(resp.data, isNotEmpty);
      expect(resp.hasNextPage, isTrue);
      resp = await client.getNextPage(resp);
      expect(resp.data, isNotEmpty);
    });

    test('Get a known hotspot', () async {
      final resp =
          await client.hotspots.getHotspotForAddress(CHEESY_BRICK_MUSTANG);

      expect(resp.data.address, CHEESY_BRICK_MUSTANG);
      expect(resp.data.name, 'cheesy-brick-mustang');
      expect(resp.data.geocode.cityId, BROOKLINE_MA);
      expect(resp.data.geocode.longCity, 'Brookline');
      expect(resp.data.geocode.longCountry, 'United States');
      expect(resp.data.geocode.shortCountry, 'US');
      expect(resp.data.timestampAdded,
          DateTime.parse('2020-01-20T19:39:17.000000Z'));
    });

    test('Gets hotspots with a given name', () async {
      final resp = await client.hotspots.getHotspotsForName('soft-candy-orca');

      expect(resp.data.length, greaterThan(1));

      final addresses = resp.data.map((e) => e.address).toList();

      expect(addresses,
          contains('11WyZvf5guoDJxHcECTarnjWEZJsmH1pU5466pya98CMVjeD9Ev'));
      expect(addresses,
          contains('112F3zbUkrftbJGnYgJxoHr8XEEkN4LEEqtcPWZmLnAjVNeME9De'));
      expect(addresses,
          contains('11HETWHUhfVFq94KYM4NeioGzjotFdqPVgSamFWf5mQi1SQBMBa'));
    });

    test('Searches for hotspots given a search term', () async {
      final resp = await client.hotspots.searchHotspotsForName('old plum');

      expect(resp.data.length, greaterThan(1));

      final names = resp.data.map((e) => e.name).toList();

      expect(names, contains('old-plum-horse'));
      expect(names, contains('old-plum-loris'));
      expect(names, contains('cold-plum-bird'));
    });

    test('Search for hotspots within a distance of a given lat/lon coordinate',
        () async {
      // Example from https://docs.helium.com/api/blockchain/hotspots#hotspot-location-distance-search
      final resp = await client.hotspots.searchHotspotsByDistance(
          38.12129445739087, -122.52885074963571, 1000);

      expect(resp.data.map((e) => e.name),
          containsAll(['curly-berry-coyote', 'immense-eggplant-stallion']));
    });

    test('Search for hotspots within a given lat/lon box', () async {
      // Example from https://docs.helium.com/api/blockchain/hotspots#hotspot-location-box-search
      final resp = await client.hotspots.searchHotspotsByBox(
          38.0795392, -122.5671627, 38.1588012, -122.5046937);

      expect(resp.data.map((e) => e.name),
          containsAll(['curly-berry-coyote', 'immense-eggplant-stallion']));
    });

    test('Search for hotspots within a given h3 index', () async {
      // Example from https://docs.helium.com/api/blockchain/hotspots#hotspots-for-h3-index
      final resp =
          await client.hotspots.searchHotspotsByH3Index('882aa38c2bfffff');

      expect(resp.data.map((e) => e.name), contains('zesty-cinnamon-lobster'));
    });

    test('List activity for a given hotspot', () async {
      var resp = await client.hotspots.listHotspotActivity(
        TALL_PLUM_GRIFFIN,
        filterTypes: {
          HeliumTransactionType.ADD_GATEWAY_V1,
          HeliumTransactionType.ASSERT_LOCATION_V1
        },
      );
      var transactions = resp.data;

      while (resp.hasNextPage) {
        resp = await client.getNextPage(resp);
        transactions.addAll(resp.data);
      }

      expect(transactions, hasLength(2));
      var txn0 = transactions[0] as HeliumTransactionAssertLocationV1;
      var txn1 = transactions[1] as HeliumTransactionAddGatewayV1;
      expect(txn0.type, HeliumTransactionType.ASSERT_LOCATION_V1);
      expect(txn0.height, 395577);
      expect(txn0.location, '8c283082a1a19ff');
      expect(txn1.type, HeliumTransactionType.ADD_GATEWAY_V1);
      expect(txn1.height, 395575);
      expect(txn1.fee, 65000);
      expect(txn1.stakingFee, 4000000);
      print(txn1.hash);
    });

    test('Get activity counts for a given hotspot', () async {
      var resp =
          await client.hotspots.getHotspotActivityCounts(TALL_PLUM_GRIFFIN);

      expect(resp.data[HeliumTransactionType.ADD_GATEWAY_V1], 1);
      expect(resp.data[HeliumTransactionType.ASSERT_LOCATION_V1], 1);
      expect(resp.data[HeliumTransactionType.REWARDS_V1], 1170);
      expect(resp.data[HeliumTransactionType.REWARDS_V2], 0);
    });

    test('Get selected activity counts for a given hotspot', () async {
      var resp = await client.hotspots
          .getHotspotActivityCounts(TALL_PLUM_GRIFFIN, filterTypes: {
        HeliumTransactionType.REWARDS_V1,
        HeliumTransactionType.ADD_GATEWAY_V1,
        HeliumTransactionType.TOKEN_BURN_V1
      });

      expect(resp.data[HeliumTransactionType.ADD_GATEWAY_V1], 1);
      expect(resp.data[HeliumTransactionType.REWARDS_V1], 1170);
      expect(resp.data[HeliumTransactionType.TOKEN_BURN_V1], 0);
      expect(resp.data, hasLength(3));
    });

    test('Currently elected hotspots is empty', () async {
      final resp = await client.hotspots.getCurrentlyElectedHotspots();

      expect(resp.data, isEmpty);
    });

    test('Get rewards for a known hotspot', () async {
      var resp = await client.hotspots.getRewards(CHEESY_BRICK_MUSTANG,
          DateTime.utc(2021, 9, 5), DateTime.utc(2021, 9, 6));

      var rewards = resp.data;

      while (resp.hasNextPage) {
        resp = await client.getNextPage(resp);
        rewards.addAll(resp.data);
      }

      expect(rewards, hasLength(32));
    });

    test('Get rewards for a known hotspot during specific hours', () async {
      var resp = await client.hotspots.getRewards(
        CHEESY_BRICK_MUSTANG,
        DateTime.parse('2021-09-05T06:02:38.000000Z'),
        DateTime.parse('2021-09-05T12:08:13.000000Z'),
      );

      var rewards = resp.data;

      while (resp.hasNextPage) {
        resp = await client.getNextPage(resp);
        rewards.addAll(resp.data);
      }

      expect(rewards, hasLength(10));
    });

    test('Get rewards for a known hotspot during specific hours using a TZ',
        () async {
      var resp = await client.hotspots.getRewards(
        CHEESY_BRICK_MUSTANG,
        DateTime.parse('2021-09-05T01:02:38.000000-0500'),
        DateTime.parse('2021-09-05T07:08:13.000000-0500'),
      );

      var rewards = resp.data;

      while (resp.hasNextPage) {
        resp = await client.getNextPage(resp);
        rewards.addAll(resp.data);
      }

      expect(rewards, hasLength(10));
    });
  });
}
