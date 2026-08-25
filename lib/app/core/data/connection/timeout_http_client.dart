import 'dart:async';

import 'package:http/http.dart' as http;

class TimeoutHttpClient extends http.BaseClient {
  TimeoutHttpClient({Duration? timeout})
      : timeout = timeout ?? const Duration(seconds: 5),
        _inner = http.Client();

  final Duration timeout;
  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _inner.send(request).timeout(timeout);

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
