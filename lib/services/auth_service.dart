import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_logger.dart';
import '../services/database_service.dart';

class AuthService {
  final DatabaseService _db = DatabaseService.instance;

  // Login user
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final List<Map<String, dynamic>> users = await _db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (users.isEmpty) {
      return null;
    }

    final user = users.first;
    final storedHash = user['password_hash'] as String;

    // Verify password
    bool isValid = BCrypt.checkpw(password, storedHash);

    if (isValid) {
      return {
        'id': user['id'],
        'username': user['username'],
        'is_admin': user['is_admin'] == 1,
      };
    }

    return null;
  }

  // Change password
  Future<bool> changePassword(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {
    // Verify old password
    final users = await _db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (users.isEmpty) {
      return false;
    }

    final user = users.first;
    final storedHash = user['password_hash'] as String;

    if (!BCrypt.checkpw(oldPassword, storedHash)) {
      return false;
    }

    // Hash new password
    final newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());

    // Update password
    await _db.update(
      'users',
      {
        'password_hash': newHash,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );

    return true;
  }

  // Admin reset password
  Future<bool> adminResetPassword(String username, String newPassword) async {
    // Hash new password
    final newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());

    // Update password
    final result = await _db.update(
      'users',
      {
        'password_hash': newHash,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'username = ?',
      whereArgs: [username],
    );

    return result > 0;
  }

  // Create new user
  Future<int> createUser(
    String username,
    String password, {
    bool isAdmin = false,
  }) async {
    // Hash password
    final hash = BCrypt.hashpw(password, BCrypt.gensalt());

    final now = DateTime.now().toIso8601String();

    return _db.insert('users', {
      'username': username,
      'password_hash': hash,
      'is_admin': isAdmin ? 1 : 0,
      'created_at': now,
      'updated_at': now,
    });
  }

  // Get all users (admin only)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return _db.query(
      'users',
      columns: ['id', 'username', 'is_admin', 'created_at'],
    );
  }

  // Delete user
  Future<bool> deleteUser(int userId) async {
    final result = await _db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result > 0;
  }
}

// Auth state
class AuthState {
  final int? userId;
  final String? username;
  final bool isAdmin;
  final bool isAuthenticated;

  AuthState({
    this.userId,
    this.username,
    this.isAdmin = false,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    int? userId,
    String? username,
    bool? isAdmin,
    bool? isAuthenticated,
  }) {
    return AuthState(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      isAdmin: isAdmin ?? this.isAdmin,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();
  final AppLogger _logger = AppLogger.instance;
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUsername = 'auth_username';
  static const String _keyIsAdmin = 'auth_is_admin';

  AuthNotifier() : super(AuthState()) {
    _restoreSession();
  }

  // Restore session from SharedPreferences
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(_keyUserId);
      final username = prefs.getString(_keyUsername);
      final isAdmin = prefs.getBool(_keyIsAdmin) ?? false;

      if (userId != null && username != null) {
        state = AuthState(
          userId: userId,
          username: username,
          isAdmin: isAdmin,
          isAuthenticated: true,
        );
      }
    } catch (e) {
      await _logger.logError(
        'Session restore error',
        operation: 'auth:restore',
        error: e,
      );
    }
  }

  // Save session to SharedPreferences
  Future<void> _saveSession(int userId, String username, bool isAdmin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUsername, username);
    await prefs.setBool(_keyIsAdmin, isAdmin);
  }

  // Clear session from SharedPreferences
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyIsAdmin);
  }

  Future<bool> login(String username, String password) async {
    try {
      final user = await _authService.login(username, password);

      if (user != null) {
        state = AuthState(
          userId: user['id'],
          username: user['username'],
          isAdmin: user['is_admin'],
          isAuthenticated: true,
        );
        // Persist session
        await _saveSession(user['id'], user['username'], user['is_admin']);
        return true;
      }
      return false;
    } catch (e) {
      await _logger.logError('Login error', operation: 'auth:login', error: e);
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (state.userId == null) return false;
    return await _authService.changePassword(
      state.userId!,
      oldPassword,
      newPassword,
    );
  }

  Future<bool> adminResetPassword(String username, String newPassword) async {
    if (!state.isAdmin) return false;
    return await _authService.adminResetPassword(username, newPassword);
  }

  Future<void> logout() async {
    await _clearSession();
    state = AuthState();
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
