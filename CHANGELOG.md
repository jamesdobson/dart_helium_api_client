
# 1.0.0

- Removed some private methods that accidentally escaped into the public API.
- Removed dependency on dart:io to enable js support.
- Updated README with basic usage information.
- Documented more of the public API.
- Renamed HeliumClient to HeliumBlockchainClient.
- Renamed HeliumPoCReceiptsPathElement to HeliumPoCPathElement.
- Renamed HeliumPoCReceiptsWitness to HeliumPoCWitness.
- Renamed HeliumPoCReceiptsReceipt to HeliumPoCReceipt.
- Renamed public methods on HeliumHotspotClient, HeliumOraclePricesClient, and HeliumTransactionsClient.

# 0.1.0

- Initial version.
- Supports 3 APIs: Hotspots, Oracle Prices, and Transactions.
- API method names and class names are beta and may be adjusted soon in a new major version.
