import 'package:flutter_test/flutter_test.dart';

import 'package:profit_connect_mobile/core/network/api_base_url_resolver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('resolve caches and returns a reachable base URL', () async {
    final url = await ApiBaseUrlResolver.resolve();
    expect(url, startsWith('http://'));
    expect(url, isNotEmpty);
    expect(ApiBaseUrlResolver.current, url);
  });

  test('resolve is stable across calls', () async {
    final first = await ApiBaseUrlResolver.resolve();
    final second = await ApiBaseUrlResolver.resolve();
    expect(first, second);
  });
}
