import 'dart:math' as math;

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
import '../../prediction/prediction_service.dart';
import '../settings/cycle_personalization_page.dart';

/// 今日页：大圆环进度指示器 + 下次经期大字 + 可能的受孕日入口。
class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late Future<_TodayState> _state;
  bool _showFertile = false;

  @override
  void initState() {
    super.initState();
    _state = _load();
    AppSettingsController.instance.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    AppSettingsController.instance.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() => _refresh();

  Future<_TodayState> _load() async {
    final userId = await getIt<CurrentUser>().id();
    final info = await getIt<PredictionService>().todayInfo(userId);
    final repo = getIt<RecordRepository>();
    final starts = await repo.periodStarts(userId);
    final settings = await CycleSettings.load();
    final now = cycle.dateOnly(DateTime.now());
    final latestPeriodStart = starts.isNotEmpty ? starts.last : now;
    final periodDay = starts.isNotEmpty
        ? now.difference(starts.last).inDays + 1
        : 1;
    // 周期长度 = nextPeriodStart - latestPeriodStart（核心推导值）
    final cycleLength = info.nextPeriodStart
        .difference(latestPeriodStart)
        .inDays
        .clamp(15, 40);
    // 经期长度：优先用数据库已确认的连续天数，没有则默认 5
    int periodLength;
    try {
      final confirmed = await repo.periodDaysByRange(
        userId,
        from: latestPeriodStart,
        to: latestPeriodStart.add(const Duration(days: 14)),
      );
      // 计算从 latestPeriodStart 起连续的 period day 数量
      var count = 0;
      var cursor = latestPeriodStart;
      for (final pd in confirmed) {
        if (pd.date == cursor) {
          count++;
          cursor = cursor.add(const Duration(days: 1));
        } else if (pd.date.isAfter(cursor)) {
          break; // 中间有间断，停
        }
      }
      periodLength = count >= 1 ? count : 5;
    } catch (_) {
      periodLength = 5;
    }
    return _TodayState(
      info: info,
      periodDay: periodDay,
      showFertile: settings.showFertile,
      showOvulation: settings.showOvulation,
      latestPeriodStart: latestPeriodStart,
      cycleLength: cycleLength,
      periodLength: periodLength,
    );
  }

  void _refresh() {
    setState(() {
      _state = _load();
      _showFertile = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.currentCycleTitle)),
      body: FutureBuilder<_TodayState>(
        future: _state,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return Center(
                child: Text(l10n.loadFailed(''), textAlign: TextAlign.center));
          }
          final s = snap.data!;
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Center(child: _Ring(
                    info: s.info,
                    periodDay: s.periodDay,
                    latestPeriodStart: s.latestPeriodStart,
                    cycleLength: s.cycleLength,
                    periodLength: s.periodLength,
                    showFertileIndicator: s.showFertile || s.showOvulation,
                    onToggleExpand: () =>
                        setState(() => _showFertile = !_showFertile),
                    expanded: _showFertile,
                  )),
                  const SizedBox(height: 28),
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: () => RootShell.switchTo(2),
                    icon: const Icon(Icons.add),
                    label: Text(
                      l10n.howAreYouToday,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 仅当圆环上的箭头被点开时，才展示受孕期详细卡片。
                  if (_showFertile && (s.showFertile || s.showOvulation))
                    _FertileInfo(
                      info: s.info,
                      showFertile: s.showFertile,
                      showOvulation: s.showOvulation,
                    ),
                  if (s.info.phase != TodayPhase.period)
                    _PhaseHint(info: s.info),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TodayState {
  const _TodayState({
    required this.info,
    required this.periodDay,
    required this.showFertile,
    required this.showOvulation,
    required this.latestPeriodStart,
    required this.cycleLength,
    required this.periodLength,
  });

  final TodayInfo info;
  final int periodDay;
  final bool showFertile;
  final bool showOvulation;

  /// 数据库里最近一次经期首日（周期锚点）。
  final DateTime latestPeriodStart;

  /// 周期长度（从预测服务反推，15-40 天）。
  final int cycleLength;

  /// 已确认的经期天数（或默认 5）。
  final int periodLength;
}

/// 圆环上一个可点击的未来预测日锚点。
class _DayAnchor {
  const _DayAnchor({
    required this.date,
    required this.phase,
    required this.ratio,
  });

  final DateTime date;
  final TodayPhase phase;

  /// 在圆环上的位置比例 [0,1)。
  final double ratio;
}

/// 大圆环进度指示器——可交互：
/// - 一圈 gray dots 表示未来 ~40 天的预测锚点
/// - 点击任意锚点，中心日期/主文案/进度弧跳到该锚点状态
/// - 点中空白处或选中"今天"点时恢复今日态
class _Ring extends StatefulWidget {
  const _Ring({
    required this.info,
    required this.periodDay,
    required this.latestPeriodStart,
    required this.cycleLength,
    required this.periodLength,
    required this.showFertileIndicator,
    required this.onToggleExpand,
    required this.expanded,
  });

  final TodayInfo info;
  final int periodDay;

  /// 周期锚点（最近一次经期首日，数据库确认）。
  final DateTime latestPeriodStart;

  /// 完整周期长度（nextPeriodStart - latestPeriodStart）。
  final int cycleLength;

  /// 已确认经期长度（或默认 5）。
  final int periodLength;

  final bool showFertileIndicator;
  final VoidCallback onToggleExpand;
  final bool expanded;

  @override
  State<_Ring> createState() => _RingState();
}

class _RingState extends State<_Ring> {
  /// 当前选中的锚点（null = 今日态）。
  _DayAnchor? _selected;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = dateLocale(context);
    final now = cycle.dateOnly(DateTime.now());
    final info = widget.info;

    // ----- 周期基准 -----
    // origin = 数据库确认的最近经期首日，是整个圆环的唯一锚点。
    final origin = cycle.dateOnly(widget.latestPeriodStart);
    final cycleLength = widget.cycleLength;
    final periodLength = widget.periodLength;

    // 基于完整周期推算锚点。
    final anchors = _buildFutureAnchors(
      now,
      info,
      origin,
      cycleLength,
      periodLength,
    );

    // 当前显示目标（选中锚点 或 今日）— 只影响中心文案和天数圆圈
    final displayDate = _selected?.date ?? now;
    final displayPhase = _selected?.phase ?? info.phase;
    // color + progress 始终跟随今日，保持圆环"本来的颜色"不变
    final color = _phaseColor(info.phase);
    final track = t.colorScheme.outlineVariant.withValues(alpha: 0.35);

    // 进度 = 今日在当前周期中的日数 / 周期长度（始终今日）
    final daysFromOrigin = now.difference(origin).inDays;
    final progress =
        (daysFromOrigin % cycleLength).clamp(0, cycleLength) / cycleLength;

    double ratioOf(DateTime d) {
      final days = d.difference(origin).inDays;
      final mod = days % cycleLength;
      return ((mod + cycleLength) % cycleLength) / cycleLength;
    }

    final fertileStartRatio = ratioOf(info.fertileStart);
    final fertileEndRatio = ratioOf(info.fertileEnd);
    final ovulationRatio = ratioOf(info.ovulation);
    final nextPeriodRatio = ratioOf(info.nextPeriodStart);

    // 中心主文案（拆成 title + date 两行）
    final isDisplayingToday = _selected == null;
    // dayN 必须基于 displayDate（选中日期 或 今日），而不是硬编码今日
    final displayDaysFromOrigin = displayDate.difference(origin).inDays;
    final dayN =
        ((displayDaysFromOrigin % cycleLength) + cycleLength) % cycleLength + 1;
    String title;
    String? bigDate; // 下一行超大日期（null = 只用 title）
    if (isDisplayingToday && info.phase == TodayPhase.period) {
      title = l10n.periodDayN(widget.periodDay);
      bigDate = null;
    } else if (displayPhase == TodayPhase.predictedPeriod) {
      title = l10n.yourNextPeriodIs;
      bigDate = DateFormat.MMMd(locale).format(
        displayDate.difference(origin).inDays < 0
            ? info.nextPeriodStart
            : origin.add(
                Duration(
                  days:
                      ((displayDate.difference(origin).inDays ~/ cycleLength) +
                          1) *
                      cycleLength,
                ),
              ),
      );
    } else if (displayPhase == TodayPhase.ovulation) {
      title = l10n.daysUntilNextPeriod;
      bigDate = l10n.daysCount(
          info.nextPeriodStart.difference(displayDate).inDays);
    } else if (displayPhase == TodayPhase.fertileWindow) {
      title = l10n.possibleFertileDays;
      bigDate = DateFormat.MMMd(locale).format(info.ovulation);
    } else if (displayPhase == TodayPhase.period) {
      title = l10n.periodDayN(dayN);
      bigDate = null;
    } else {
      final daysToNext = info.nextPeriodStart.difference(displayDate).inDays;
      if (daysToNext > 0) {
        title = l10n.daysUntilNextPeriod;
        bigDate = l10n.daysCount(daysToNext);
      } else {
        title = l10n.yourNextPeriodIs;
        bigDate = DateFormat.MMMd(locale).format(info.nextPeriodStart);
      }
    }

    final weekdayLabel = DateFormat.MMMEd(locale).format(displayDate);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth * 0.85;

        // 天数圆圈跟随：选中态 → 选中的 anchor ratio；今日态 → 进度弧 progress
        final dayNRatio = _selected != null
            ? ratioOf(_selected!.date)
            : progress;
        const stroke = 44.0; // 和天数小圆圈直径相同
        final ringRadius = (size / 2) - stroke / 2;
        final dayNAngle = -math.pi / 2 + dayNRatio * 2 * math.pi;
        final dayNLeft = size / 2 + ringRadius * math.cos(dayNAngle) - 22;
        final dayNTop = size / 2 + ringRadius * math.sin(dayNAngle) - 22;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CustomPaint(
                  painter: _RingPainter(
                    progress: progress,
                    color: color,
                    track: track,
                    periodRatio: periodLength / cycleLength,
                    fertileStartRatio: fertileStartRatio,
                    fertileEndRatio: fertileEndRatio,
                    ovulationRatio: ovulationRatio,
                    nextPeriodRatio: nextPeriodRatio,
                    showFertileBand: widget.showFertileIndicator,
                    anchors: anchors,
                    selectedRatio: _selected != null
                        ? ratioOf(_selected!.date)
                        : null,
                  ),
                ),
              ),
              // 中心日期 + 主文案（title + bigDate 两行） + 受孕日入口
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    weekdayLabel,
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: t.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: bigDate == null
                        ? t.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: color,
                          )
                        : t.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                  ),
                  if (bigDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      bigDate,
                      textAlign: TextAlign.center,
                      style: t.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  // "可能的受孕日"入口只在今日处于易孕期时出现
                  if (widget.showFertileIndicator &&
                      isDisplayingToday &&
                      info.phase == TodayPhase.fertileWindow)
                    GestureDetector(
                      onTap: widget.onToggleExpand,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.possibleFertileDays,
                            style: t.textTheme.bodyMedium?.copyWith(
                              color: AppColors.teal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            widget.expanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: 20,
                            color: AppColors.teal,
                          ),
                        ],
                      ),
                    ),
                  // 其他情况（关闭了受孕期显示 或 今日不在易孕期）显示阶段标签
                  if (isDisplayingToday &&
                      !(widget.showFertileIndicator &&
                          info.phase == TodayPhase.fertileWindow))
                    _PhaseChip(info: info),
                  if (!isDisplayingToday)
                    Text(
                      l10n.backToTodayHint,
                      style: t.textTheme.bodySmall?.copyWith(
                        color: t.colorScheme.outline,
                      ),
                    ),
                ],
              ),
              // 天数圆圈：跟随当前选中的 anchor 或今日进度点
              Positioned(
                left: dayNLeft,
                top: dayNTop,
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: t.colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$dayN',
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l10n.dayUnitShort,
                        style: t.textTheme.labelSmall?.copyWith(height: 1),
                      ),
                    ],
                  ),
                ),
              ),
              // Hit test 层（最上层）：Positioned.fill + GestureDetector
              // 点击圆环带内的位置命中最近的 anchor。
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapUp: (details) {
                    final localX = details.localPosition.dx;
                    final localY = details.localPosition.dy;
                    final center = Offset(size / 2, size / 2);
                    final distToCenter = math.sqrt(
                      (localX - center.dx) * (localX - center.dx) +
                          (localY - center.dy) * (localY - center.dy),
                    );

                    // 只响应圆环带内的点击（0.25r ~ 0.70r）
                    if (distToCenter < size * 0.25 ||
                        distToCenter > size * 0.70) {
                      setState(() => _selected = null);
                      return;
                    }

                    // 算每个 anchor 在圆环上的实际坐标，找距离最近的。
                    const hitStroke = 44.0;
                    final ringRadius = (size / 2) - hitStroke / 2;
                    Offset anchorCoord(_DayAnchor a) {
                      final angle = a.ratio * 2 * math.pi - math.pi / 2;
                      return Offset(
                        center.dx + ringRadius * math.cos(angle),
                        center.dy + ringRadius * math.sin(angle),
                      );
                    }

                    double bestDist = double.infinity;
                    _DayAnchor? best;
                    for (final a in anchors) {
                      final c = anchorCoord(a);
                      final d = math.sqrt(
                        (localX - c.dx) * (localX - c.dx) +
                            (localY - c.dy) * (localY - c.dy),
                      );
                      if (d < bestDist) {
                        bestDist = d;
                        best = a;
                      }
                    }

                    const hitThreshold = 22.0; // px（每天一个锚点，间距约 40px 弧长）
                    if (best != null && bestDist < hitThreshold) {
                      if (cycle.dateOnly(best.date) == now) {
                        setState(() => _selected = null);
                      } else {
                        setState(() => _selected = best);
                      }
                    } else {
                      setState(() => _selected = null);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 根据 TodayInfo + 完整周期推算锚点列表。
  /// 锚点在圆环上**每天一个**：ratio 按 cycleLength 等分，每个 ratio 对应周期中的确切一天。
  /// 这样锚点在圆环上的密度 = 日历日密度，点击点 = 某一天，phase 由 _phaseOfDate 自动推算。
  List<_DayAnchor> _buildFutureAnchors(
    DateTime now,
    TodayInfo info,
    DateTime origin,
    int cycleLength,
    int periodLength,
  ) {
    final anchors = <_DayAnchor>[];

    // 每天一个锚点：ratio = i / cycleLength，i ∈ [0, cycleLength)
    for (var i = 0; i < cycleLength; i++) {
      final r = i / cycleLength;
      final date = origin.add(Duration(days: i));
      final phase = _phaseOfDate(
        date,
        info,
        origin,
        cycleLength,
        periodLength,
        now,
      );
      anchors.add(_DayAnchor(date: date, phase: phase, ratio: r));
    }

    return anchors;
  }

  /// 基于完整周期推算某一天的 phase。
  /// 优先级：已确认经期 > 排卵日 > 易孕期 > 预测经期 > normal。
  TodayPhase _phaseOfDate(
    DateTime d,
    TodayInfo info,
    DateTime origin,
    int cycleLength,
    int periodLength,
    DateTime now,
  ) {
    final df = cycle.dateOnly(d);
    final daysFromOrigin = df.difference(origin).inDays;
    if (daysFromOrigin < 0) return TodayPhase.normal;

    final dayInCycle = daysFromOrigin % cycleLength;

    // 1) 经期段：dayInCycle ∈ [0, periodLength)
    if (dayInCycle < periodLength) {
      final cycleIndex = daysFromOrigin ~/ cycleLength;
      final isCurrentCycle = cycleIndex == 0;
      if (isCurrentCycle && !df.isAfter(now)) {
        return TodayPhase.period; // 已确认
      }
      return TodayPhase.predictedPeriod;
    }

    // 2) 排卵日：用 TodayInfo.ovulation 在周期中的偏移，推算任意周期
    final ovulationOffset = cycle
        .dateOnly(info.ovulation)
        .difference(origin)
        .inDays;
    final ovDayInCycle =
        ((ovulationOffset % cycleLength) + cycleLength) % cycleLength;
    if (dayInCycle == ovDayInCycle) {
      return TodayPhase.ovulation;
    }

    // 3) 易孕期：用 fertileStart/fertileEnd 在周期中的偏移
    final fsOffset = cycle
        .dateOnly(info.fertileStart)
        .difference(origin)
        .inDays;
    final feOffset = cycle.dateOnly(info.fertileEnd).difference(origin).inDays;
    final fsDay = ((fsOffset % cycleLength) + cycleLength) % cycleLength;
    final feDay = ((feOffset % cycleLength) + cycleLength) % cycleLength;

    if (fsDay <= feDay) {
      if (dayInCycle >= fsDay && dayInCycle <= feDay) {
        return TodayPhase.fertileWindow;
      }
    } else {
      // 跨周期边界
      if (dayInCycle >= fsDay || dayInCycle <= feDay) {
        return TodayPhase.fertileWindow;
      }
    }

    return TodayPhase.normal;
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.track,
    required this.periodRatio,
    required this.fertileStartRatio,
    required this.fertileEndRatio,
    required this.ovulationRatio,
    required this.nextPeriodRatio,
    required this.showFertileBand,
    required this.anchors,
    required this.selectedRatio,
  });

  final double progress;
  final Color color;
  final Color track;
  final double periodRatio;
  final double fertileStartRatio;
  final double fertileEndRatio;
  final double ovulationRatio;
  final double nextPeriodRatio;
  final bool showFertileBand;

  /// 圆环上要画的未来预测日锚点。
  final List<_DayAnchor> anchors;

  /// 当前选中锚点在圆环上的比例 [0,1)，null 表示今日态无选中。
  final double? selectedRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    const stroke = 44.0;
    const dotRadius = 4.5;
    final ring = Rect.fromCircle(center: center, radius: radius - stroke / 2);
    const startAngle = -math.pi / 2;

    final trackPaint = Paint()
      ..color = track
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 1) 底色圈
    canvas.drawCircle(center, radius - stroke / 2, trackPaint);

    // 1.5) 经期弧段（danger 红色，固定位置 0 ~ periodRatio）
    if (periodRatio > 0) {
      final periodPaint = Paint()
        ..color = AppColors.danger
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        ring,
        startAngle,
        periodRatio * 2 * math.pi,
        false,
        periodPaint,
      );
    }

    if (showFertileBand) {
      // 2) 受孕期弧段（teal 半透明底色，宽一点让它看起来是在底下）
      final fertilePaint = Paint()
        ..color = AppColors.teal.withValues(alpha: 0.35)
        ..strokeWidth = stroke + 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      void drawArcSegment(double fromRatio, double toRatio) {
        if (toRatio <= fromRatio) return;
        canvas.drawArc(
          ring,
          startAngle + fromRatio * 2 * math.pi,
          (toRatio - fromRatio) * 2 * math.pi,
          false,
          fertilePaint,
        );
      }

      if (fertileStartRatio <= fertileEndRatio) {
        drawArcSegment(fertileStartRatio, fertileEndRatio);
      } else {
        drawArcSegment(fertileStartRatio, 1.0);
        drawArcSegment(0.0, fertileEndRatio);
      }
    }

    // 3) 进度弧（渐变，覆盖在底色之上）。
    //    起点 = 经期结束位置（periodRatio），避免覆盖红色经期弧。
    //    如果今日仍在经期（progress <= periodRatio），则不画（红色经期弧已承担视觉）。
    final arcStart = periodRatio;
    final arcEnd = progress.clamp(arcStart, 1.0);
    if (arcEnd > arcStart) {
      final activePaint = Paint()
        ..shader = SweepGradient(
          startAngle: startAngle + arcStart * 2 * math.pi,
          endAngle: startAngle + arcEnd * 2 * math.pi,
          colors: [color, color.withValues(alpha: 0.55)],
        ).createShader(ring)
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        ring,
        startAngle + arcStart * 2 * math.pi,
        (arcEnd - arcStart) * 2 * math.pi,
        false,
        activePaint,
      );
    }

    // 4) 均匀分布的可点击锚点：统一灰色小点（phase 由 arc + 关键标记点表达）
    for (final a in anchors) {
      final ratio = a.ratio;
      final isSelected =
          selectedRatio != null && (ratio - selectedRatio!).abs() < 0.01;

      // 统一灰色 phase 独立表达
      final dotColor = isSelected ? AppColors.brand : const Color(0xFFBDBDBD);

      final angle = ratio * 2 * math.pi + startAngle;
      final dotR = isSelected ? dotRadius + 2 : dotRadius - 1;
      final dx = center.dx + (radius - stroke / 2) * math.cos(angle);
      final dy = center.dy + (radius - stroke / 2) * math.sin(angle);

      canvas.drawCircle(
        Offset(dx, dy),
        dotR,
        Paint()
          ..color = dotColor
          ..style = PaintingStyle.fill,
      );

      if (isSelected) {
        canvas.drawCircle(
          Offset(dx, dy),
          dotR + 2.5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8,
        );
      }
    }

    // 5) 关键标记点（排卵日 / 下次经期）
    if (showFertileBand) {
      _drawAngleDot(
        canvas,
        center,
        radius,
        startAngle + ovulationRatio * 2 * math.pi,
        AppColors.amber,
        dotRadius,
      );
      _drawAngleDot(
        canvas,
        center,
        radius,
        startAngle + nextPeriodRatio * 2 * math.pi,
        AppColors.danger,
        dotRadius + 1.5,
      );
    }
  }

  void _drawAngleDot(
    Canvas canvas,
    Offset center,
    double ringRadius,
    double angle,
    Color color,
    double dotR,
  ) {
    const stroke = 44.0;
    final dx = center.dx + (ringRadius - stroke / 2) * math.cos(angle);
    final dy = center.dy + (ringRadius - stroke / 2) * math.sin(angle);
    canvas.drawCircle(
      Offset(dx, dy),
      dotR,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(dx, dy),
      dotR + 1.5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      color != oldDelegate.color ||
      track != oldDelegate.track ||
      periodRatio != oldDelegate.periodRatio ||
      fertileStartRatio != oldDelegate.fertileStartRatio ||
      fertileEndRatio != oldDelegate.fertileEndRatio ||
      ovulationRatio != oldDelegate.ovulationRatio ||
      nextPeriodRatio != oldDelegate.nextPeriodRatio ||
      showFertileBand != oldDelegate.showFertileBand ||
      anchors != oldDelegate.anchors ||
      selectedRatio != oldDelegate.selectedRatio;
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({required this.info});

  final TodayInfo info;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final color = _phaseColor(info.phase);
    final borderAlpha = t.brightness == Brightness.dark ? 0.7 : 0.5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: borderAlpha)),
      ),
      child: Text(
        info.isPredicted ? l10n.predictedChip : l10n.confirmedChip,
        style: t.textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class _PhaseHint extends StatelessWidget {
  const _PhaseHint({required this.info});

  final TodayInfo info;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final color = _phaseColor(info.phase);
    final bgAlpha = t.brightness == Brightness.dark ? 0.2 : 0.08;
    final now = cycle.dateOnly(DateTime.now());
    final daysToOvulation = now.difference(info.ovulation).inDays;
    final subtitle = switch (info.phase) {
      TodayPhase.predictedPeriod =>
        l10n.predictedPeriodSubtitle(info.confidenceRangeDays),
      TodayPhase.ovulation => l10n.ovulationSubtitle,
      TodayPhase.fertileWindow => daysToOvulation == 0
          ? l10n.fertileWindowSubtitleToday
          : l10n.fertileWindowSubtitleInDays(-daysToOvulation),
      TodayPhase.normal =>
        l10n.normalSubtitle(info.nextPeriodStart.difference(now).inDays),
      TodayPhase.period => '',
    };
    return Card(
      color: color.withValues(alpha: bgAlpha),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.insights_outlined, color: color),
            const SizedBox(width: 12),
            Expanded(child: Text(subtitle, style: t.textTheme.bodyMedium)),
          ],
        ),
      ),
    );
  }
}

