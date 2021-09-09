# Helium API Client Library for Dart
Provides a client for the Helium API in the Dart language.


## Developers

### Run tests (does code generation)

```sh
dart run build_runner test
```

### Generate Code

```sh
dart run build_runner build
```

## Usage

A simple usage example:

```dart
import 'package:helium_api_client/helium_api_client.dart';

main() {
  var awesome = new Awesome();
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme

## TODO

* Implement the Oracle Prices API
* Write an example that computes hotspot earnings in USD
* Add exceptions for 4xx, 5xx, etc.
* Add usage documentation to this README
* Determine where pub.dev documentation comes from and set it up
* Publish to pub.dev
* Start downloading the blockchain
* Run the blockchain API locally
* Fix the blockchain API handling of speculative_nonce during distance search (we need a new _to_json method)
* Submit a PR for blockchain API speculative_nonce bug (might also have to submit a bug)
