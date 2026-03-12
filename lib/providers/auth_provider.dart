import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../database/app_database.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final AppDatabase db;
  User? _currentUser;

  AuthProvider(this.db) {
    _tryAutoLogin();
  }

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  static String hashPassword(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  Future<void> _tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      _currentUser = await db.users.findById(userId);
      notifyListeners();
    }
  }

  Future<String?> login(String identifier, String password) async {
    final user =
        await db.users.findByUsernameOrEmail(identifier.trim());
    if (user == null) return 'User not found.';
    if (user.passwordHash != hashPassword(password)) {
      return 'Incorrect password.';
    }
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user.id!);
    notifyListeners();
    return null;
  }

  Future<String?> register({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    email = email.trim();
    username = username.trim();

    if (!RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email)) return 'Invalid email address.';
    if (!RegExp(r'^[a-zA-Z0-9]{3,10}$').hasMatch(username)) {
      return 'Username must be 3–10 alphanumeric characters.';
    }
    if (password.length < 8) return 'Password must be at least 8 characters.';
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter.';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter.';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a digit.';
    }
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))) {
      return 'Password must contain a special character.';
    }
    if (password != confirmPassword) return 'Passwords do not match.';
    if (await db.users.isEmailTaken(email)) return 'Email already in use.';
    if (await db.users.isUsernameTaken(username)) {
      return 'Username already taken.';
    }

    await db.users.insert(User(
      email: email,
      username: username,
      passwordHash: hashPassword(password),
      createdAt: DateTime.now().toIso8601String(),
    ));
    return null;
  }

  Future<String?> changePassword(
      String currentPassword, String newPassword) async {
    if (_currentUser == null) return 'Not logged in.';
    if (_currentUser!.passwordHash != hashPassword(currentPassword)) {
      return 'Current password is incorrect.';
    }
    if (newPassword.length < 8) return 'Password must be at least 8 characters.';
    if (!newPassword.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter.';
    }
    if (!newPassword.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter.';
    }
    if (!newPassword.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a digit.';
    }
    if (!newPassword.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))) {
      return 'Password must contain a special character.';
    }
    await db.users.updateFields(
        _currentUser!.id!, {'password_hash': hashPassword(newPassword)});
    return null;
  }

  Future<String?> changeUsername(String newUsername) async {
    if (_currentUser == null) return 'Not logged in.';
    newUsername = newUsername.trim();
    if (!RegExp(r'^[a-zA-Z0-9]{3,10}$').hasMatch(newUsername)) {
      return 'Username must be 3–10 alphanumeric characters.';
    }
    if (await db.users.isUsernameTaken(newUsername)) {
      return 'Username already taken.';
    }
    await db.users
        .updateFields(_currentUser!.id!, {'username': newUsername});
    await refreshUser();
    return null;
  }

  Future<void> refreshUser() async {
    if (_currentUser?.id == null) return;
    _currentUser = await db.users.findById(_currentUser!.id!);
    notifyListeners();
  }

  Future<void> resetProgress() async {
    if (_currentUser == null) return;
    await db.users.updateFields(_currentUser!.id!, {
      'coins': 0,
      'total_score': 0,
      'max_lives': 3,
    });
    await db.stageResults
        .deleteWhere('user_id = ?', [_currentUser!.id!]);
    await db.inventory
        .deleteWhere('user_id = ?', [_currentUser!.id!]);
    await refreshUser();
  }

  Future<void> deleteAccount() async {
    if (_currentUser == null) return;
    final id = _currentUser!.id!;
    await db.stageResults.deleteWhere('user_id = ?', [id]);
    await db.inventory.deleteWhere('user_id = ?', [id]);
    await db.users.deleteById(id);
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    notifyListeners();
  }
}
