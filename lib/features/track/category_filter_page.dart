import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'track_category_config.dart';

/// 类别筛选页：开关控制各分类是否在跟踪页显示，
/// 长按拖拽右侧手柄可重新排序。顶部「所有类别」为主开关。
class CategoryFilterPage extends StatefulWidget {
  const CategoryFilterPage({super.key, required this.config});

  final TrackCategoryConfig config;

  @override
  State<CategoryFilterPage> createState() => _CategoryFilterPageState();
}

class _CategoryFilterPageState extends State<CategoryFilterPage> {
  late List<CategoryItem> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.config.load();
  }

  bool get _allEnabled => _items.every((i) => i.enabled);

  Future<void> _persist() async {
    await widget.config.save(_items);
    AppSettingsController.instance.notify();
  }

  void _toggleAll(bool v) {
    setState(() {
      _items = _items.map((i) => i.copyWith(enabled: v)).toList();
    });
    _persist();
  }

  void _toggle(int index, bool v) {
    setState(() {
      _items[index] = _items[index].copyWith(enabled: v);
    });
    _persist();
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      // onReorderItem 已为移除项调整过 newIndex。
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.categoryFilter),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              l10n.categoryFilterHint,
              style: t.textTheme.bodyMedium
                  ?.copyWith(color: t.colorScheme.onSurfaceVariant),
            ),
          ),
          // 所有类别主开关
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(l10n.allCategories, style: t.textTheme.titleMedium),
                const Spacer(),
                Switch(
                  value: _allEnabled,
                  onChanged: _toggleAll,
                  activeTrackColor: AppColors.brand,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _items.length,
              onReorderItem: _reorder,
              proxyDecorator: (child, index, animation) {
                return Material(
                  elevation: 4,
                  color: t.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final item = _items[index];
                final c = item.category;
                return ListTile(
                  key: ValueKey(c.name),
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: item.enabled
                        ? c.color.withValues(alpha: 0.15)
                        : t.colorScheme.surfaceContainerHighest,
                    child: Icon(c.icon,
                        size: 18,
                        color: item.enabled ? c.color : t.colorScheme.outline),
                  ),
                  title: Text(
                    c.label(l10n),
                    style: TextStyle(
                      color: item.enabled ? null : t.colorScheme.outline,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: item.enabled,
                        onChanged: (v) => _toggle(index, v),
                        activeTrackColor: AppColors.brand,
                      ),
                      ReorderableDragStartListener(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.drag_indicator,
                              color: t.colorScheme.outline),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
