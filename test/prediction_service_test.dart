// G Stage：预测服务集成测试（内存库）：记录→重算→快照 与 今日阶段派生。
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:period_tracker/core/db/app_database.dart';
import 'package:period_tracker/data/repositories/record_repository.dart';
import 'package:period_tracker/prediction/prediction_service.dart';

void main() {
  late AppDatabase db;
  late RecordRepository repo;
  late PredictionService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = RecordRepository(db);
    service = PredictionService(repository: repo);
  });

  tearDown(() async {
    await db.close();
  });

  test('recompute 写入 nextPeriod/ovulation/windowStart/windowEnd 快照', () async {
    final userId = await repo.createUser(localId: 'a');
    // 记录一段经期 9/1-9/5
    for (var d = 0; d < 5; d++) {
      await repo.upsertPeriodDay(
        userId: userId,
        date: DateTime(2026, 9, 1).add(Duration(days: d)),
      );
    }

    await service.recompute(userId);

    final preds = await repo.predictionsByRange(
      userId,
      from: DateTime(2026, 9, 1),
      to: DateTime(2026, 11, 30),
    );
    final events = preds.map((e) => e.predictedEvent).toSet();
    expect(events, containsAll(['nextPeriod', 'ovulation', 'windowStart', 'windowEnd']));
  });

  test('todayInfo：经期首日当天判定为已确认经期第 1 天', () async {
    final userId = await repo.createUser(localId: 'b');
    await repo.upsertPeriodDay(
      userId: userId,
      date: DateTime(2026, 9, 1),
    );

    final info = await service.todayInfo(userId, now: DateTime(2026, 9, 1));
    expect(info.phase, TodayPhase.period);
    expect(info.dayNumber, 1);
  });

  test('todayInfo：经期第 5 天判定正确', () async {
    final userId = await repo.createUser(localId: 'c');
    for (var d = 0; d < 5; d++) {
      await repo.upsertPeriodDay(
        userId: userId,
        date: DateTime(2026, 9, 1).add(Duration(days: d)),
      );
    }

    final info = await service.todayInfo(userId, now: DateTime(2026, 9, 5));
    expect(info.phase, TodayPhase.period);
    expect(info.dayNumber, 5);
  });
}