import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_logger.dart';

/// Configuration for Supabase connection
class SupabaseConfig {
  static const String _urlKey = 'supabase_url';
  static const String _anonKeyKey = 'supabase_anon_key';
  static const String _enabledKey = 'supabase_enabled';

  final String url;
  final String anonKey;
  final bool enabled;

  const SupabaseConfig({
    required this.url,
    required this.anonKey,
    this.enabled = true,
  });

  bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static Future<SupabaseConfig?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(_urlKey);
    final anonKey = prefs.getString(_anonKeyKey);
    final enabled = prefs.getBool(_enabledKey) ?? false;

    if (url == null || anonKey == null) {
      return null;
    }

    return SupabaseConfig(url: url, anonKey: anonKey, enabled: enabled);
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_urlKey, url);
    await prefs.setString(_anonKeyKey, anonKey);
    await prefs.setBool(_enabledKey, enabled);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_urlKey);
    await prefs.remove(_anonKeyKey);
    await prefs.remove(_enabledKey);
  }
}

/// Service to manage Supabase initialization and connection
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  final AppLogger _logger = AppLogger.instance;
  SupabaseClient? _client;
  bool _isInitialized = false;
  SupabaseConfig? _config;

  bool get isInitialized => _isInitialized;
  bool get isConfigured => _config?.isConfigured ?? false;
  bool get isEnabled => _config?.enabled ?? false;
  SupabaseClient? get client => _client;

  /// Initialize Supabase with stored configuration
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _config = await SupabaseConfig.load();

      if (_config == null || !_config!.isConfigured) {
        await _logger.logInfo(
          'Supabase not configured - running in offline mode',
          operation: 'supabase:init',
        );
        return false;
      }

      if (!_config!.enabled) {
        await _logger.logInfo(
          'Supabase sync disabled',
          operation: 'supabase:init',
        );
        return false;
      }

      await Supabase.initialize(url: _config!.url, anonKey: _config!.anonKey);

      _client = Supabase.instance.client;
      _isInitialized = true;

      await _logger.logInfo(
        'Supabase initialized successfully',
        operation: 'supabase:init',
      );

      return true;
    } catch (e, stackTrace) {
      await _logger.logError(
        'Failed to initialize Supabase',
        operation: 'supabase:init',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Configure Supabase with new credentials
  Future<bool> configure(String url, String anonKey) async {
    try {
      // Test the connection first
      final testClient = SupabaseClient(url, anonKey);

      // Try a simple query to verify connection
      await testClient.from('firms').select().limit(1);

      // Save configuration
      _config = SupabaseConfig(url: url, anonKey: anonKey, enabled: true);
      await _config!.save();

      // Re-initialize
      _isInitialized = false;
      return await initialize();
    } catch (e, stackTrace) {
      await _logger.logError(
        'Failed to configure Supabase',
        operation: 'supabase:configure',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Enable or disable sync
  Future<void> setEnabled(bool enabled) async {
    if (_config == null) return;

    _config = SupabaseConfig(
      url: _config!.url,
      anonKey: _config!.anonKey,
      enabled: enabled,
    );
    await _config!.save();

    if (enabled && !_isInitialized) {
      await initialize();
    }
  }

  /// Test the current connection
  Future<bool> testConnection() async {
    if (!_isInitialized || _client == null) return false;

    try {
      await _client!.from('firms').select().limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Connection status for the app
enum ConnectionStatus { online, offline, syncing }

/// Provider for connection status
class ConnectionStatusNotifier extends StateNotifier<ConnectionStatus> {
  ConnectionStatusNotifier() : super(ConnectionStatus.offline) {
    _init();
  }

  StreamSubscription? _subscription;

  void _init() {
    _checkConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _updateStatus(results);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      state = ConnectionStatus.offline;
    } else {
      state = ConnectionStatus.online;
    }
  }

  void setSyncing() {
    if (state != ConnectionStatus.offline) {
      state = ConnectionStatus.syncing;
    }
  }

  void setSyncComplete() {
    if (state == ConnectionStatus.syncing) {
      state = ConnectionStatus.online;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Providers
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});

final connectionStatusProvider =
    StateNotifierProvider<ConnectionStatusNotifier, ConnectionStatus>((ref) {
      return ConnectionStatusNotifier();
    });

final isOnlineProvider = Provider<bool>((ref) {
  final status = ref.watch(connectionStatusProvider);
  return status != ConnectionStatus.offline;
});
