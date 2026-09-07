import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 语言设置控制器（对应多语言需求）：
/// - 默认「跟随系统」：系统为中文 → zh，否则（含非中英文）→ en；
/// - 用户可在更多页显式选择 简体中文 / English，选择后持久化。
class LocaleController extends ChangeNotifier {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  static const _prefsKey = 'app_language';

  /// 持久化选择：'system' | 'zh' | 'en'。
  static const system = 'system';
  static const zh = 'zh';
  static const en = 'en';

  String _choice = system;
  bool _loaded = false;

  /// 当前持久化选择（'system' / 'zh' / 'en'）。
  String get choice => _choice;

  bool get isSystem => _choice == system;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final p = await SharedPreferences.getInstance();
      final v = p.getString(_prefsKey);
      if (v != null && (v == zh || v == en)) _choice = v;
    } catch (_) {
      // 读取失败按默认「跟随系统」处理。
    }
  }

  Future<void> setChoice(String value) async {
    if (value == _choice) return;
    _choice = value;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      if (value == system) {
        await p.remove(_prefsKey);
      } else {
        await p.setString(_prefsKey, value);
      }
    } catch (_) {
      // 持久化失败仅影响下次启动，不影响本次生效。
    }
  }

  /// 解析为实际 UI 语言。
  /// 用户显式选择优先；否则系统为中文 → zh，其余（含非中英文）→ en。
  Locale resolve(Locale systemLocale) {
    if (_choice == zh) return const Locale('zh');
    if (_choice == en) return const Locale('en');
    return systemLocale.languageCode == 'zh'
        ? const Locale('zh')
        : const Locale('en');
  }
}
