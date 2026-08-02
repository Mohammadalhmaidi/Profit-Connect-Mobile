import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../api_service.dart';

class AppUpdateChecker {
  static final AppUpdateChecker _instance = AppUpdateChecker._internal();
  factory AppUpdateChecker() => _instance;
  AppUpdateChecker._internal();

  static const String _versionCheckUrl = '/api/app/version';

  Future<VersionCheckResult> checkForUpdate() async {
    try {
      final hasInternet = await InternetConnection().hasInternetAccess;
      if (!hasInternet) {
        final packageInfo = await PackageInfo.fromPlatform();
        return VersionCheckResult(
          isUpdateAvailable: false,
          isForceUpdate: false,
          currentVersion: packageInfo.version,
          serverVersion: packageInfo.version,
          currentBuild: int.tryParse(packageInfo.buildNumber) ?? 1,
          serverBuild: int.tryParse(packageInfo.buildNumber) ?? 1,
        );
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 1;

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}$_versionCheckUrl'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final serverVersion = data['version'] as String? ?? currentVersion;
        final serverBuild = int.tryParse(data['build']?.toString() ?? '1') ?? 1;
        final forceUpdate = data['force_update'] as bool? ?? false;
        final updateUrl = data['update_url'] as String?;
        final changelog = data['changelog'] as String?;

        final isUpdateAvailable = _isVersionNewer(serverVersion, currentVersion) ||
            serverBuild > currentBuild;

        return VersionCheckResult(
          isUpdateAvailable: isUpdateAvailable,
          isForceUpdate: forceUpdate && isUpdateAvailable,
          currentVersion: currentVersion,
          serverVersion: serverVersion,
          currentBuild: currentBuild,
          serverBuild: serverBuild,
          updateUrl: updateUrl,
          changelog: changelog,
        );
      }

      return VersionCheckResult(
        isUpdateAvailable: false,
        isForceUpdate: false,
        currentVersion: currentVersion,
        serverVersion: currentVersion,
        currentBuild: currentBuild,
        serverBuild: currentBuild,
      );
    } catch (e) {
      debugPrint('Version Check Error: $e');
      final packageInfo = await PackageInfo.fromPlatform();
      return VersionCheckResult(
        isUpdateAvailable: false,
        isForceUpdate: false,
        currentVersion: packageInfo.version,
        serverVersion: packageInfo.version,
        currentBuild: int.tryParse(packageInfo.buildNumber) ?? 1,
        serverBuild: int.tryParse(packageInfo.buildNumber) ?? 1,
      );
    }
  }

  bool _isVersionNewer(String server, String current) {
    final serverParts = server.split('.');
    final currentParts = current.split('.');

    for (int i = 0; i < serverParts.length; i++) {
      final serverMajor = int.tryParse(serverParts[i]) ?? 0;
      final currentMajor = i < currentParts.length ? int.tryParse(currentParts[i]) ?? 0 : 0;
      if (serverMajor > currentMajor) return true;
      if (serverMajor < currentMajor) return false;
    }
    return false;
  }
}

class VersionCheckResult {
  final bool isUpdateAvailable;
  final bool isForceUpdate;
  final String currentVersion;
  final String serverVersion;
  final int currentBuild;
  final int serverBuild;
  final String? updateUrl;
  final String? changelog;

  VersionCheckResult({
    required this.isUpdateAvailable,
    required this.isForceUpdate,
    required this.currentVersion,
    required this.serverVersion,
    required this.currentBuild,
    required this.serverBuild,
    this.updateUrl,
    this.changelog,
  });
}