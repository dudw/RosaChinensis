// 数据迁移服务测试：导出 JSON + 合并去重导入 + schema 校验回滚。
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:period_tracker/core/db/app_database.dart';
import 'package:period_tracker/data/data_transfer_service.dart';
import 'package:period_tracker/data/repositories/record_repository.dart';

void main() {
  late AppDatabase db;
  late DataTransferService transfer;
  late RecordRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    transfer = DataTransferService(db);
    repo = RecordRepository(db);
    // 各表 userId 外键指向 users.id（schema 已启用 foreign_keys），须先建用户行。
    await repo.createUser(localId: 'test');
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> exportJsonString(int userId) async =>
      const JsonEncoder.withIndent('  ').convert(await transfer.exportJson(userId));

  test('导出 JSON 可原样回导（经期/症状/情绪/性生活/预测全表往返）', () async {
    // 造一份数据。
    await repo.upsertPeriodDay(userId: 1, date: DateTime(2026, 9, 1), flowLevel: 2);
    await repo.upsertSymptom(userId: 1, date: DateTime(2026, 9, 1), symptomType: '头痛');
    await repo.upsertMood(userId: 1, date: DateTime(2026, 9, 1), moodType: '平静');
    await repo.upsertSex(userId: 1, date: DateTime(2026, 9, 1), tag: 'protected');
    await repo.upsertPrediction(userId: 1, event: 'nextPeriod', date: DateTime(2026, 9, 30));

    // 导出到另一用户，再导入回用户 1（应全部跳过，因为唯一键已存在）。
    final json = await exportJsonString(1);
    final report = await transfer.import(1, json);

    expect(report.totalInserted, 0);
    expect(report.totalSkipped, 5);
    // 数据未被重复。
    expect(await db.select(db.periodDays).get(), hasLength(1));
    expect(await db.select(db.symptomRecords).get(), hasLength(1));
    expect(await db.select(db.sexRecords).get(), hasLength(1));
  });

  test('导入唯一键不冲突时新增，冲突时跳过不覆盖本地', () async {
    // 本地已有 9/1 的经期（流量 1）。
    await repo.upsertPeriodDay(userId: 1, date: DateTime(2026, 9, 1), flowLevel: 1);

    // 导入内容：同键 9/1（流量 3）→ 跳过；新键 9/5（流量 2）→ 新增。
    final payload = {
      'schema_version': db.schemaVersion,
      'exported_at': DateTime(2026, 9, 4).toIso8601String(),
      'data': {
        'period_days': [
          {'id': 99, 'userId': 99, 'date': '2026-09-01T00:00:00Z', 'isPeriod': true, 'flowLevel': 3, 'note': null},
          {'id': 100, 'userId': 99, 'date': '2026-09-05T00:00:00Z', 'isPeriod': true, 'flowLevel': 2, 'note': 'x'},
        ],
      },
    };
    final report = await transfer.import(1, jsonEncode(payload));

    expect(report.skipped['period_days'], 1);
    expect(report.inserted['period_days'], 1);

    final rows = await db.select(db.periodDays).get();
    expect(rows, hasLength(2));
    // 本地 9/1 流量保持 1（未被覆盖）。
    final local = rows.singleWhere((r) => r.date == DateTime(2026, 9, 1));
    expect(local.flowLevel, 1);
    // 导入用户 id 被重映射到当前用户 1，而非原文的 99。
    expect(rows.every((r) => r.userId == 1), isTrue);
  });

  test('schema 版本不匹配时整笔拒绝，不写入任何数据', () async {
    final payload = {
      'schema_version': db.schemaVersion + 1, // 假版本
      'data': {
        'period_days': [
          {'date': '2026-09-01T00:00:00Z', 'isPeriod': true},
        ],
      },
    };
    await expectLater(
      transfer.import(1, jsonEncode(payload)),
      throwsA(isA<FormatException>()),
    );
    expect(await db.select(db.periodDays).get(), isEmpty);
  });

  test('非法 JSON 抛 FormatException 且不写库', () async {
    await expectLater(
      transfer.import(1, '这不是 JSON'),
      throwsA(isA<FormatException>()),
    );
    expect(await db.select(db.periodDays).get(), isEmpty);
  });

  test('schema_version=1 的旧版导出包（无 sex_records）仍可正常导入', () async {
    final payload = {
      'schema_version': 1,
      'exported_at': DateTime(2026, 9, 4).toIso8601String(),
      'data': {
        'period_days': [
          {'date': '2026-09-10T00:00:00Z', 'isPeriod': true, 'flowLevel': 2, 'note': null},
        ],
        'symptom_records': [],
        'body_metrics': [],
        'mood_records': [],
        'predictions': [],
      },
    };
    final report = await transfer.import(1, jsonEncode(payload));
    expect(report.inserted['period_days'], 1);
    expect(await db.select(db.periodDays).get(), hasLength(1));
  });
}