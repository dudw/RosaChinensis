import 'package:flutter/material.dart';

/// 语义色 Token（对应 PRD 17.2）。
/// 命名强化「颜色即语义」：经期/排卵/受孕窗口/主操作/中性均在此统一定义，
/// 深色模式只需复用同 Token 的暗色取值。
///
/// 注意：为避免干扰，本文件不承载任何业务逻辑，仅提供颜色与主题构建。
abstract final class AppColors {
  AppColors._();

  // 品牌紫罗兰 · 主操作
  static const Color brand = Color(0xFF6C5CE7);
  // 经期红（最高警告语义）
  static const Color danger = Color(0xFFE63946);
  // 排卵琥珀
  static const Color amber = Color(0xFFE08A3E);
  // 受孕窗口青
  static const Color teal = Color(0xFF2A9D8F);
  // 中性（浅色背景 / 白卡片）
  static const Color neutralLight = Color(0xFFF6F5F9);
  static const Color neutralCard = Color(0xFFFFFFFF);
  // 中性（深色背景 / 黑卡片）
  static const Color neutralDarkBg = Color(0xFF17151F);
  static const Color neutralDarkCard = Color(0xFF241F30);
  // 信息诚实用的「预测态」浅色/虚线色调
  static const Color predictedLight = Color(0xFFE8E4F7);
  static const Color predictedDark = Color(0xFF2E284A);
}

/// 渐变 Token（PRD 17.2 视觉升级）。
/// 所有渐变以「同色系深→浅」或「品牌→语义」过渡，保证视觉一致。
abstract final class AppGradients {
  AppGradients._();

  /// 品牌主渐变（紫罗兰→柔紫），用于按钮、标题、进度弧。
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B6CF6), AppColors.brand],
  );

  /// 经期渐变（深红→暖红），用于经期弧、经期标记。
  static const LinearGradient period = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4F5B), AppColors.danger],
  );

  /// 排卵渐变（琥珀→暖橙）。
  static const LinearGradient ovulation = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEFA856), AppColors.amber],
  );

  /// 受孕期渐变（青绿→深青）。
  static const LinearGradient fertile = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3FB3A4), AppColors.teal],
  );

  /// 折线图下方填充渐变（语义色 → 透明），垂直方向。
  static LinearGradient chartFill(Color base) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [base.withValues(alpha: 0.35), base.withValues(alpha: 0.0)],
      );

  /// 趋势条垂直渐变（语义色 → 浅）。
  static LinearGradient barVertical(Color base) => LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [base, base.withValues(alpha: 0.55)],
      );
}

/// 柔光阴影 Token：用于关键卡片的「浮起」质感。
/// 深色模式下阴影极轻（深底上重阴影会脏），仅留细微边光。
abstract final class AppShadows {
  AppShadows._();

  /// 浮起卡片阴影（浅色）。
  static List<BoxShadow> card(Brightness b) => b == Brightness.dark
      ? []
      : [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ];

  /// 强调元素阴影（如选中态、主按钮）。
  static List<BoxShadow> accent(Brightness b, Color c) => b == Brightness.dark
      ? []
      : [
          BoxShadow(
            color: c.withValues(alpha: 0.30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];

  /// 圆环天数小圆圈的轻微浮起。
  static List<BoxShadow> dot(Brightness b) => b == Brightness.dark
      ? []
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
}

/// 圆角 Token：统一全 app 的圆角节奏（小=8 / 中=14 / 大=20 / 极大=28）。
abstract final class AppRadius {
  AppRadius._();
  static const double xs = 8;
  static const double s = 12;
  static const double m = 14;
  static const double l = 20;
  static const double xl = 28;
}

/// 语义色的深浅模式感知工具。
/// 给定 [Brightness]，返回「语义色块的最佳前景色」或「半透明背景色」。
extension SemanticColor on Brightness {
  /// 在指定语义色的实心色块上，文字/图标应该用什么颜色。
  Color onBlock(Color semantic) =>
      semantic.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  /// 语义色的「浅色底」变体，用于 chip / card 背景。
  /// 深色模式下 alpha 更高（因为深底上纯色更亮）。
  Color softBg(Color semantic, {double lightAlpha = 0.12, double darkAlpha = 0.22}) {
    final a = this == Brightness.dark ? darkAlpha : lightAlpha;
    return semantic.withValues(alpha: a);
  }
}

/// 小工具：根据 context 判断亮/暗，用于条件样式。
extension ContextTheme on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

/// 构建整套 Material 主题（浅/深），供 app.dart 统一使用。
abstract final class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: brightness,
      primary: AppColors.brand,
      error: AppColors.danger,
      surface: isDark ? AppColors.neutralDarkBg : AppColors.neutralLight,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.neutralDarkBg : AppColors.neutralLight,
      cardColor: isDark ? AppColors.neutralDarkCard : AppColors.neutralCard,
      fontFamilyFallback: const ['PingFang SC', 'Noto Sans CJK SC'],
    );

    return base.copyWith(
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          elevation: 0,
          shadowColor: AppColors.brand.withValues(alpha: isDark ? 0 : 0.30),
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.neutralDarkCard : AppColors.neutralCard,
        elevation: 0,
        shadowColor: AppColors.brand.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.l),
          side: BorderSide(
            color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.neutralDarkBg : AppColors.neutralLight,
        indicatorColor: AppColors.brand.withValues(alpha: isDark ? 0.30 : 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? AppColors.brand
                : (isDark ? Colors.white70 : Colors.black54),
          );
        }),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: isDark ? AppColors.neutralDarkBg : AppColors.neutralLight,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}