import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/db/app_database.dart';
import '../prediction/cycle_math.dart' as cycle;

/// 导入失败原因（数据层抛出，UI 按此映射为本地化文案）。
enum ImportError { jsonParse, invalidJson, schemaMismatch, missingData, invalidDate }

/// 携带机器可读错误码的 [FormatException]。
/// UI 捕获后按 [error] 翻译，避免数据层硬编码中文文案。
class ImportFormatException extends FormatException {
  ImportFormatException(this.error, {this.detail = ''})
      : super(detail.isEmpty ? error.name : '${error.name}: $detail');

  final ImportError error;
  final String detail;
}

/// 导入/导出报告（供 UI 汇总展示）。
class ImportReport {
  const ImportReport({
    required this.inserted,
    required this.skipped,
    required this.usersIgnored,
  });

  /// 各类型成功新增条数（table -> count）。
  final Map<String, int> inserted;

  /// 各类型因唯一键已存在而跳过条数（默认不覆盖本地数据）。
  final Map<String, int> skipped;

  /// 导入文件中被忽略的用户配置文件行数（本地单用户合并口径）。
  final int usersIgnored;

  int get totalInserted => inserted.values.fold(0, (a, b) => a + b);
  int get totalSkipped => skipped.values.fold(0, (a, b) => a + b);
}

/// 导出结果（写文件后返回路径与内容，供 UI 展示/复制）。
class ExportFile {
  const ExportFile({required this.path, required this.content});
  final String path;
  final String content;
}

/// 数据迁移服务（对应 PRD 19.1 / 26.2、硬约束「JSON 全量导出 + 合并去重导入」）。
///
/// - 导出：JSON（全表）。
/// - 导入：schema 校验 → 单事务内按唯一键合并写入；默认不覆盖本地，
///   仅插入缺失键；任一步失败整笔回滚（SQLite 事务即备份/回滚语义）。
class DataTransferService {
  DataTransferService(this._db);

  final AppDatabase _db;

  // ── 导出 ──────────────────────────────────────────────────────────────

  /// 全量 JSON（结构同导入，schema_version 对齐）。
  Future<Map<String, dynamic>> exportJson(int userId) async {
    // 仅导出有实际跟踪内容的经期日（排除 isPeriod=false 且无流量、无备注的空记录）。
    final periods = (await _userRows(_db.periodDays, userId))
        .where(_hasTracking)
        .toList();
    final symptoms = await _userRows(_db.symptomRecords, userId);
    final metrics = await _userRows(_db.bodyMetrics, userId);
    final moods = await _userRows(_db.moodRecords, userId);
    final sex = await _userRows(_db.sexRecords, userId);
    return {
      'schema_version': _db.schemaVersion,
      'exported_at': DateTime.now().toIso8601String(),
      'data': {
        'period_days': periods,
        'symptom_records': symptoms,
        'body_metrics': metrics,
        'mood_records': moods,
        'sex_records': sex,
      },
    };
  }

  /// 是否有实际跟踪内容（预测快照不入导出，故这里只针对经期日）。
  static bool _hasTracking(Map<String, dynamic> row) =>
      row['isPeriod'] == true || row['flowLevel'] != null || row['note'] != null;

  /// 写入文件：JSON 全量导出。
  Future<ExportFile> exportJsonToFile(int userId) async {
    final json = const JsonEncoder.withIndent('  ')
        .convert(await exportJson(userId));
    return _writeExport(_stamp('json'), json);
  }

  static String _stamp(String ext) =>
      'period_export_${DateTime.now().toIso8601String().split('.').first.replaceAll(':', '-')}.$ext';

  Future<ExportFile> _writeExport(String fileName, String content) async {
    final dir = await getApplicationDocumentsDirectory();
    final target = p.join(dir.path, fileName);
    final file = File(target);
    await file.writeAsString(content, flush: true);
    return ExportFile(path: target, content: content);
  }

  // ── 导入（合并去重，默认不覆盖）───────────────────────────────────────

  /// 校验并导入 [json] 到 [userId] 名下。
  /// - schema_version 与当前库版本不一致 → 抛 [FormatException]，不写任何数据。
  /// - 唯一键冲突 → 跳过（不覆盖本地）；缺失键 → 插入。
  /// - 整个流程在单事务内执行，任一步失败即整体回滚。
  Future<ImportReport> import(int userId, String json) async {
    final Map<String, dynamic> payload;
    try {
      payload = jsonDecode(json) as Map<String, dynamic>;
    } on FormatException {
      throw ImportFormatException(ImportError.jsonParse);
    } catch (_) {
      throw ImportFormatException(ImportError.invalidJson);
    }
    final version = payload['schema_version'];
    // 兼容旧版导出（v1 无 sex_records 字段，按空列表处理）。
    if (version != 1 && version != _db.schemaVersion) {
      throw ImportFormatException(
        ImportError.schemaMismatch,
        detail: '$version/${_db.schemaVersion}',
      );
    }
    final data = payload['data'];
    if (data is! Map<String, dynamic>) {
      throw ImportFormatException(ImportError.missingData);
    }

    final inserted = <String, int>{};
    final skipped = <String, int>{};
    var usersIgnored = 0;
    if (data['users'] is List) usersIgnored = (data['users'] as List).length;

    await _db.transaction(() async {
      await _mergePeriodDays(userId, data['period_days'], inserted, skipped);
      await _mergeSymptoms(userId, data['symptom_records'], inserted, skipped);
      await _mergeMetrics(userId, data['body_metrics'], inserted, skipped);
      await _mergeMoods(userId, data['mood_records'], inserted, skipped);
      await _mergeSex(userId, data['sex_records'], inserted, skipped);
      await _mergePredictions(userId, data['predictions'], inserted, skipped);
    });

    return ImportReport(
      inserted: inserted,
      skipped: skipped,
      usersIgnored: usersIgnored,
    );
  }

