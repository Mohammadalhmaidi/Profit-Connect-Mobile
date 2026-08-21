import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Auto‑detects the backend base URL so the app works on any emulator
/// (Android Studio, LDPlayer, Genymotion, iOS simulator) and on real
/// phones/desktops as long as the backend is running on the same network.
class ApiBaseUrlResolver {
  ApiBaseUrlResolver._();

  static const int defaultPort = 5000;
  static const Duration _probeTimeout = Duration(milliseconds: 700);
  static const Duration _scanProbeTimeout = Duration(milliseconds: 250);
  static const int _scanBatchSize = 24;
  static String? _resolved;

  /// The base URL to use. Falls back to the .env value, then to a
  /// platform default, when auto-detection fails.
  static String get current =>
      _resolved ?? (_envApiBaseUrl() ?? _platformDefault());

  static String _platformDefault() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$defaultPort';
    }
    return 'http://localhost:$defaultPort';
  }

  /// Probes candidate hosts and caches the first one that responds.
  static Future<String> resolve() async {
    if (_resolved != null) return _resolved!;
    final outcomes = await Future.wait([
      for (final url in await _candidates()) _probe(url, _probeTimeout),
    ]);
    _resolved = _firstHit(outcomes);
    _resolved ??= await _subnetScan();
    return current;
  }

  static Future<List<String>> _candidates() async {
    final candidates = <String>[];
    final seen = <String>{};

    void add(String url) {
      if (seen.add(url)) candidates.add(url);
    }

    final envUrl = _envApiBaseUrl();
    if (envUrl != null) add(_normalize(envUrl));

    if (defaultTargetPlatform == TargetPlatform.android) {
      add('http://10.0.2.2:$defaultPort'); // Android Studio / AVD
      add('http://10.0.3.2:$defaultPort'); // Genymotion
      add('http://172.16.1.2:$defaultPort'); // LDPlayer NAT gateway
      add('http://127.0.0.1:$defaultPort'); // rooted devices / local
    } else {
      add('http://localhost:$defaultPort'); // iOS simulator
      add('http://127.0.0.1:$defaultPort');
    }

    (await _lanHosts()).forEach(add);
    return candidates;
  }

  /// Builds host candidates on the same LAN as the device: the device's
  /// own IP plus the common gateway addresses (.1/.2/.254).
  static Future<List<String>> _lanHosts() async {
    final result = <String>[];
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    for (final iface in interfaces) {
      for (final addr in iface.addresses) {
        final ip = addr.address;
        final lastDot = ip.lastIndexOf('.');
        if (lastDot <= 0) continue;
        final subnet = ip.substring(0, lastDot + 1);
        result.add('http://$ip:$defaultPort');
        result.add('http://$subnet${'1'}:$defaultPort');
        result.add('http://$subnet${'2'}:$defaultPort');
        result.add('http://$subnet${'254'}:$defaultPort');
      }
    }
    return result;
  }

  /// Scans the whole local /24 subnet in small parallel batches, looking
  /// for any host listening on the backend port (the backend machine can
  /// have any LAN address, not just gateways).
  static Future<String?> _subnetScan() async {
    final prefix = await _localSubnetPrefix();
    if (prefix == null) return null;
    for (var start = 1; start <= 254; start += _scanBatchSize) {
      final end = (start + _scanBatchSize - 1).clamp(1, 254);
      final futures = <Future<String?>>[
        for (var host = start; host <= end; host++)
          _probe('http://$prefix$host:$defaultPort', _scanProbeTimeout),
      ];
      final hit = _firstHit(await Future.wait(futures));
      if (hit != null) return hit;
    }
    return null;
  }

  static Future<String?> _localSubnetPrefix() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final ip = addr.address;
          if (ip.startsWith('127.')) continue;
          final lastDot = ip.lastIndexOf('.');
          if (lastDot <= 0) continue;
          return ip.substring(0, lastDot + 1);
        }
      }
    } catch (_) {}
    return null;
  }

  static String? _firstHit(List<String?> results) {
    for (final result in results) {
      if (result != null) return result;
    }
    return null;
  }

  static String _normalize(String url) =>
      url.endsWith('/') ? url.substring(0, url.length - 1) : url;

  static String? _envApiBaseUrl() {
    try {
      final value = dotenv.env['API_BASE_URL'];
      return (value != null && value.isNotEmpty) ? value : null;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _probe(String baseUrl, Duration timeout) async {
    final client = HttpClient()
      ..connectionTimeout = timeout
      ..badCertificateCallback = (cert, host, port) => true;
    try {
      final request = await client
          .getUrl(Uri.parse('$baseUrl/'))
          .timeout(timeout);
      final response = await request.close().timeout(timeout);
      await response.drain<void>().timeout(timeout);
      return baseUrl;
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
