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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.neutralDarkCard : AppColors.neutralCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 1,
          ),
        ),
      ),
    );
  }
}