  // ── 合并实现（各表按唯一键判断是否存在）───────────────────────────────

  Future<void> _mergePeriodDays(
    int userId,
    dynamic rows,
    Map<String, int> inserted,
    Map<String, int> skipped,
  ) async {
    if (rows is! List) return;
    for (final raw in rows) {
      if (raw is! Map) continue;
      final date = _parseDate(raw['date']);
      final existing = await (_db.select(_db.periodDays)
            ..where((d) =>
                d.userId.equals(userId) &
                d.date.equals(cycle.dateOnly(date))))
          .getSingleOrNull();
      if (existing != null) {
        _bump(skipped, 'period_days');
        continue;
      }
      await _db.into(_db.periodDays).insert(
            PeriodDaysCompanion(
              userId: Value(userId),
              date: Value(cycle.dateOnly(date)),
              isPeriod: Value(raw['isPeriod'] == true),
              flowLevel: Value.absentIfNull(
                  (raw['flowLevel'] as num?)?.toInt()),
              note: Value.absentIfNull(raw['note'] as String?),
            ),
          );
      _bump(inserted, 'period_days');
    }
  }

  Future<void> _mergeSymptoms(
    int userId,
    dynamic rows,
    Map<String, int> inserted,
    Map<String, int> skipped,
  ) async {
    if (rows is! List) return;
    for (final raw in rows) {
      if (raw is! Map) continue;
      final date = _parseDate(raw['date']);
      final type = raw['symptomType'] as String? ?? '';
      if (type.isEmpty) continue;
      final existing = await (_db.select(_db.symptomRecords)
            ..where((s) =>
                s.userId.equals(userId) &
                s.date.equals(cycle.dateOnly(date)) &
                s.symptomType.equals(type)))
          .getSingleOrNull();
      if (existing != null) {
        _bump(skipped, 'symptom_records');
        continue;
      }
      await _db.into(_db.symptomRecords).insert(
            SymptomRecordsCompanion(
              userId: Value(userId),
              date: Value(cycle.dateOnly(date)),
              symptomType: Value(type),
              severity: Value.absentIfNull((raw['severity'] as num?)?.toInt()),
            ),
          );
      _bump(inserted, 'symptom_records');
    }
  }

  Future<void> _mergeMetrics(
    int userId,
    dynamic rows,
    Map<String, int> inserted,
    Map<String, int> skipped,
  ) async {
    if (rows is! List) return;
    for (final raw in rows) {
      if (raw is! Map) continue;
      final date = _parseDate(raw['date']);
      final type = raw['metricType'] as String? ?? '';
      if (type.isEmpty) continue;
      final existing = await (_db.select(_db.bodyMetrics)
            ..where((b) =>
                b.userId.equals(userId) &
                b.date.equals(cycle.dateOnly(date)) &
                b.metricType.equals(type)))
          .getSingleOrNull();
      if (existing != null) {
        _bump(skipped, 'body_metrics');
        continue;
      }
      await _db.into(_db.bodyMetrics).insert(
            BodyMetricsCompanion(
              userId: Value(userId),
              date: Value(cycle.dateOnly(date)),
              metricType: Value(type),
              value: Value((raw['value'] as num?)?.toDouble() ?? 0),
            ),
          );
      _bump(inserted, 'body_metrics');
    }
  }

  Future<void> _mergeMoods(
    int userId,
    dynamic rows,
    Map<String, int> inserted,
    Map<String, int> skipped,
  ) async {
    if (rows is! List) return;
    for (final raw in rows) {
      if (raw is! Map) continue;
      final date = _parseDate(raw['date']);
      final type = raw['moodType'] as String? ?? '';
      if (type.isEmpty) continue;
      final existing = await (_db.select(_db.moodRecords)
            ..where((m) =>
                m.userId.equals(userId) &
                m.date.equals(cycle.dateOnly(date)) &
                m.moodType.equals(type)))
          .getSingleOrNull();
      if (existing != null) {
        _bump(skipped, 'mood_records');
        continue;
      }
      await _db.into(_db.moodRecords).insert(
            MoodRecordsCompanion(
              userId: Value(userId),
              date: Value(cycle.dateOnly(date)),
              moodType: Value(type),
              intensity:
                  Value.absentIfNull((raw['intensity'] as num?)?.toInt()),
            ),
          );
      _bump(inserted, 'mood_records');
    }
  }

