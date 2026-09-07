// Stage A 冒烟测试：验证骨架可构建，底部导航五个入口可达。
// 用内存库替换真实 DB，避免 widget 测试依赖 path_provider 平台通道。
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:period_tracker/core/db/app_database.dart';
import 'package:period_tracker/core/di/injection.dart';
import 'package:period_tracker/app.dart';

void main() {
  late AppDatabase db;

  setUpAll(() async {
    await configureDependencies();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    getIt.allowReassignment = true;
    getIt.registerSingleton<AppDatabase>(db);
  });

  tearDownAll(() => db.close());

  testWidgets('Root shell renders bottom navigation with five tabs',
      (tester) async {
    await tester.pumpWidget(const PeriodTrackerApp());

    // 底部导航固定五个入口（文案随语言变化，这里只验证结构）。
    expect(find.byType(NavigationDestination), findsNWidgets(5));
  });
}