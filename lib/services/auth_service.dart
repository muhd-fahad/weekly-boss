import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _nameKey = 'user_name';
  static const _passwordKey = 'user_password';


  Future<void> registerUser(String name, String password) async {
    await _storage.write(key: _nameKey, value: name);
    await _storage.write(key: _passwordKey, value: password);
  }


  Future<String?> getUserName() async {
    return _storage.read(key: _nameKey);
  }

  Future<bool> isUserRegistered() async {
    final name = await _storage.read(key: _nameKey);
    return name != null && name.isNotEmpty;
  }
  
  Future<void> signOut() => _storage.deleteAll();
}