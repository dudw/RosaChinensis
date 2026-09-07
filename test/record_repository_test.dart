// B Stage DAO 集成测试：用内存 drift 库验证 upsert 唯一键合并、统计、级联清除。
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:period_tracker/core/db/app_database.dart';
import 'package:period_tracker/data/repositories/record_repository.dart';

void main() {
  late AppDatabase db;
  late RecordRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = RecordRepository(db);
    // 各表 userId 外键指向 users.id（schema 已启用 foreign_keys），须先建用户行。
    await repo.createUser(localId: 'test');
  });

  tearDown(() async {
    await db.close();
  });

  test('upsert 按 (userId,date) 唯一键合并，同一经期日不重复', () async {
    await repo.upsertPeriodDay(
      userId: 1,
      date: DateTime(2026, 9, 1),
      flowLevel: 2,
    );
    await repo.upsertPeriodDay(
      userId: 1,
      date: DateTime(2026, 9, 1),
      isPeriod: false, // 再次写入同键 → 应更新而非新增
    );
    final rows = await db.select(db.periodDays).get();
    expect(rows, hasLength(1));
    expect(rows.single.isPeriod, isFalse);
  });

  test('预测快照按 (userId,event,date) 唯一键 upsert', () async {
    await repo.upsertPrediction(userId: 1, event: 'nextPeriod', date: DateTime(2026, 9, 30));
    await repo.upsertPrediction(
      userId: 1,
      event: 'nextPeriod',
      date: DateTime(2026, 9, 30),
      confidenceRange: '+-2d',
      modelVersion: '1',
    );
    final rows = await db.select(db.predictionSnapshots).get();
    expect(rows, hasLength(1));
    expect(rows.single.confidenceRange, '+-2d');
    expect(rows.single.modelVersion, '1');
  });

  test('周期统计：平均周期与平均经期持续', () async {
    final base = DateTime(2026, 1, 1);
    // 段1：1/1-1/5（5天），段2：1/30-2/3（5天），段3：3/1-3/5（5天）
    for (final d in [0, 1, 2, 3, 4]) {
      await repo.upsertPeriodDay(userId: 1, date: base.add(Duration(days: d)));
    }
    for (final d in [0, 1, 2, 3, 4]) {
      // 1/30
      await repo.upsertPeriodDay(
          userId: 1, date: DateTime(2026, 1, 30).add(Duration(days: d)));
    }
    for (final d in [0, 1, 2, 3, 4]) {
      await repo.upsertPeriodDay(
          userId: 1, date: DateTime(2026, 3, 1).add(Duration(days: d)));
    }

    expect(await repo.averagePeriodLength(1), closeTo(5, 1e-9));
    // 周期 1/1->1/30 = 29，1/30->3/1 = 30 → 平均 29.5
    expect(await repo.averageCycleLength(1), closeTo(29.5, 1e-9));
  });

  test('性生活标签按 (userId,date,tag) 唯一键去重，clearSexByDate 清空当天', () async {
    final date = DateTime(2026, 9, 5);
    await repo.upsertSex(userId: 1, date: date, tag: 'protected');
    await repo.upsertSex(userId: 1, date: date, tag: 'protected'); // 同键 → 跳过
    await repo.upsertSex(userId: 1, date: date, tag: 'orgasm');

    var rows = await repo.sexByRange(1, from: date, to: date);
    expect(rows, hasLength(2));
    expect(rows.map((r) => r.tag).toList()..sort(), ['orgasm', 'protected']);

    await repo.clearSexByDate(userId: 1, date: date);
    rows = await repo.sexByRange(1, from: date, to: date);
    expect(rows, isEmpty);
  });

  test('clearUserData 级联删除该用户全部数据', () async {
    await repo.upsertPeriodDay(userId: 1, date: DateTime(2026, 9, 1));
    await repo.upsertSymptom(
        userId: 1, date: DateTime(2026, 9, 1), symptomType: '头痛');
    await repo.upsertSex(userId: 1, date: DateTime(2026, 9, 1), tag: 'protected');
    await repo.upsertPrediction(userId: 1, event: 'nextPeriod', date: DateTime(2026, 9, 30));

    await repo.clearUserData(1);

    expect(await db.select(db.periodDays).get(), isEmpty);
    expect(await db.select(db.symptomRecords).get(), isEmpty);
    expect(await db.select(db.sexRecords).get(), isEmpty);
    expect(await db.select(db.users).get(), isEmpty);
  });

  test('新增的单日回显查询与删除方法：增改删闭环', () async {
    final d = DateTime(2026, 9, 6);
    // 写入一行经期日（含备注）、症状、情绪、体重指标。
    await repo.upsertPeriodDay(userId: 1, date: d, isPeriod: true, flowLevel: 2, note: '备注');
    await repo.upsertSymptom(userId: 1, date: d, symptomType: '腹痛');
    await repo.upsertMood(userId: 1, date: d, moodType: '平静');
    await repo.upsertBodyMetric(userId: 1, date: d, metricType: '体重', value: 52.5);

    // 单日回显。
    expect((await repo.periodDaysByRange(1, from: d, to: d)).single.note, '备注');
    expect(await repo.symptomsByRange(1, from: d, to: d), hasLength(1));
    expect(await repo.moodsByRange(1, from: d, to: d), hasLength(1));
    expect((await repo.metricsByRange(1, from: d, to: d)).single.value, closeTo(52.5, 1e-9));

    // 取消选择 → 删除对应记录。
    await repo.deletePeriodDay(userId: 1, date: d);
    await repo.deleteSymptom(userId: 1, date: d, symptomType: '腹痛');
    await repo.deleteMood(userId: 1, date: d, moodType: '平静');
    await repo.deleteBodyMetric(userId: 1, date: d, metricType: '体重');

    expect(await repo.periodDaysByRange(1, from: d, to: d), isEmpty);
    expect(await repo.symptomsByRange(1, from: d, to: d), isEmpty);
    expect(await repo.moodsByRange(1, from: d, to: d), isEmpty);
    expect(await repo.metricsByRange(1, from: d, to: d), isEmpty);
  });

  test('追踪统计：记录概览 / 症状频次 / 情绪频次 / 指标序列', () async {
    // 经期：9/1-9/2（2 天）
    await repo.upsertPeriodDay(userId: 1, date: DateTime(2026, 9, 1));
    await repo.upsertPeriodDay(userId: 1, date: DateTime(2026, 9, 2));
    // 症状：9/1 腹痛；9/2 头痛 + 疲劳（3 条 / 2 天）
    await repo.upsertSymptom(userId: 1, date: DateTime(2026, 9, 1), symptomType: '腹痛');
    await repo.upsertSymptom(userId: 1, date: DateTime(2026, 9, 2), symptomType: '头痛');
    await repo.upsertSymptom(userId: 1, date: DateTime(2026, 9, 2), symptomType: '疲劳');
    // 情绪：9/1 平静 + 开心
    await repo.upsertMood(userId: 1, date: DateTime(2026, 9, 1), moodType: '平静');
    await repo.upsertMood(userId: 1, date: DateTime(2026, 9, 1), moodType: '开心');
    // 体重：9/1 52.5，9/3 52.0
    await repo.upsertBodyMetric(userId: 1, date: DateTime(2026, 9, 1), metricType: '体重', value: 52.5);
    await repo.upsertBodyMetric(userId: 1, date: DateTime(2026, 9, 3), metricType: '体重', value: 52.0);
    // 性生活
    await repo.upsertSex(userId: 1, date: DateTime(2026, 9, 1), tag: 'protected');

    final s = await repo.recordSummary(1);
    expect(s.trackedDays, 3); // 9/1 9/2 9/3
    expect(s.periodDays, 2);
    expect(s.symptomDays, 2);
    expect(s.moodDays, 1);
    expect(s.sexDays, 1);
    expect(s.metricDays, 2);

    final syms = await repo.symptomFrequency(1);
    expect(syms.map((e) => e.type).toSet(), {'腹痛', '头痛', '疲劳'});
    expect(syms.every((e) => e.count == 1), isTrue);
    // 频次应为降序
    for (var i = 1; i < syms.length; i++) {
      expect(syms[i].count <= syms[i - 1].count, isTrue);
    }

    final moods = await repo.moodCounts(1);
    expect(moods, hasLength(2));
    expect(moods.map((e) => e.type).toSet(), {'平静', '开心'});

    final wt = await repo.metricSeries(1, '体重');
    expect(wt, hasLength(2));
    expect(wt.first.value, closeTo(52.5, 1e-9));
    expect(wt.last.value, closeTo(52.0, 1e-9));
    expect(wt.first.date.isBefore(wt.last.date), isTrue);
  });
}