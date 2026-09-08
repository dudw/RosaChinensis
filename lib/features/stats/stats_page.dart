import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/injection.dart';
import '../../core/i18n/format.dart';
import '../../core/theme/app_theme.dart';
import '../../data/current_user.dart';
import '../../data/repositories/record_repository.dart';
import '../../l10n/app_localizations.dart';
import '../track/track_options.dart';

/// 统计页（PRD 7.7 / 25 章）：周期口径统计 + 追踪记录分析。
///
/// - 记录概览：全历史各分类的记录天数。
/// - 周期：平均周期 / 平均经期（近 6 周期口径）+ 周期长度趋势条。
/// - 症状频率 / 情绪分布：按记录天数的横向占比条。
/// - 体重 / 体温趋势：最近 N 点的折线图 + 极值与均值。
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsBody {
  const _StatsBody({
    this.avgCycle,
    this.avgPeriod,
    required this.cycleLengths,
    required this.summary,
    required this.symptoms,
    required this.moods,
    required this.weight,
    required this.temp,
  });

  /// 平均周期（天）；无数据为 null。
  final double? avgCycle;
  final double? avgPeriod;

  /// 最近一段历史周期长度序列（旧→新）。
  final List<int> cycleLengths;

  /// 全历史记录概览计数。
  final RecordSummary summary;

  /// 症状频次（按记录天数降序）。
  final List<TypeCount> symptoms;
  final List<TypeCount> moods;

  /// 体重 / 体温时间序列（最近 [kMaxTrendPoints] 点，升序）。
  final List<MetricPoint> weight;
  final List<MetricPoint> temp;
}

const int _kMaxTrendPoints = 30;

class _StatsPageState extends State<StatsPage> {
  late Future<_StatsBody> _body;

  @override
  void initState() {
    super.initState();
    _body = _load();
  }

  Future<_StatsBody> _load() async {
    final userId = await getIt<CurrentUser>().id();
    final repo = getIt<RecordRepository>();
    final lengths = await repo.cycleLengths(userId);
    final recent =
        lengths.length <= 6 ? lengths : lengths.sublist(lengths.length - 6);
    // 平均周期与趋势条同口径：取最近【至多 6 个】周期的简单平均，
    // 避免被更早、更长的历史周期拉高（如近期 27~29，却被早期 30+ 拉成 31.4）。
    final avgCycle = recent.isEmpty
        ? null
        : recent.reduce((a, b) => a + b) / recent.length;
    // 平均经期同样统一为近 6 段口径（与周期长度趋势一致）。
    final durations = await repo.periodDurations(userId);
    final recentDurations = durations.length <= 6
        ? durations
        : durations.sublist(durations.length - 6);
    final avgPeriod = recentDurations.isEmpty
        ? null
        : recentDurations.reduce((a, b) => a + b) / recentDurations.length;
    return _StatsBody(
      avgCycle: avgCycle,
      avgPeriod: avgPeriod,
      cycleLengths: recent,
      summary: await repo.recordSummary(userId),
      symptoms: await repo.symptomFrequency(userId),
      moods: await repo.moodCounts(userId),
      weight: _trim(await repo.metricSeries(userId, '体重')),
      temp: _trim(await repo.metricSeries(userId, '体温')),
    );
  }

  List<MetricPoint> _trim(List<MetricPoint> p) =>
      p.length <= _kMaxTrendPoints ? p : p.sublist(p.length - _kMaxTrendPoints);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.statsTitle)),
      body: FutureBuilder<_StatsBody>(
        future: _body,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text(l10n.loadFailed('${snap.error}')));
          }
          final b = snap.data!;
          return RefreshIndicator(
            onRefresh: () async => setState(() => _body = _load()),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── 记录概览 ──
                Text(l10n.statsOverview, style: t.textTheme.titleMedium),
                const SizedBox(height: 12),
                _OverviewGrid(summary: b.summary, unit: l10n.dayUnit),
                const SizedBox(height: 28),

                // ── 周期分析 ──
                Text(l10n.last6Cycles, style: t.textTheme.titleMedium),
                const SizedBox(height: 12),
                if (b.avgCycle == null)
                  _EmptyHint(text: l10n.statsEmpty)
                else ...[
                  Row(
                    children: [
                      _MetricCard(
                          label: l10n.avgCycle,
                          value: _fmt(b.avgCycle),
                          unit: l10n.dayUnit),
                      const SizedBox(width: 12),
                      _MetricCard(
                          label: l10n.avgPeriod,
                          value: _fmt(b.avgPeriod),
                          unit: l10n.dayUnit),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.cycleLengthTrend, style: t.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _TrendBars(lengths: b.cycleLengths),
                ],
                const SizedBox(height: 28),

                // ── 症状频率 ──
                Text(l10n.symptomFrequency, style: t.textTheme.titleMedium),
                const SizedBox(height: 12),
                _FrequencySection(
                  items: b.symptoms,
                  color: AppColors.danger,
                  labelOf: (type) => symptomLabel(l10n, type),
                  emptyText: l10n.noTrackingData,
                ),
                const SizedBox(height: 28),

                // ── 情绪分布 ──
                Text(l10n.moodDistribution, style: t.textTheme.titleMedium),
                const SizedBox(height: 12),
                _FrequencySection(
                  items: b.moods,
                  color: AppColors.brand,
                  labelOf: (type) => moodLabel(l10n, type),
                  emptyText: l10n.noTrackingData,
                ),
                const SizedBox(height: 28),

                // ── 体重 / 体温趋势 ──
                Text(l10n.weightTrend, style: t.textTheme.titleMedium),
                const SizedBox(height: 12),
                _MetricTrend(
                  points: b.weight,
                  unit: 'kg',
                  color: AppColors.teal,
                  emptyText: l10n.noTrackingData,
                ),
                const SizedBox(height: 28),
                Text(l10n.tempTrend, style: t.textTheme.titleMedium),
                const SizedBox(height: 12),
                _MetricTrend(
                  points: b.temp,
                  unit: '℃',
                  color: AppColors.amber,
                  emptyText: l10n.noTrackingData,
                ),
                const SizedBox(height: 20),
                Text(l10n.statsHint, style: t.textTheme.bodySmall),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _fmt(double? v) =>
      v == null ? '—' : v.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

/// 记录概览：全历史各分类记录天数的 2 列网格计数卡。
class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({required this.summary, required this.unit});
  final RecordSummary summary;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      (l10n.trackedDays, summary.trackedDays),
      (l10n.periodDays, summary.periodDays),
      (l10n.symptomDays, summary.symptomDays),
      (l10n.moodDays, summary.moodDays),
      (l10n.sexDays, summary.sexDays),
      (l10n.metricDays, summary.metricDays),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.7,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        for (final (label, value) in items)
          _OverviewCell(label: label, value: value, unit: unit),
      ],
    );
  }
}

