import 'package:finance_tracker/core/services/app_settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Test-only store substitute for a failed platform read.
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _FailingStore extends InMemorySharedPreferencesStore {
  _FailingStore() : super.empty();

  int writes = 0;

  @override
  Future<Map<String, Object>> getAll() async =>
      throw StateError('synthetic preference read failure');

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    writes++;
    return super.setValue(valueType, key, value);
  }
}

void main() {
  const key = 'app_lock_enabled';

  for (final (description, initial, expected)
      in <(String, Map<String, Object>, bool)>[
        ('absent', {}, true),
        ('stored true', {key: true}, true),
        ('stored false', {key: false}, false),
        ('wrong string type', {key: 'false'}, true),
        ('wrong number type', {key: 0}, true),
      ]) {
    test('$description resolves safely without writing', () async {
      SharedPreferences.setMockInitialValues(initial);
      final prefs = await SharedPreferences.getInstance();
      final before = {
        for (final name in prefs.getKeys()) name: prefs.get(name),
      };

      expect(await AppSettingsService.loadAppLockEnabled(), expected);
      expect({
        for (final name in prefs.getKeys()) name: prefs.get(name),
      }, before);
      expect(prefs.get(key), initial[key]);
    });
  }

  test('platform read failure defaults to enabled without writing', () async {
    SharedPreferences.setMockInitialValues({});
    final originalStore = SharedPreferencesStorePlatform.instance;
    final failingStore = _FailingStore();
    SharedPreferencesStorePlatform.instance = failingStore;
    addTearDown(() {
      SharedPreferencesStorePlatform.instance = originalStore;
      SharedPreferences.setMockInitialValues({});
    });

    expect(await AppSettingsService.loadAppLockEnabled(), isTrue);
    expect(failingStore.writes, 0);
  });
}
