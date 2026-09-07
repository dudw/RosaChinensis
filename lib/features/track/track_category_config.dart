import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// 跟踪页类别定义（顺序即默认展示顺序）。
enum TrackCategory {
  period(Icons.water_drop_outlined, AppColors.danger),
  symptoms(Icons.sick_outlined, AppColors.amber),
  mood(Icons.mood_outlined, AppColors.teal),
  sex(Icons.favorite_outline, AppColors.teal),
  metrics(Icons.monitor_weight_outlined, AppColors.brand),
  note(Icons.note_outlined, AppColors.brand);

  const TrackCategory(this.icon, this.color);
  final IconData icon;
  final Color color;

  /// 本地化类别名（数据库持久化用 [name]，不用 label）。
  String label(AppLocalizations l10n) => switch (this) {
        TrackCategory.period => l10n.categoryPeriod,
        TrackCategory.symptoms => l10n.categorySymptoms,
        TrackCategory.mood => l10n.categoryMood,
        TrackCategory.sex => l10n.categorySex,
        TrackCategory.metrics => l10n.categoryMetrics,
        TrackCategory.note => l10n.categoryNote,
      };
}

/// 单个类别配置项：类别 + 是否启用。
class CategoryItem {
  const CategoryItem(this.category, this.enabled);
  final TrackCategory category;
  final bool enabled;

  CategoryItem copyWith({bool? enabled}) =>
      CategoryItem(category, enabled ?? this.enabled);
}

/// 跟踪页类别配置服务：持久化启用状态与排序。
///
/// 存储格式（SharedPreferences）：
/// - `track_categories_order`：逗号分隔的类别 id 有序列表
/// - `track_categories_enabled`：逗号分隔的已启用类别 id 列表
/// 若键不存在，使用默认配置（全部启用、默认顺序）。
class TrackCategoryConfig {
  TrackCategoryConfig._(this._prefs);

  static TrackCategoryConfig? _instance;
  static Future<TrackCategoryConfig> get instance async {
    _instance ??= TrackCategoryConfig._(await SharedPreferences.getInstance());
    return _instance!;
  }

  final SharedPreferences _prefs;
  static const _orderKey = 'track_categories_order';
  static const _enabledKey = 'track_categories_enabled';

  /// 默认顺序（全部启用）。
  static const List<TrackCategory> _defaultOrder = TrackCategory.values;

  /// 读取当前配置（有序 + 启用标记）。
  List<CategoryItem> load() {
    final orderRaw = _prefs.getString(_orderKey);
    final enabledRaw = _prefs.getString(_enabledKey);

    final order = <TrackCategory>[];
    if (orderRaw != null && orderRaw.isNotEmpty) {
      for (final id in orderRaw.split(',')) {
        final c = TrackCategory.values.asMap().values.cast<TrackCategory?>().firstWhere(
              (e) => e?.name == id,
              orElse: () => null,
            );
        if (c != null) order.add(c);
      }
    }
    // 补齐可能缺失的类别（新增类别时向后兼容）。
    for (final c in _defaultOrder) {
      if (!order.contains(c)) order.add(c);
    }

    final enabledSet = <String>{};
    if (enabledRaw != null && enabledRaw.isNotEmpty) {
      enabledSet.addAll(enabledRaw.split(','));
    } else {
      // 首次使用，全部启用。
      enabledSet.addAll(_defaultOrder.map((c) => c.name));
    }

    return order.map((c) => CategoryItem(c, enabledSet.contains(c.name))).toList();
  }

  /// 保存配置。
  Future<void> save(List<CategoryItem> items) async {
    final order = items.map((i) => i.category.name).join(',');
    final enabled = items.where((i) => i.enabled).map((i) => i.category.name).join(',');
    await _prefs.setString(_orderKey, order);
    await _prefs.setString(_enabledKey, enabled);
  }

  /// 全部启用 / 全部关闭。
  Future<void> setAllEnabled(bool enabled) async {
    final items = load().map((i) => i.copyWith(enabled: enabled)).toList();
    await save(items);
  }

  /// 是否已全部启用。
  bool get allEnabled => load().every((i) => i.enabled);
}