Color _phaseColor(TodayPhase phase) => switch (phase) {
  TodayPhase.period => AppColors.danger,
  TodayPhase.predictedPeriod => AppColors.danger.withValues(alpha: 0.7),
  TodayPhase.ovulation => AppColors.amber,
  TodayPhase.fertileWindow => AppColors.teal,
  TodayPhase.normal => AppColors.brand,
};

/// 受孕期详情卡片。
/// 根据用户设置显示 / 隐藏排卵日与受孕期。
class _FertileInfo extends StatelessWidget {
  const _FertileInfo({
    required this.info,
    required this.showFertile,
    required this.showOvulation,
  });

  final TodayInfo info;
  final bool showFertile;
  final bool showOvulation;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final df = DateFormat.MMMd(dateLocale(context));
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: AppColors.teal.withValues(
          alpha: t.brightness == Brightness.dark ? 0.18 : 0.10,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppColors.teal,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.possibleFertileDays,
                    style: t.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (showFertile) ...[
                _InfoRow(
                  label: l10n.fertileWindowLabel,
                  value:
                      '${df.format(info.fertileStart)} – ${df.format(info.fertileEnd)}',
                  color: AppColors.teal,
                ),
                const SizedBox(height: 8),
              ],
              if (showOvulation) ...[
                _InfoRow(
                  label: l10n.predictedOvulationLabel,
                  value: df.format(info.ovulation),
                  color: AppColors.amber,
                ),
                const SizedBox(height: 8),
              ],
              Text(
                l10n.fertileDisclaimer,
                style: t.textTheme.bodySmall?.copyWith(
                  color: t.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: t.textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
