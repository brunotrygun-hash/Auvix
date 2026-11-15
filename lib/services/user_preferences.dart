import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPreferences {
  UserPreferences._(this._prefs, this._userId);

  final SharedPreferences _prefs;
  final String _userId;

  static const String _migrationKey = 'auvix_user_storage_migration_v1';
  static const String _migrationOwnerKey =
      'auvix_user_storage_migration_v1_owner';

  static Future<void>? _migrationFuture;

  static Future<UserPreferences> getInstance() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null || userId.isEmpty) {
      throw StateError('Não existe usuário autenticado para acessar os dados.');
    }

    final prefs = await SharedPreferences.getInstance();

    final migration = _migrationFuture ??= _migrateLegacyData(prefs, userId);

    try {
      await migration;
    } catch (_) {
      _migrationFuture = null;
      rethrow;
    }

    return UserPreferences._(prefs, userId);
  }

  String _key(String key) => '${key}__auvix_user_$_userId';

  static bool _isLegacyAuvixKey(String key, String userId) {
    if (key.contains('__auvix_user_')) return false;

    return key == 'auvix_debts' ||
        key == 'auvix_personal_assets' ||
        key == 'auvix_money_history' ||
        key == 'auvix_money_total' ||
        key == 'auvix_money_monthly_goal' ||
        key == 'auvix_money_goal' ||
        key == 'auvix_read_announcement_ids' ||
        key == 'auvix_official_notifications_enabled' ||
        key == 'wealth_contribution_input' ||
        key == 'wealth_rate_input' ||
        key == 'wealth_months_input' ||
        key == 'wealth_goal_input' ||
        key == 'wealth_income_input' ||
        key == 'wealth_expenses_input' ||
        key == 'wealth_reserve_input' ||
        key == 'wealth_contribution' ||
        key == 'wealth_rate' ||
        key == 'wealth_months' ||
        key == 'wealth_goal' ||
        key == 'wealth_suggested' ||
        key == 'wealth_budget_calculated' ||
        key.startsWith('lesson_') ||
        key.startsWith('module_02_lesson_') ||
        key.startsWith('module_03_lesson_') ||
        key.startsWith('module_04_lesson_') ||
        key.startsWith('module_05_lesson_') ||
        key == 'auvix_profile_avatar_$userId';
  }

  static Future<void> _migrateLegacyData(
    SharedPreferences prefs,
    String userId,
  ) async {
    if (prefs.getBool(_migrationKey) == true) {
      return;
    }

    final previousOwner = prefs.getString(_migrationOwnerKey);

    if (previousOwner != null && previousOwner != userId) {
      throw StateError(
        'Os dados antigos pertencem a outra conta. '
        'A migração foi bloqueada para proteger os dados.',
      );
    }

    // Define o proprietário antes de iniciar a cópia.
    // Se o processo for interrompido, outra conta não poderá assumir os dados.
    await prefs.setString(_migrationOwnerKey, userId);

    final legacyKeys = prefs
        .getKeys()
        .where((key) => _isLegacyAuvixKey(key, userId))
        .toList();

    for (final key in legacyKeys) {
      final value = prefs.get(key);
      if (value == null) continue;

      final target = '${key}__auvix_user_$userId';

      if (prefs.containsKey(target)) continue;

      if (value is String) {
        await prefs.setString(target, value);
      } else if (value is bool) {
        await prefs.setBool(target, value);
      } else if (value is int) {
        await prefs.setInt(target, value);
      } else if (value is double) {
        await prefs.setDouble(target, value);
      } else if (value is List<String>) {
        await prefs.setStringList(target, value);
      } else {
        throw StateError('Tipo de dado não suportado na migração: $key');
      }
    }

    await prefs.setBool(_migrationKey, true);
  }

  String? getString(String key) => _prefs.getString(_key(key));
  bool? getBool(String key) => _prefs.getBool(_key(key));
  int? getInt(String key) => _prefs.getInt(_key(key));
  double? getDouble(String key) => _prefs.getDouble(_key(key));
  List<String>? getStringList(String key) => _prefs.getStringList(_key(key));

  Future<bool> setString(String key, String value) =>
      _prefs.setString(_key(key), value);

  Future<bool> setBool(String key, bool value) =>
      _prefs.setBool(_key(key), value);

  Future<bool> setInt(String key, int value) => _prefs.setInt(_key(key), value);

  Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(_key(key), value);

  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(_key(key), value);

  Future<bool> remove(String key) => _prefs.remove(_key(key));
}
