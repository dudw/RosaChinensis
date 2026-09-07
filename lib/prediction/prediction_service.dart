import '../data/repositories/record_repository.dart';
import 'cycle_math.dart' as cycle;

/// 今日所处阶段（D 今日页展示用）。
enum TodayPhase { period, predictedPeriod, fertileWindow, ovulation, normal }

/// 今日阶段信息结构。
class TodayInfo {
  const TodayInfo({
    required this.phase,
    this.dayNumber,
    required this.confidenceRangeDays,
    required this.nextPeriodStart,
    required this.ovulation,
    required this.fertileStart,
    required this.fertileEnd,
  });

  final TodayPhase phase;
  final int? dayNumber;
  final int confidenceRangeDays;
  final DateTime nextPeriodStart;
  final DateTime ovulation;
  final DateTime fertileStart;
  final DateTime fertileEnd;

  bool get isPredicted => phase == TodayPhase.predictedPeriod ||
      phase == TodayPhase.fertileWindow ||
      phase == TodayPhase.ovulation;
}

/// 预测服务（PRD 21 / G Stage）：
/// 读取经期记录 → 计算预测 → 写入 PredictionSnapshots；并为今日页派生阶段。
class PredictionService {
  PredictionService({required RecordRepository repository})
      : _repo = repository;

  final RecordRepository _repo;

  /// 全量重算并写快照（记录写入后调用）。
  /// 先清理旧快照，再循环生成未来 [cyclesAhead] 个周期的预测快照，
  /// 确保日历能正确展示多个周期的连续预测，且不会累积脏数据。
  Future<void> recompute(int userId, {int cyclesAhead = 6}) async {
    await _repo.clearPredictions(userId);

    final starts = await _repo.periodStarts(userId);
    final latest = await _repo.latestPeriodStart(userId);
    if (latest == null) return;

    var base = latest;
    for (var i = 0; i < cyclesAhead; i++) {
      final p = cycle.computePrediction(
        periodStarts: starts,
        latestPeriodStart: base,
      );
      final confidence = '+/-${p.confidenceRangeDays}d';

      await _repo.upsertPrediction(
        userId: userId,
        event: 'nextPeriod',
        date: p.nextPeriodStart,
        confidenceRange: confidence,
        modelVersion: '2',
      );
      await _repo.upsertPrediction(
        userId: userId,
        event: 'ovulation',
        date: p.ovulation,
        confidenceRange: confidence,
        modelVersion: '2',
      );
      await _repo.upsertPrediction(
        userId: userId,
        event: 'windowStart',
        date: p.windowStart,
        modelVersion: '2',
      );
      await _repo.upsertPrediction(
        userId: userId,
        event: 'windowEnd',
        date: p.windowEnd,
        modelVersion: '2',
      );

      base = p.nextPeriodStart;
    }
  }

  /// 今日阶段派生（21.3 / 24 章），按 已确认 > 预测 优先级判定。
  /// 同时返回完整预测字段供首页/日历渲染。
  Future<TodayInfo> todayInfo(int userId, {DateTime? now}) async {
    final today = cycle.dateOnly(now ?? DateTime.now());
    final starts = await _repo.periodStarts(userId);
    final latest = await _repo.latestPeriodStart(userId);

    // 完整预测（完全走自适应，周期长度无需用户填写）。
    final p = latest == null
        ? cycle.computePrediction(
            periodStarts: const [],
            latestPeriodStart: today,
          )
        : cycle.computePrediction(
            periodStarts: starts,
            latestPeriodStart: latest,
          );

    // 已确认经期：沿最近首日起判定连续段内 days。
    if (latest != null && starts.isNotEmpty) {
      final isPeriodToday = await _repo.periodDaysByRange(userId,
          from: today, to: today);
      final confirmedToday =
          isPeriodToday.isNotEmpty && isPeriodToday.first.isPeriod;
      if (confirmedToday && !today.isBefore(latest)) {
        final dayN = today.difference(latest).inDays + 1;
        return TodayInfo(
          phase: TodayPhase.period,
          dayNumber: dayN,
          confidenceRangeDays: p.confidenceRangeDays,
          nextPeriodStart: p.nextPeriodStart, ovulation: p.ovulation, fertileStart: p.windowStart, fertileEnd: p.windowEnd,
        );
      }
    }

    if (!today.isBefore(p.nextPeriodStart) &&
        today.difference(p.nextPeriodStart).inDays <= 7) {
      final dayN = today.difference(p.nextPeriodStart).inDays + 1;
      return TodayInfo(
        phase: TodayPhase.predictedPeriod,
        dayNumber: dayN,
        confidenceRangeDays: p.confidenceRangeDays,
        nextPeriodStart: p.nextPeriodStart, ovulation: p.ovulation, fertileStart: p.windowStart, fertileEnd: p.windowEnd,
      );
    }
    if (today == p.ovulation) {
      return TodayInfo(
        phase: TodayPhase.ovulation,
        dayNumber: null,
        confidenceRangeDays: p.confidenceRangeDays,
        nextPeriodStart: p.nextPeriodStart, ovulation: p.ovulation, fertileStart: p.windowStart, fertileEnd: p.windowEnd,
      );
    }
    final daysToOvulation = today.difference(p.ovulation).inDays;
    if (daysToOvulation >= -5 && daysToOvulation <= 0) {
      return TodayInfo(
        phase: TodayPhase.fertileWindow,
        dayNumber: null,
        confidenceRangeDays: p.confidenceRangeDays,
        nextPeriodStart: p.nextPeriodStart, ovulation: p.ovulation, fertileStart: p.windowStart, fertileEnd: p.windowEnd,
      );
    }

    return TodayInfo(
      phase: TodayPhase.normal,
      dayNumber: null,
      confidenceRangeDays: p.confidenceRangeDays,
      nextPeriodStart: p.nextPeriodStart, ovulation: p.ovulation, fertileStart: p.windowStart, fertileEnd: p.windowEnd,
    );
  }
}