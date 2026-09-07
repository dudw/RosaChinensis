// 对齐 8.1.1 示例：周期 29、首日 9/1 → 下期 9/30、排卵 9/16、窗口 9/11–9/16。
import 'package:flutter_test/flutter_test.dart';

import 'package:period_tracker/prediction/cycle_math.dart';

void main() {
  group('cycleLengths', () {
    test('相邻首日差构成周期长度，未完结周期不参与', () {
      final starts = [
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 30), // 29
        DateTime(2026, 7, 29), // 29
        DateTime(2026, 8, 27), // 29
      ];
      expect(cycleLengths(starts), [29, 29, 29]);
    });

    test('剔除异常区间（<=15 或 >540 天）', () {
      final starts = [
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 3), // 2 -> 剔除
        DateTime(2026, 2, 1), // 29（相对 1/1）
        DateTime(2026, 3, 1), // 28
      ];
      expect(cycleLengths(starts), [29, 28]);
    });
  });

  group('weightedMeanCycleLength', () {
    test('无数据退化到兜底 28', () {
      expect(weightedMeanCycleLength([]), 28);
    });

    test('偶数序列的近·加权平均在算术平均附近', () {
      final mean = weightedMeanCycleLength([30, 26, 30, 26, 30, 26]);
      expect(mean, closeTo(28, 1.5));
    });
  });

  group('computePrediction', () {
    test('匹配 8.1.1 示例：29 天周期 → 9/30、9/16、[9/11,9/16]', () {
      final starts = [
        DateTime(2026, 8, 3),
        DateTime(2026, 9, 1), // 相邻 29 天
      ];
      final p = computePrediction(
        periodStarts: starts,
        latestPeriodStart: DateTime(2026, 9, 1),
      );
      expect(p.nextPeriodStart, DateTime(2026, 9, 30));
      expect(p.ovulation, DateTime(2026, 9, 16));
      expect(p.windowStart, DateTime(2026, 9, 11));
      expect(p.windowEnd, DateTime(2026, 9, 16));
      expect(p.usedCycles, 1);
    });

    test('无历史直接以期望周期估测', () {
      final p = computePrediction(
        periodStarts: [],
        latestPeriodStart: DateTime(2026, 9, 1),
        expectedCycleLength: 28,
      );
      expect(p.nextPeriodStart, DateTime(2026, 9, 29));
      expect(p.confidenceRangeDays, 3);
    });
  });
}