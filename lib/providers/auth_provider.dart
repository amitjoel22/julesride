import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _username;

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;

  Future<void> login(String username, String password) async {
    // In a real app, you would verify credentials here.
    // For this demonstration, we'll just accept any non-empty input.
    if (username.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _username = username;
      notifyListeners();
    }
  }

  void logout() {
    _isAuthenticated = false;
    _username = null;
    notifyListeners();
  }
}