class _OverviewCell extends StatelessWidget {
  const _OverviewCell({
    required this.label,
    required this.value,
    required this.unit,
  });
  final String label;
  final int value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: Theme.of(context).textTheme.bodySmall, maxLines: 1),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$value',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text(unit, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.unit,
  });
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(value,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Text(unit, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 频次横向占比条（症状 / 情绪通用）。
class _FrequencySection extends StatelessWidget {
  const _FrequencySection({
    required this.items,
    required this.color,
    required this.labelOf,
    required this.emptyText,
  });
  final List<TypeCount> items;
  final Color color;
  final String Function(String type) labelOf;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _EmptyHint(text: emptyText);
    final maxCount = items.first.count;
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            for (final it in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    SizedBox(
                      width: 92,
                      child: Text(
                        labelOf(it.type),
                        style: t.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: maxCount == 0 ? 0 : it.count / maxCount,
                          minHeight: 12,
                          backgroundColor: color.withValues(alpha: 0.12),
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${it.count}',
                        textAlign: TextAlign.right,
                        style: t.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 身体指标趋势：极值/均值摘要 + 折线图 + 起止日期。
class _MetricTrend extends StatelessWidget {
  const _MetricTrend({
    required this.points,
    required this.unit,
    required this.color,
    required this.emptyText,
  });
  final List<MetricPoint> points;
  final String unit;
  final Color color;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (points.length < 2) return _EmptyHint(text: emptyText);
    final vals = points.map((p) => p.value).toList();
    final min = vals.reduce((a, b) => a < b ? a : b);
    final max = vals.reduce((a, b) => a > b ? a : b);
    final avg = vals.reduce((a, b) => a + b) / vals.length;
    final df = DateFormat.MMMd(dateLocale(context));
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.metricRangeStats(_trim1(min), _trim1(max), _trim1(avg)),
                    style: t.textTheme.bodyMedium,
                  ),
                ),
                Text(unit, style: t.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 120,
              width: double.infinity,
              child: CustomPaint(
                painter: _LinePainter(points: points, color: color),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(df.format(points.first.date), style: t.textTheme.bodySmall),
                Text(df.format(points.last.date), style: t.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _trim1(double v) => v.toStringAsFixed(1);
}

/// 折线图 painter（体重 / 体温）。
class _LinePainter extends CustomPainter {
  const _LinePainter({required this.points, required this.color});
  final List<MetricPoint> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || size.width <= 0 || size.height <= 0) return;
    final vals = points.map((p) => p.value).toList();
    var min = vals.reduce((a, b) => a < b ? a : b);
    var max = vals.reduce((a, b) => a > b ? a : b);
    if (max == min) {
      min -= 1;
      max += 1;
    }
    final dx = points.length == 1 ? 0.0 : size.width / (points.length - 1);
    double yOf(double v) => size.height - (v - min) / (max - min) * size.height;

    // 水平网格线（min / 中值 / max）
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    for (final frac in [0.0, 0.5, 1.0]) {
      final y = size.height * frac;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 折线
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = i * dx;
      final y = yOf(points[i].value);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);

    // 数据点
    final dotPaint = Paint()..color = color;
    for (var i = 0; i < points.length; i++) {
      final c = Offset(i * dx, yOf(points[i].value));
      canvas.drawCircle(c, 3, dotPaint);
      canvas.drawCircle(c, 3, Paint()..color = Colors.white..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.points != points || old.color != color;
}

class _TrendBars extends StatelessWidget {
  const _TrendBars({required this.lengths});

  final List<int> lengths;

  @override
  Widget build(BuildContext context) {
    if (lengths.isEmpty) return const SizedBox.shrink();
    final max = lengths.reduce((a, b) => a > b ? a : b);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < lengths.length; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${lengths[i]}',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Container(
                        height: max == 0
                            ? 4
                            : 8 + 80 * lengths[i] / max,
                        decoration: BoxDecoration(
                          color: i == lengths.length - 1
                              ? scheme.primary
                              : scheme.primary.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${i + 1}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
