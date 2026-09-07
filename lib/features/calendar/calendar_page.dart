import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../core/di/injection.dart';
import '../../core/i18n/format.dart';
import '../../core/theme/app_theme.dart';
import '../../data/current_user.dart';
import '../../data/repositories/record_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../prediction/cycle_math.dart' as cycle;
import '../track/track_page.dart';

/// 日历页：垂直无限滚动月份视图。
///
/// - 上下滑动可浏览任意月份（基准月 +- 120 年范围），无月份数量限制。
/// - 顶部 AppBar 左右箭头每次翻动 ±3 个月，支持平滑定位；
///   "回到今天" 一键滚回本月。
/// - 今天蓝框高亮，经期/预测/排卵标记着色；点击某一天打开该日期跟踪页。
/// - 标记数据按需加载：滑到哪个月份就加载其 ±1 个月范围，避免一次取太多。
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

enum _Mark { period, predictedPeriod, ovulation, window, blank }

class _DayMark {
  const _DayMark({this.mark = _Mark.blank, this.flow, this.hasSex = false});
  final _Mark mark;
  final int? flow;
  final bool hasSex;
}

/// 以某个基准月为 index 0，可表示 ±[kMonthRange] 个月的月份序号。
const int kMonthRange = 144; // 前后各 12 年，共 24 年

class _CalendarPageState extends State<CalendarPage> {
  DateTime? _selected;
  /// index 0 对应的基准月（通常是本月首日）。
  late final DateTime _anchorMonth;

  /// 平均每个月份块高度估算（标题 + 周首 + 日历格 + padding），
  /// 用于 ScrollController 初始定位和箭头平滑滚动的粗略换算。
  static const double _kAvgMonthHeight = 390.0;

  /// ScrollController 初始 offset 设为本月 index（0）对应的粗略位置，
  /// 让列表首屏就落在本月附近，用户可自由上下滑动。
  final ScrollController _scroll = ScrollController(
    initialScrollOffset: kMonthRange * _kAvgMonthHeight,
  );

  late Future<_MarkSet> _marks;
  _MarkSet? _marksCache;

  /// 最近一次数据加载覆盖的月份范围（含）。
  int _loadedFromIndex = -9999;
  int _loadedToIndex = -9999;

  /// 节流定时器：滚动时延迟刷新标题/数据。
  Timer? _scrollDebounce;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _anchorMonth = DateTime(now.year, now.month, 1);
    _selected = cycle.dateOnly(now);
    _marks = _loadRange(-1, 1);
    AppSettingsController.instance.addListener(_onSettingsChanged);
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    AppSettingsController.instance.removeListener(_onSettingsChanged);
    _scroll.removeListener(_onScroll);
    _scrollDebounce?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _onSettingsChanged() {
    _marksCache = null;
    setState(() => _marks = _loadVisibleRange());
  }

  /// 由月份 index 转为该月首日 DateTime。
  DateTime _monthAt(int index) => DateTime(
        _anchorMonth.year,
        _anchorMonth.month + index,
        1,
      );

  /// 由 DateTime 转为月份 index。
  int _indexOf(DateTime month) {
    final years = month.year - _anchorMonth.year;
    final months = month.month - _anchorMonth.month;
    return years * 12 + months;
  }

