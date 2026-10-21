import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Service for managing Firebase Remote Config feature flags.
class RemoteConfigService {
  RemoteConfigService._();

  static final RemoteConfigService _instance = RemoteConfigService._();
  static RemoteConfigService get instance => _instance;

  FirebaseRemoteConfig? _remoteConfig;
  bool _initialized = false;

  // ── Default values ─────────────────────────────────────────────
  // Add a key here when a feature flag is introduced.
  static const Map<String, dynamic> _defaults = {};

  /// Initialize Remote Config with defaults and fetch latest values.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: kDebugMode
              ? const Duration(minutes: 5)
              : const Duration(hours: 12),
        ),
      );

      await _remoteConfig!.setDefaults(_defaults);
      await _remoteConfig!.fetchAndActivate();
    } catch (e) {
      debugPrint('RemoteConfig initialization failed: $e');
      _remoteConfig = null;
    }

    _initialized = true;
  }

  // ── Getters ────────────────────────────────────────────────────

  /// Get a boolean config value by key.
  bool getBool(String key) => _remoteConfig?.getBool(key) ?? false;

  /// Get a string config value by key.
  String getString(String key) => _remoteConfig?.getString(key) ?? '';

  /// Get an int config value by key.
  int getInt(String key) => _remoteConfig?.getInt(key) ?? 0;
}
