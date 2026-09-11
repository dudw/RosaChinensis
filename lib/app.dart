import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/i18n/locale_controller.dart';
import 'core/theme/app_theme.dart';
import 'data/auto_backup_controller.dart';
import 'features/calendar/calendar_page.dart';
import 'features/settings/settings_page.dart';
import 'features/stats/stats_page.dart';
import 'features/today/today_page.dart';
import 'features/track/track_page.dart';
import 'l10n/app_localizations.dart';

/// 全局主题模式控制器（供设置页切换深浅模式）。
class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  void setMode(ThemeMode mode) {
    if (_mode != mode) {
      _mode = mode;
      notifyListeners();
    }
  }
}

/// 全局设置变更广播：任何设置修改后调 [notify]，
/// 首页 / 日历 / 跟踪 / 分析等页面监听自动刷新。
class AppSettingsController extends ChangeNotifier {
  AppSettingsController._();
  static final AppSettingsController instance = AppSettingsController._();

  /// 设置页（主题 / 周期个人化 / 自定义跟踪）保存完成后调用。
  void notify() => notifyListeners();
}

/// 应用根组件：5-tab 底部导航（今日 / 日历 / 跟踪 / 分析 / 更多）。
/// 中间「跟踪」tab 为大号图标，是主录入入口。
class PeriodTrackerApp extends StatelessWidget {
  const PeriodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ThemeController.instance,
        LocaleController.instance,
      ]),
      builder: (context, _) {
        final locale = LocaleController.instance.resolve(
          WidgetsBinding.instance.platformDispatcher.locale,
        );
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          themeMode: ThemeController.instance.mode,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: const RootShell(),
        );
      },
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  /// 子页面调用此方法切换底部导航 tab。index = 0(今日)/1(日历)/2(追踪)/3(分析)/4(更多)。
  static void switchTo(int i) => _switch?.call(i);
  static void Function(int)? _switch;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> with WidgetsBindingObserver {
  int _index = 0;
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 预热备份控制器（读取 SharedPreferences）。
    AutoBackupController.instance.load();
    // 暴露给子页面使用
    RootShell._switch = _switchTo;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    RootShell._switch = null;
    super.dispose();
  }

  /// App 切到后台 / 用户退出时触发静默备份。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // 静默执行，不 await、不报错，后台操作。
      AutoBackupController.instance.backupNow();
    }
  }

  void _onTab(int i) => setState(() => _index = i);

  void _switchTo(int i) {
    if (mounted) setState(() => _index = i);
  }

  /// 返回键处理：非「今日」页先切回今日；「今日」页 2 秒内连按两次则退出。
  void _handleBack() {
    if (_index != 0) {
      setState(() => _index = 0);
      return;
    }
    final now = DateTime.now();
    final last = _lastBackPressed;
    if (last != null && now.difference(last) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
      return;
    }
    _lastBackPressed = now;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.pressAgainToExit)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context);
    final pages = [
      TodayPage(),
      CalendarPage(),
      TrackPage(),
      StatsPage(),
      SettingsPage(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        body: IndexedStack(index: _index, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _onTab,
          height: 80,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.water_drop_outlined),
              selectedIcon: Icon(Icons.water_drop, color: AppColors.brand),
              label: l10n.tabToday,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month, color: AppColors.brand),
              label: l10n.tabCalendar,
            ),
            NavigationDestination(
              icon: const Icon(Icons.add_circle_outline, size: 34),
              selectedIcon: _FloatingAddIcon(
                color: AppColors.brand,
                gradient: AppGradients.brand,
                isDark: t.brightness == Brightness.dark,
              ),
              label: l10n.tabTrack,
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart, color: AppColors.brand),
              label: l10n.tabStats,
            ),
            NavigationDestination(
              icon: const Icon(Icons.more_horiz),
              selectedIcon: Icon(Icons.more_vert, color: AppColors.brand),
              label: l10n.tabMore,
            ),
          ],
        ),
      ),
    );
  }
}

/// 浮起式 + 号：品牌渐变圆形背景 + 柔光阴影，模拟 FAB 浮起感。
class _FloatingAddIcon extends StatelessWidget {
  const _FloatingAddIcon({
    required this.color,
    required this.gradient,
    required this.isDark,
  });

  final Color color;
  final Gradient gradient;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -4),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: gradient,
          shape: BoxShape.circle,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.40),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