  Future<_MarkSet> _loadRange(int fromIndex, int toIndex) async {
    final userId = await getIt<CurrentUser>().id();
    final repo = getIt<RecordRepository>();
    final from = _monthAt(fromIndex);
    final to = DateTime(
      _monthAt(toIndex + 1).year,
      _monthAt(toIndex + 1).month,
      0,
    );

    final days = await repo.periodDaysByRange(userId, from: from, to: to);
    final preds = await repo.predictionsByRange(userId, from: from, to: to);
    final sexRows = await repo.sexByRange(userId, from: from, to: to);
    final sexDates = sexRows.map((s) => cycle.dateOnly(s.date)).toSet();

    final byDate = <DateTime, _DayMark>{};
    for (final d in days) {
      final key = cycle.dateOnly(d.date);
      if (d.isPeriod) {
        byDate[key] = _DayMark(mark: _Mark.period, flow: d.flowLevel, hasSex: sexDates.contains(key));
      }
    }
    final periodDates = days.where((d) => d.isPeriod).map((d) => cycle.dateOnly(d.date)).toSet();

    // 易孕期（teal 区间）：从 windowStart 到 windowEnd 的完整连续区间，
    // 而不是只标记起止两个端点。
    final windowStarts = preds
        .where((p) => p.predictedEvent == 'windowStart')
        .map((p) => cycle.dateOnly(p.predictedDate))
        .toList()
      ..sort();
    final windowEnds = preds
        .where((p) => p.predictedEvent == 'windowEnd')
        .map((p) => cycle.dateOnly(p.predictedDate))
        .toList()
      ..sort();
    for (var i = 0;
        i < windowStarts.length && i < windowEnds.length;
        i++) {
      final s = windowStarts[i];
      final e = windowEnds[i];
      if (e.isBefore(s)) continue;
      var d = s;
      while (!d.isAfter(e)) {
        final key = cycle.dateOnly(d);
        if (!periodDates.contains(key)) {
          byDate.putIfAbsent(
            key,
            () => _DayMark(mark: _Mark.window, hasSex: sexDates.contains(key)),
          );
        }
        d = d.add(const Duration(days: 1));
      }
    }

    // 单点标记：ovulation（琥珀）和 nextPeriod（浅红），
    // 优先级高于 window，覆盖同日期的 teal。
    for (final p in preds) {
      final key = cycle.dateOnly(p.predictedDate);
      if (periodDates.contains(key)) continue;
      final existing = byDate[key];
      final _Mark? mark = switch (p.predictedEvent) {
        'ovulation' => _Mark.ovulation,
        'nextPeriod' => _Mark.predictedPeriod,
        _ => null,
      };
      if (mark == null) continue;
      if (existing == null || existing.mark == _Mark.window) {
        byDate[key] = _DayMark(mark: mark, hasSex: sexDates.contains(key));
      }
    }

    for (final sd in sexDates) {
      byDate.putIfAbsent(sd, () => _DayMark(hasSex: true));
    }

    _loadedFromIndex = fromIndex;
    _loadedToIndex = toIndex;
    return _MarkSet(marks: byDate);
  }

  Future<_MarkSet> _loadVisibleRange() async {
    // 基于 ScrollController 的位置估算当前可见 index 范围。
    // 每个 _MonthBlock 高度不固定，这里保守地以 ±3 个月为缓冲。
    final center = _currentCenterIndex();
    return _loadRange(center - 3, center + 3);
  }

  /// 估算 ScrollController 当前中心对应的月份 index。
  int _currentCenterIndex() {
    if (!_scroll.hasClients) return 0;
    // 粗略估算：假设屏幕中心处的 item 为 center index。
    // 实际每个月高度不同，但滚动时会触发 debounce 重新加载，误差可接受。
    final offset = _scroll.offset;
    final viewportCenter = offset + _scroll.position.viewportDimension / 2;
    final estimatedIndex = (viewportCenter / _kAvgMonthHeight).round() - kMonthRange;
    return estimatedIndex.clamp(-kMonthRange, kMonthRange);
  }

  void _onScroll() {
    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      final center = _currentCenterIndex();
      // 若已加载范围不再覆盖中心 ±2 个月，则重新加载
      if (center - 2 < _loadedFromIndex || center + 2 > _loadedToIndex) {
        setState(() {
          _marks = _loadRange(center - 3, center + 3);
        });
      } else {
        // 仅刷新 AppBar 标题
        setState(() {});
      }
    });
  }

  /// 平滑滚动到指定月份 index。
  Future<void> _animateTo(int targetIndex) async {
    if (!_scroll.hasClients) return;
    final targetOffset = (targetIndex + kMonthRange) * _kAvgMonthHeight;
    await _scroll.animateTo(
      targetOffset.clamp(0.0, _scroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openDay(DateTime day) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrackPage(initialDate: day),
        fullscreenDialog: true,
      ),
    );
    if (!mounted) return;
    setState(() => _selected = day);
    // 强制刷新一次可见范围的数据（记录可能刚改过）
    setState(() => _marks = _loadVisibleRange());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final nowIndex = _indexOf(DateTime(now.year, now.month, 1));
    final centerIndex = _currentCenterIndex();
    final centerMonth = _monthAt(centerIndex);
    final showToday = centerIndex == nowIndex;

    return Scaffold(
      appBar: AppBar(
        title: Text(showToday
            ? l10n.tabCalendar
            : DateFormat.yMMMM(dateLocale(context)).format(centerMonth)),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: l10n.prevMonth,
            onPressed: () => _animateTo(centerIndex - 1),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: l10n.nextMonth,
            onPressed: () => _animateTo(centerIndex + 1),
          ),
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: l10n.backToToday,
            onPressed: () => _animateTo(0),
          ),
        ],
      ),
      body: FutureBuilder<_MarkSet>(
        future: _marks,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done && _marksCache == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final set = snap.data ?? _marksCache;
          if (set == null) {
            return const Center(child: CircularProgressIndicator());
          }
          _marksCache = set;

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _loadedFromIndex = -9999;
                    setState(() => _marks = _loadVisibleRange());
                  },
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemExtent: _kAvgMonthHeight,
                    itemCount: kMonthRange * 2 + 1,
                    itemBuilder: (context, i) {
                      final index = i - kMonthRange;
                      if (index < -kMonthRange || index > kMonthRange) {
                        return const SizedBox.shrink();
                      }
                      return SizedBox(
                        height: _kAvgMonthHeight,
                        child: _MonthBlock(
                          month: _monthAt(index),
                          marks: set.marks,
                          selected: _selected,
                          onSelect: _openDay,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const _LegendBar(),
            ],
          );
        },
      ),
    );
  }
}

