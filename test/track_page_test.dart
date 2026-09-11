// 回归测试：跟踪页按类别筛选配置渲染卡片。
// 背景：_Section 曾用 Row + CrossAxisAlignment.stretch 放在高度无界的
// ListView 中，导致第一张卡片被撑成无限高、后续卡片全部不渲染
// （用户启用了 4 个类别却只看到 1 张卡）。此测试固定该场景防止回归。
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:period_tracker/app.dart';
import 'package:period_tracker/core/db/app_database.dart';
import 'package:period_tracker/core/di/injection.dart';

void main() {
  setUpAll(() async {
    // 预设类别配置：仅启用 4 个类别（与用户遇到问题时的场景一致）。
    SharedPreferences.setMockInitialValues(const {
      'track_categories_enabled': 'period,symptoms,mood,sex',
    });
    await configureDependencies();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    getIt.allowReassignment = true;
    getIt.registerSingleton<AppDatabase>(db);
    addTearDown(db.close);
  });

  testWidgets('启用 4 个类别时跟踪页渲染全部 4 张卡片', (tester) async {
    // 拉高测试视口，避免列表懒加载影响卡片计数断言。
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const PeriodTrackerApp());
    await tester.pumpAndSettle();

    // 切换到「跟踪」tab（第 3 个导航项）。
    await tester.tap(find.byType(NavigationDestination).at(2));
    await tester.pumpAndSettle();

    // _Section 是 track_page.dart 的私有类，用 runtimeType 定位。
    final sections = find.byWidgetPredicate(
      (w) => w.runtimeType.toString() == '_Section',
    );
    expect(sections, findsNWidgets(4));
    expect(tester.takeException(), isNull);

    // 卡片高度必须有限（无限高是本次回归的根因特征）。
    final first = tester.renderObject<RenderBox>(sections.first);
    expect(first.size.height.isFinite, isTrue);
    expect(first.size.height, lessThan(600));
  });
}