  Future<void> _mergeSex(
    int userId,
    dynamic rows,
    Map<String, int> inserted,
    Map<String, int> skipped,
  ) async {
    if (rows is! List) return;
    for (final raw in rows) {
      if (raw is! Map) continue;
      final date = _parseDate(raw['date']);
      final tag = raw['tag'] as String? ?? '';
      if (tag.isEmpty) continue;
      final existing = await (_db.select(_db.sexRecords)
            ..where((s) =>
                s.userId.equals(userId) &
                s.date.equals(cycle.dateOnly(date)) &
                s.tag.equals(tag)))
          .getSingleOrNull();
      if (existing != null) {
        _bump(skipped, 'sex_records');
        continue;
      }
      await _db.into(_db.sexRecords).insert(
            SexRecordsCompanion(
              userId: Value(userId),
              date: Value(cycle.dateOnly(date)),
              tag: Value(tag),
              note: Value.absentIfNull(raw['note'] as String?),
            ),
          );
      _bump(inserted, 'sex_records');
    }
  }

  Future<void> _mergePredictions(
    int userId,
    dynamic rows,
    Map<String, int> inserted,
    Map<String, int> skipped,
  ) async {
    if (rows is! List) return;
    for (final raw in rows) {
      if (raw is! Map) continue;
      final date = _parseDate(raw['date'] ?? raw['predictedDate']);
      final event = raw['predictedEvent'] as String? ?? '';
      if (event.isEmpty) continue;
      final existing = await (_db.select(_db.predictionSnapshots)
            ..where((p) =>
                p.userId.equals(userId) &
                p.predictedDate.equals(cycle.dateOnly(date)) &
                p.predictedEvent.equals(event)))
          .getSingleOrNull();
      if (existing != null) {
        _bump(skipped, 'predictions');
        continue;
      }
      await _db.into(_db.predictionSnapshots).insert(
            PredictionSnapshotsCompanion(
              userId: Value(userId),
              predictedEvent: Value(event),
              predictedDate: Value(cycle.dateOnly(date)),
              confidenceRange:
                  Value.absentIfNull(raw['confidenceRange'] as String?),
              modelVersion: Value(raw['modelVersion'] as String? ?? '0'),
            ),
          );
      _bump(inserted, 'predictions');
    }
  }

  // ── 私有工具 ──────────────────────────────────────────────────────────

  // drift 各表不支持统一泛型签名，这里用 dynamic 桥接具体查询。
  Future<List<Map<String, dynamic>>> _userRows(Object table, int userId) async {
    final Future<List<Object?>> list;
    if (table == _db.periodDays) {
      final rows = await (_db.select(_db.periodDays)
            ..where((d) => d.userId.equals(userId)))
          .get();
      list = Future.value(rows);
    } else if (table == _db.symptomRecords) {
      list = Future.value(await (_db.select(_db.symptomRecords)
            ..where((s) => s.userId.equals(userId)))
          .get());
    } else if (table == _db.bodyMetrics) {
      list = Future.value(await (_db.select(_db.bodyMetrics)
            ..where((b) => b.userId.equals(userId)))
          .get());
    } else if (table == _db.moodRecords) {
      list = Future.value(await (_db.select(_db.moodRecords)
            ..where((m) => m.userId.equals(userId)))
          .get());
    } else if (table == _db.sexRecords) {
      list = Future.value(await (_db.select(_db.sexRecords)
            ..where((s) => s.userId.equals(userId)))
          .get());
    } else {
      return [];
    }
    return (await list)
        .whereType<Object>()
        .map((r) {
          // drift toJson 把 DateTime 序列化为 UTC 毫秒数；这里转成易读的
          // ISO 字符串（日期列典型值 ~1.7e12，远大于普通小整型字段）。
          final row = (r as dynamic).toJson() as Map<String, dynamic>;
          return <String, dynamic>{
            for (final e in row.entries) e.key: _humanize(e.value),
          };
        })
        .toList();
  }

  static dynamic _humanize(dynamic v) {
    if (v is int && v.abs() >= 100000000000) {
      return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true)
          .toLocal()
          .toIso8601String();
    }
    return v;
  }

  static void _bump(Map<String, int> map, String key) =>
      map[key] = (map[key] ?? 0) + 1;

  static DateTime _parseDate(dynamic v) {
    if (v is DateTime) return cycle.dateOnly(v);
    if (v is num) {
      // drift toJson 将 DateTime 序列化为 UTC 毫秒时间戳。
      return cycle.dateOnly(
        DateTime.fromMillisecondsSinceEpoch(v.toInt(), isUtc: true).toLocal(),
      );
    }
    final parsed = DateTime.tryParse('$v');
    if (parsed == null) {
      throw ImportFormatException(ImportError.invalidDate);
    }
    return cycle.dateOnly(parsed.toLocal());
  }
}