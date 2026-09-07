// 周期数学纯模块（对应 PRD 21.2 / 21.3 / 8.1.1）。
// 本模块只依赖时间与数值计算，不触碰数据库，便于单测。
// 入参统一为「经期首日序列」[periodStarts]（DateOnly 语义，升序去重）。
import 'dart:math' as math;

/// 一组预测结果（对应 21.3 输出，写库前在此计算）。
class CyclePrediction {
  const CyclePrediction({
    required this.nextPeriodStart,
    required this.ovulation,
    required this.windowStart,
    required this.windowEnd,
    required this.meanCycle,
    required this.confidenceRangeDays,
    required this.usedCycles,
  });

  final DateTime nextPeriodStart;
  final DateTime ovulation;
  final DateTime windowStart;
  final DateTime windowEnd;

  /// 加权平均周期（天）。
  final double meanCycle;

  /// 预测置信区间（±天数）。
  final int confidenceRangeDays;

  /// 用于计算的完整周期个数。
  final int usedCycles;
}

/// 周期长度常量（兜底）。
const int defaultCycleLength = 28;
const int ovulationOffsetBeforeNextPeriod = 14;

/// 仅保留日期部分（忽略时分秒），统一比较基准。
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// 从经期首日序列计算相邻周期长度（21.2）。
/// 过滤异常区间：`(15, 540]` 天内视为误录剔除，未完结周期不参与。
List<int> cycleLengths(List<DateTime> periodStarts) {
  final sorted = periodStarts.map(dateOnly).toList()..sort();
  final lengths = <int>[];
  for (var i = 1; i < sorted.length; i++) {
    final d = sorted[i].difference(sorted[i - 1]).inDays;
    if (d > 15 && d <= 540) lengths.add(d);
  }
  return lengths;
}

/// 加权平均周期长度（8.1.1）。
/// 权重 w_i=2^{(i-n)/k}（k 默认 2，近期权重更高）；剔除偏离 >±2σ 的样本后重算。
double weightedMeanCycleLength(List<int> lengths, {double k = 2}) {
  if (lengths.isEmpty) return defaultCycleLength.toDouble();
  var filtered = _withoutOutliers(lengths);
  if (filtered.isEmpty) filtered = lengths;
  final n = filtered.length;
  var wSum = 0.0, vSum = 0.0;
  for (var i = 0; i < n; i++) {
    final w = math.pow(2, (i + 1 - n) / k).toDouble();
    wSum += w;
    vSum += w * filtered[i];
  }
  return vSum / wSum;
}

List<int> _withoutOutliers(List<int> xs) {
  if (xs.length < 2) return xs;
  final mean = xs.reduce((a, b) => a + b) / xs.length;
  final std = math.sqrt(
    xs.fold(0.0, (sum, x) => sum + (x - mean) * (x - mean)) / xs.length,
  );
  return xs.where((x) => (x - mean).abs() <= 2 * std).toList();
}

/// 计算预测（21.3 分支）。
/// [latestPeriodStart]（已知的最近一次经期首日）非空传入时以其为基础，
/// 否则退化到 [fallbackStart]（Onboarding 收敛基线）。
CyclePrediction computePrediction({
  required List<DateTime> periodStarts,
  required DateTime latestPeriodStart,
  int expectedCycleLength = defaultCycleLength,
}) {
  final starts = periodStarts.map(dateOnly).toList()..sort();

  final lengths = cycleLengths(starts);
  double mean;
  int rangeDays;
  if (lengths.isEmpty) {
    mean = expectedCycleLength.toDouble();
    rangeDays = 3;
  } else if (lengths.length < 3) {
    mean = weightedMeanCycleLength(lengths);
    rangeDays = 3; // 少量数据更宽
  } else {
    mean = weightedMeanCycleLength(lengths);
    rangeDays = lengths.length >= 10 ? 2 : 2; // >=10 按 PRD 收窄至 ±2
  }

  final nextPeriod =
      dateOnly(latestPeriodStart).add(Duration(days: mean.round()));
  final ovulation = nextPeriod.subtract(
    const Duration(days: ovulationOffsetBeforeNextPeriod),
  );
  return CyclePrediction(
    nextPeriodStart: nextPeriod,
    ovulation: ovulation,
    windowStart: ovulation.subtract(const Duration(days: 5)),
    windowEnd: ovulation,
    meanCycle: mean,
    confidenceRangeDays: rangeDays,
    usedCycles: lengths.length,
  );
}