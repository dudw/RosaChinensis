import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/i18n/locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_CN', null);
  // 初始化核心模块（数据层、安全存储），见 PRD 23 章。
  await configureDependencies();
  // 读取持久化语言选择（默认跟随系统）。
  await LocaleController.instance.load();
  runApp(const PeriodTrackerApp());
}