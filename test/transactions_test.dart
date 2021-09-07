import 'package:helium_api_client/helium_api_client.dart';
import 'package:test/test.dart';

void main() {
  group('Transactions API Integration Tests', () {
    final client = HeliumClient();

    test('Get a specific transaction of known type', () async {
      var resp = await client.transactions
          .getTransaction('VSO7aKH9uiCuWUNzb5rPddlq-m-kvaMeVeufUQisjbo');

      expect(resp.data.type, HeliumTransactionType.ADD_GATEWAY_V1);

      final txn = resp.data as HeliumTransactionAddGatewayV1;

      expect(txn.stakingFee, 4000000);
    });

    test('Get a specific transaction of unknown type (genesis gateway)',
        () async {
      var resp = await client.transactions
          .getTransaction('iEDrnBsQByoty59AqR1w44BQmjKpT4XUnlewohE_ZsI');

      expect(resp.data.type, HeliumTransactionType.get('gen_gateway_v1'));

      final txn = resp.data as HeliumTransactionUnknown;

      expect(txn.data['staking_fee'], 1);
      expect(txn.data['gateway'],
          '112aVmnM3bJsA1gM9fjNPSvAeY4LkrMzNJdHRfTdtZ9nTgWZgncs');
    });
  });
}