class _MarkSet {
  const _MarkSet({required this.marks});
  final Map<DateTime, _DayMark> marks;
}

class _MonthBlock extends StatelessWidget {
  const _MonthBlock({
    required this.month,
    required this.marks,
    required this.selected,
    required this.onSelect,
  });
  final DateTime month;
  final Map<DateTime, _DayMark> marks;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = (first.weekday - 1 + 7) % 7;

    final cells = <DateTime?>[];
    for (var i = 0; i < leading; i++) {
      cells.add(null);
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(month.year, month.month, d));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              DateFormat.yMMMM(dateLocale(context)).format(month),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const _WeekdayHeader(),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            childAspectRatio: 1.1,
            padding: EdgeInsets.zero,
            children: [
              for (final date in cells)
                _DayCell(
                  date: date,
                  mark: date != null ? marks[cycle.dateOnly(date)] : null,
                  isToday: date != null && cycle.dateOnly(DateTime.now()) == cycle.dateOnly(date),
                  selected: date != null && selected != null && cycle.dateOnly(selected!) == cycle.dateOnly(date),
                  onTap: date != null ? () => onSelect(date) : null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final labels = weekdayShortLabels(context);
    return Row(
      children: [
        for (final l in labels)
          Expanded(
            child: Center(
              child: Text(l,
                  style: t.textTheme.labelMedium
                      ?.copyWith(color: t.colorScheme.outline)),
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.mark,
    required this.isToday,
    required this.selected,
    required this.onTap,
  });

  final DateTime? date;
  final _DayMark? mark;
  final bool isToday;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (date == null) return const SizedBox.shrink();
    final t = Theme.of(context);
    final brightness = t.brightness;
    final m = mark?.mark ?? _Mark.blank;

    Color bg = Colors.transparent;
    Color fg = t.colorScheme.onSurface;
    BoxBorder? border;

    switch (m) {
      case _Mark.period:
        bg = AppColors.danger;
        fg = brightness.onBlock(AppColors.danger);
      case _Mark.predictedPeriod:
        bg = brightness.softBg(AppColors.danger);
        fg = AppColors.danger;
      case _Mark.ovulation:
        bg = brightness.softBg(AppColors.amber, lightAlpha: 0.65, darkAlpha: 0.8);
        fg = brightness.onBlock(AppColors.amber);
      case _Mark.window:
        bg = brightness.softBg(AppColors.teal);
        fg = AppColors.teal;
      case _Mark.blank:
        break;
    }

    if (isToday) {
      border = Border.all(color: AppColors.brand, width: 1.8);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: border,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date!.day}',
              style: TextStyle(
                color: fg,
                fontWeight: isToday || m == _Mark.period ? FontWeight.w700 : null,
              ),
            ),
            if (m == _Mark.period && mark?.flow != null)
              Icon(
                Icons.water_drop,
                size: 10,
                color: fg.withValues(alpha: 0.9),
              )
            else if (mark?.hasSex == true)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: m == _Mark.blank ? AppColors.teal : fg.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 日历底部颜色图例：说明各颜色块代表的周期阶段。
class _LegendBar extends StatelessWidget {
  const _LegendBar();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final labels = [
      _LegendItem(color: AppColors.danger, label: l10n.legendPeriod),
      _LegendItem(
        color: t.brightness.softBg(AppColors.danger),
        label: l10n.legendPredictedPeriod,
      ),
      _LegendItem(color: AppColors.teal, label: l10n.legendFertileWindow),
      _LegendItem(
        color: t.brightness.softBg(AppColors.amber,
            lightAlpha: 0.65, darkAlpha: 0.8),
        label: l10n.legendOvulation,
      ),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        border: Border(
          top: BorderSide(color: t.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: labels,
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Text(
          label,
          style: t.textTheme.bodySmall,
        ),
      ],
    );
  }
}

