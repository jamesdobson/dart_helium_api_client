import 'package:helium_api_client/helium_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('Error Handling Tests', () {
    test('Error 404 not found', () async {
      final client = HeliumClient(baseUrl: 'https://api.helium.io/err');

      try {
        await client.prices.getCurrentOraclePrice();
        fail('Expected a HeliumException');
      } on HeliumException catch (e) {
        expect(e.message, contains('404'));
        expect(e.uri.toString(), contains('err'));
      }

      try {
        await client.prices.listOracleActivity();
        fail('Expected a HeliumException');
      } on HeliumException catch (e) {
        expect(e.message, contains('404'));
        expect(e.uri.toString(), contains('err'));
      }
    });

    test('Error during host lookup', () async {
      final client = HeliumClient(baseUrl: 'https://apierr.helium.io');

      try {
        await client.prices.getCurrentOraclePrice();
        fail('Expected a HeliumException');
      } on HeliumException catch (e) {
        expect(e.toString(), contains('Network error'));
        expect(e.uri.toString(), contains('apierr'));
      }

      try {
        await client.prices.listOracleActivity();
        fail('Expected a HeliumException');
      } on HeliumException catch (e) {
        expect(e.toString(), contains('Network error'));
        expect(e.uri.toString(), contains('apierr'));
      }
    });
  });
}