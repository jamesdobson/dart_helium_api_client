# Helium API Client Library for Dart
Provides a client for the [Helium API][api] in the Dart language.

Currently, it supports 3 sections of the Blockchain API: Hotspots,
Oracle Prices, and Transactions.

[api]: https://docs.helium.com/api/blockchain/introduction

## Usage
Get a client instance:

```dart
final client = HeliumBlockchainClient();
```

You can make API calls on the methods of:
* `client.hotspots`
* `client.prices`
* `client.transactions`

API calls return a `HeliumResponse` object. You can get the results
from the `data` property on the response.

```dart
final client = HeliumBlockchainClient();
var resp = await client.prices.getCurrent();
print(resp.data.price);
```

If the API is paged, it returns a `HeliumPagedResponse`. To get the
next page of results (also a `HeliumPagedResponse` object), call
`getNextPage` passing the previous page response:

```dart
final client = HeliumBlockchainClient();
var resp = await client.prices.getCurrentAndHistoric();
print(resp.data.length);
resp = await client.getNextPage(resp);
print(resp.data.length);
resp = await client.getNextPage(resp);
print(resp.data.length);
// ...
```

There is no need to close or destroy any objects when done.

## Features and bugs
Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/jamesdobson/dart_helium_api_client/issues

## Contributing to this library

### Run tests (does code generation)
```sh
dart run build_runner test
```

### Generate Code
```sh
dart run build_runner build
```
