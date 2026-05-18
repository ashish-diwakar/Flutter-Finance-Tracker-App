import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {

  static const storage =
      FlutterSecureStorage();

  static Future<void> write({
    required String key,
    required String value,
  }) async {

    await storage.write(
      key: key,
      value: value,
    );
  }

  static Future<String?> read(
    String key,
  ) async {

    return storage.read(
      key: key,
    );
  }

  static Future<void> delete(
    String key,
  ) async {

    await storage.delete(
      key: key,
    );
  }
}