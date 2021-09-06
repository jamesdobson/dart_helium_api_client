import 'package:helium_api_client/helium_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('Hotspot API Integration Tests', () {
    final client = HeliumClient();

    /// cheesy-brick-mustang in Brookline, MA
    const CHEESY_BRICK_MUSTANG =
        '112S9jVNn8iRvLpm86DHH2TGczv446YEzmXwNoyxG6xg97wLrda2';

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
