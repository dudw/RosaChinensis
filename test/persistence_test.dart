// 持久化验证测试：用真实文件数据库（非内存）验证导入后关闭再打开数据仍在。
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:period_tracker/core/db/app_database.dart';
import 'package:period_tracker/data/data_transfer_service.dart';
import 'package:period_tracker/data/repositories/record_repository.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('pt_persist_test');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('导入数据写入文件数据库后，关闭重开数据仍存在', () async {
    final dbFile = File('${tempDir.path}/test_db.sqlite');

    // 第一次打开：创建用户 + 导入数据。
    var db = AppDatabase.forTesting(NativeDatabase(File(dbFile.path)));
    final repo = RecordRepository(db);
    final transfer = DataTransferService(db);

    final userId = await repo.currentUserId();
    expect(userId, 1);

    final payload = {
      'schema_version': db.schemaVersion,
      'exported_at': DateTime.now().toIso8601String(),
      'data': {
        'period_days': [
          {'date': '2019-06-07T00:00:00Z', 'isPeriod': true, 'flowLevel': 2},
          {'date': '2019-06-08T00:00:00Z', 'isPeriod': true, 'flowLevel': 2},
        ],
        'sex_records': [
          {'date': '2019-06-13T00:00:00Z', 'tag': 'protected'},
        ],
        'symptom_records': <Map<String, dynamic>>[],
        'body_metrics': <Map<String, dynamic>>[],
        'mood_records': <Map<String, dynamic>>[],
        'predictions': <Map<String, dynamic>>[],
      },
    };
    final report = await transfer.import(userId, jsonEncode(payload));
    expect(report.totalInserted, 3);

    // 关闭数据库。
    await db.close();

    // 第二次打开：验证数据持久化。
    db = AppDatabase.forTesting(NativeDatabase(File(dbFile.path)));
    final repo2 = RecordRepository(db);
    final userId2 = await repo2.currentUserId();
    expect(userId2, userId); // 用户 ID 稳定。

    final days = await (db.select(db.periodDays)
          ..where((d) => d.userId.equals(userId2)))
        .get();
    expect(days, hasLength(2));

    final sex = await (db.select(db.sexRecords)
          ..where((s) => s.userId.equals(userId2)))
        .get();
    expect(sex, hasLength(1));

    await db.close();
  });
}
