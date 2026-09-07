import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 本地安全存储（对应 PRD 19.4 / 23.3）。
/// iOS 走 Keychain，Android 走 EncryptedSharedPreferences。
///
/// 当前阶段：承载库密钥位（供后续 sqlcipher 加密开通时读取），
/// 以及匿名本地标识；不保存经期业务数据。
class SecureStore {
  SecureStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _dbKeyKey = 'period_db_key';
  static const _anonIdKey = 'period_anon_id';

  Future<String?> readDbKey() => _storage.read(key: _dbKeyKey);

  Future<void> writeDbKey(String key) =>
      _storage.write(key: _dbKeyKey, value: key);

  Future<String?> readAnonId() => _storage.read(key: _anonIdKey);

  Future<void> writeAnonId(String id) =>
      _storage.write(key: _anonIdKey, value: id);
}