import 'package:drift/drift.dart';

import '../../core/db/app_database.dart';
import '../../prediction/cycle_math.dart' as cycle;

/// 一个分类的计数（症状 / 情绪 频次行）。
class TypeCount {
  const TypeCount(this.type, this.count);
  final String type;
  final int count;
}

/// 一个身体指标的时间序列点（体重 / 体温）。
class MetricPoint {
  const MetricPoint(this.date, this.value);
  final DateTime date;
  final double value;
}

/// 全历史记录概览计数。
class RecordSummary {
  const RecordSummary({
    required this.trackedDays,
    required this.periodDays,
    required this.symptomDays,
    required this.moodDays,
    required this.sexDays,
    required this.metricDays,
  });
  final int trackedDays;
  final int periodDays;
  final int symptomDays;
  final int moodDays;
  final int sexDays;
  final int metricDays;
}

/// 记录仓库（数据访问层，对应 PRD B Stage / 23.1 数据层）。
///
/// 统一入口：按“合并去重唯一键” upsert 各类型记录、范围查询、
/// 经期首日与周期序列派生、按用户级联清除。纯数据层，无 UI 副作用。
class RecordRepository {
  RecordRepository(this._db);

  final AppDatabase _db;

  /// ── Users ──────────────────────────────────────────────────────────────

  /// 以用户行 ID 为准做 upsert；存在则以 [localId] 更新为标识。
  Future<int> ensureUser({
    required int id,
    String localId = '',
    int expectCycleLength = cycle.defaultCycleLength,
    int expectPeriodLength = 5,
    DateTime? lastPeriodStart,
  }) async {
    final companion = UsersCompanion(
      expectCycleLength: Value(expectCycleLength),
      expectPeriodLength: Value(expectPeriodLength),
      lastPeriodStart: Value(lastPeriodStart),
    );
    await (_db.update(_db.users)..where((u) => u.id.equals(id))).write(
      companion,
    );
    return id;
  }

  /// 新建一个用户行，返回自增 id（本地单用户场景）。
  Future<int> createUser({String localId = ''}) {
    return _db.into(_db.users).insert(
          UsersCompanion(localId: Value(localId)),
        );
  }

  /// 取第一条用户 id；无则新建。
  Future<int> currentUserId() async {
    final row = await (_db.select(_db.users)..limit(1)).getSingleOrNull();
    return row?.id ?? createUser();
  }

  /// ── PeriodDays（唯一键：userId + date）─────────────────────────────────

  Future<void> upsertPeriodDay({
    required int userId,
    required DateTime date,
    bool isPeriod = true,
    int? flowLevel,
    String? note,
  }) {
    final companion = PeriodDaysCompanion(
      userId: Value(userId),
      date: Value(cycle.dateOnly(date)),
      isPeriod: Value(isPeriod),
      flowLevel: Value.absentIfNull(flowLevel),
      note: Value.absentIfNull(note),
    );
    return _db.into(_db.periodDays).insert(
          companion,
          onConflict: DoUpdate(
            (_) => PeriodDaysCompanion(
              isPeriod: Value(isPeriod),
              flowLevel: Value.absentIfNull(flowLevel),
              note: Value.absentIfNull(note),
            ),
            target: [_db.periodDays.userId, _db.periodDays.date],
          ),
        );
  }

  Future<List<PeriodDay>> periodDaysByRange(
    int userId, {
    required DateTime from,
    required DateTime to,
  }) {
    return (_db.select(_db.periodDays)
          ..where((d) =>
              d.userId.equals(userId) &
              d.date.isBetweenValues(cycle.dateOnly(from), cycle.dateOnly(to)))
          ..orderBy([(d) => OrderingTerm.asc(d.date)]))
        .get();
  }

  /// 派生经期首日序列：仅当与前一个经期日不相邻（非连续）时才记为一段的首日。
  Future<List<DateTime>> periodStarts(int userId) async {
    final rows = await _allPeriodDays(userId);
    final starts = <DateTime>[];
    DateTime? previous;
    for (final r in rows) {
      if (!r.isPeriod) continue;
      final d = cycle.dateOnly(r.date);
      if (previous == null || d.difference(previous).inDays != 1) {
        starts.add(d);
      }
      previous = d;
    }
    return starts;
  }

  /// 最近一次经期首日（最新一段的开头）；无则 null。
  Future<DateTime?> latestPeriodStart(int userId) async {
    final starts = await periodStarts(userId);
    return starts.isEmpty ? null : starts.last;
  }

  /// 周期长度序列（供预测与统计，见 21.2）。
  Future<List<int>> cycleLengths(int userId) async =>
      cycle.cycleLengths(await periodStarts(userId));

  /// ── 症状 / 身体指标 / 情绪（各自唯一键 upsert）────────────────────────

  Future<void> upsertSymptom({
    required int userId,
    required DateTime date,
    required String symptomType,
    int? severity,
  }) {
    final companion = SymptomRecordsCompanion(
      userId: Value(userId),
      date: Value(cycle.dateOnly(date)),
      symptomType: Value(symptomType),
      severity: Value.absentIfNull(severity),
    );
    return _db.into(_db.symptomRecords).insert(
          companion,
          // 症状同键下无可变字段（severity 可能为空），冲突直接忽略。
          onConflict: DoNothing(
            target: [
              _db.symptomRecords.userId,
              _db.symptomRecords.date,
              _db.symptomRecords.symptomType,
            ],
          ),
        );
  }

  Future<void> upsertBodyMetric({
    required int userId,
    required DateTime date,
    required String metricType,
    required double value,
  }) {
    final companion = BodyMetricsCompanion(
      userId: Value(userId),
      date: Value(cycle.dateOnly(date)),
      metricType: Value(metricType),
      value: Value(value),
    );
    return _db.into(_db.bodyMetrics).insert(
          companion,
          onConflict: DoUpdate(
            (_) => BodyMetricsCompanion(value: Value(value)),
            target: [
              _db.bodyMetrics.userId,
              _db.bodyMetrics.date,
              _db.bodyMetrics.metricType,
            ],
          ),
        );
  }

  Future<void> upsertMood({
    required int userId,
    required DateTime date,
    required String moodType,
    int? intensity,
  }) {
    final companion = MoodRecordsCompanion(
      userId: Value(userId),
      date: Value(cycle.dateOnly(date)),
      moodType: Value(moodType),
      intensity: Value.absentIfNull(intensity),
    );
    return _db.into(_db.moodRecords).insert(
          companion,
          // 情绪同键下无可变字段（intensity 可能为空），冲突直接忽略。
          onConflict: DoNothing(
            target: [
              _db.moodRecords.userId,
              _db.moodRecords.date,
              _db.moodRecords.moodType,
            ],
          ),
        );
  }

  /// 删除某天经期日（取消选择血量且无备注时调用）。
  Future<void> deletePeriodDay({
    required int userId,
    required DateTime date,
  }) {
    return (_db.delete(_db.periodDays)
          ..where((d) =>
              d.userId.equals(userId) &
              d.date.equals(cycle.dateOnly(date))))
        .go();
  }

  Future<void> deleteSymptom({
    required int userId,
    required DateTime date,
    required String symptomType,
  }) {
    return (_db.delete(_db.symptomRecords)
          ..where((s) =>
              s.userId.equals(userId) &
              s.date.equals(cycle.dateOnly(date)) &
              s.symptomType.equals(symptomType)))
        .go();
  }

  Future<void> deleteMood({
    required int userId,
    required DateTime date,
    required String moodType,
  }) {
    return (_db.delete(_db.moodRecords)
          ..where((m) =>
              m.userId.equals(userId) &
              m.date.equals(cycle.dateOnly(date)) &
              m.moodType.equals(moodType)))
        .go();
  }

  Future<void> deleteBodyMetric({
    required int userId,
    required DateTime date,
    required String metricType,
  }) {
    return (_db.delete(_db.bodyMetrics)
          ..where((b) =>
              b.userId.equals(userId) &
              b.date.equals(cycle.dateOnly(date)) &
              b.metricType.equals(metricType)))
        .go();
  }

  /// 某天症状列表（自动回显用）。
  Future<List<SymptomRecord>> symptomsByRange(
    int userId, {
    required DateTime from,
    required DateTime to,
  }) {
    return (_db.select(_db.symptomRecords)
          ..where((s) =>
              s.userId.equals(userId) &
              s.date.isBetweenValues(cycle.dateOnly(from), cycle.dateOnly(to))))
        .get();
  }

  /// 某天情绪列表（自动回显用）。
  Future<List<MoodRecord>> moodsByRange(
    int userId, {
    required DateTime from,
    required DateTime to,
  }) {
    return (_db.select(_db.moodRecords)
          ..where((m) =>
              m.userId.equals(userId) &
              m.date.isBetweenValues(cycle.dateOnly(from), cycle.dateOnly(to))))
        .get();
  }

  /// 某天身体指标列表（自动回显用）。
  Future<List<BodyMetric>> metricsByRange(
    int userId, {
    required DateTime from,
    required DateTime to,
  }) {
    return (_db.select(_db.bodyMetrics)
          ..where((b) =>
              b.userId.equals(userId) &
              b.date.isBetweenValues(cycle.dateOnly(from), cycle.dateOnly(to))))
        .get();
  }

  /// ── 性生活记录（标签模型，唯一键：userId + date + tag）────────────────────

  Future<void> upsertSex({
    required int userId,
    required DateTime date,
    required String tag,
    String? note,
  }) {
    final companion = SexRecordsCompanion(
      userId: Value(userId),
      date: Value(cycle.dateOnly(date)),
      tag: Value(tag),
      note: Value.absentIfNull(note),
    );
    return _db.into(_db.sexRecords).insert(
          companion,
          onConflict: DoNothing(
            target: [
              _db.sexRecords.userId,
              _db.sexRecords.date,
              _db.sexRecords.tag,
            ],
          ),
        );
  }

  /// 删除某天某个标签（用于切换「今天没性行为」等互斥场景）。
  Future<void> deleteSexTag({
    required int userId,
    required DateTime date,
    required String tag,
  }) {
    return (_db.delete(_db.sexRecords)
          ..where((s) =>
              s.userId.equals(userId) &
              s.date.equals(cycle.dateOnly(date)) &
              s.tag.equals(tag)))
        .go();
  }

  /// 清空某天全部性生活标签（重保存时先清后写，避免残留）。
  Future<void> clearSexByDate({
    required int userId,
    required DateTime date,
  }) {
    return (_db.delete(_db.sexRecords)
          ..where((s) =>
              s.userId.equals(userId) &
              s.date.equals(cycle.dateOnly(date))))
        .go();
  }

  Future<List<SexRecord>> sexByRange(
    int userId, {
    required DateTime from,
    required DateTime to,
  }) {
    return (_db.select(_db.sexRecords)
          ..where((s) =>
              s.userId.equals(userId) &
              s.date.isBetweenValues(cycle.dateOnly(from), cycle.dateOnly(to)))
          ..orderBy([(s) => OrderingTerm.asc(s.date)]))
        .get();
  }

  /// ── 级联清除（PRD 19.3：删除用户数据）──────────────────────────────────

  Future<void> clearUserData(int userId) {
    return _db.transaction(() async {
      await (_db.delete(_db.periodDays)..where((d) => d.userId.equals(userId)))
          .go();
      await (_db.delete(_db.symptomRecords)
            ..where((s) => s.userId.equals(userId)))
          .go();
      await (_db.delete(_db.bodyMetrics)..where((b) => b.userId.equals(userId)))
          .go();
      await (_db.delete(_db.moodRecords)..where((m) => m.userId.equals(userId)))
          .go();
      await (_db.delete(_db.sexRecords)..where((s) => s.userId.equals(userId)))
          .go();
      await (_db.delete(_db.predictionSnapshots)
            ..where((p) => p.userId.equals(userId)))
          .go();
      await (_db.delete(_db.users)..where((u) => u.id.equals(userId))).go();
    });
  }

  /// ── 预测快照（21.3 写库 / 22.1 读取）───────────────────────────────────

  Future<void> clearPredictions(int userId) async {
    await (_db.delete(_db.predictionSnapshots)
          ..where((p) => p.userId.equals(userId)))
        .go();
  }

  Future<void> upsertPrediction({
    required int userId,
    required String event,
    required DateTime date,
    String? confidenceRange,
    String modelVersion = '0',
  }) {
    final companion = PredictionSnapshotsCompanion(
      userId: Value(userId),
      predictedEvent: Value(event),
      predictedDate: Value(cycle.dateOnly(date)),
      confidenceRange: Value.absentIfNull(confidenceRange),
      modelVersion: Value(modelVersion),
    );
    return _db.into(_db.predictionSnapshots).insert(
          companion,
          onConflict: DoUpdate(
            (_) => PredictionSnapshotsCompanion(
              confidenceRange: Value.absentIfNull(confidenceRange),
              modelVersion: Value(modelVersion),
            ),
            target: [
              _db.predictionSnapshots.userId,
              _db.predictionSnapshots.predictedEvent,
              _db.predictionSnapshots.predictedDate,
            ],
          ),
        );
  }

  Future<List<PredictionSnapshot>> predictionsByRange(
    int userId, {
    required DateTime from,
    required DateTime to,
  }) {
    return (_db.select(_db.predictionSnapshots)
          ..where((p) =>
              p.userId.equals(userId) &
              p.predictedDate.isBetweenValues(
                  cycle.dateOnly(from), cycle.dateOnly(to)))
          ..orderBy([
            (p) => OrderingTerm.asc(p.predictedDate),
          ]))
        .get();
  }

  /// ── 周期统计（25.1，口径与预测一致）────────────────────────────────────

  /// 每个完整经期的持续天数（连续 isPeriod 日的分段长度）。
  Future<List<int>> periodDurations(int userId) async {
    final rows = await _allPeriodDays(userId);
    final durations = <int>[];
    var count = 0;
    DateTime? lastDate;
    for (final r in rows) {
      if (!r.isPeriod) {
        if (count > 0) durations.add(count);
        count = 0;
        lastDate = null;
        continue;
      }
      final d = cycle.dateOnly(r.date);
      if (lastDate != null && d.difference(lastDate).inDays == 1) {
        count++;
      } else {
        if (count > 0) durations.add(count);
        count = 1;
      }
      lastDate = d;
    }
    if (count > 0) durations.add(count);
    return durations;
  }

  /// 平均周期长度（天）；无完整周期返回 null。
  Future<double?> averageCycleLength(int userId) async {
    final lens = await cycleLengths(userId);
    if (lens.isEmpty) return null;
    return lens.reduce((a, b) => a + b) / lens.length;
  }

  /// 平均经期持续（天）；无记录返回 null。
  Future<double?> averagePeriodLength(int userId) async {
    final durs = await periodDurations(userId);
    if (durs.isEmpty) return null;
    return durs.reduce((a, b) => a + b) / durs.length;
  }

  /// ── 追踪统计（记录概览 / 频次 / 指标序列）──────────────────────────────

  /// 全历史各分类的记录天数概览。
  Future<RecordSummary> recordSummary(int userId) async {
    final periodRows = await _allPeriodDays(userId);
    final symptoms = await _allSymptoms(userId);
    final moods = await _allMoods(userId);
    final sex = await _allSex(userId);
    final metrics = await _allMetrics(userId);

    final periodDates = <DateTime>{};
    for (final r in periodRows) {
      if (r.isPeriod) periodDates.add(cycle.dateOnly(r.date));
    }
    final symptomDates = symptoms.map((s) => cycle.dateOnly(s.date)).toSet();
    final moodDates = moods.map((m) => cycle.dateOnly(m.date)).toSet();
    final sexDates = sex.map((s) => cycle.dateOnly(s.date)).toSet();
    final metricDates = metrics.map((m) => cycle.dateOnly(m.date)).toSet();

    final all = <DateTime>{}
      ..addAll(periodDates)
      ..addAll(symptomDates)
      ..addAll(moodDates)
      ..addAll(sexDates)
      ..addAll(metricDates);

    return RecordSummary(
      trackedDays: all.length,
      periodDays: periodDates.length,
      symptomDays: symptomDates.length,
      moodDays: moodDates.length,
      sexDays: sexDates.length,
      metricDays: metricDates.length,
    );
  }

  /// 各症状的记录天数（按频次降序）。
  Future<List<TypeCount>> symptomFrequency(int userId) async {
    final rows = await _allSymptoms(userId);
    final map = <String, int>{};
    for (final s in rows) {
      map[s.symptomType] = (map[s.symptomType] ?? 0) + 1;
    }
    return _toTypeCounts(map);
  }

  /// 各情绪的记录天数（按频次降序）。
  Future<List<TypeCount>> moodCounts(int userId) async {
    final rows = await _allMoods(userId);
    final map = <String, int>{};
    for (final m in rows) {
      map[m.moodType] = (map[m.moodType] ?? 0) + 1;
    }
    return _toTypeCounts(map);
  }

  /// 某类身体指标（体重 / 体温）的时间序列，按日期升序。
  Future<List<MetricPoint>> metricSeries(int userId, String metricType) async {
    final rows = await (_db.select(_db.bodyMetrics)
          ..where((b) =>
              b.userId.equals(userId) & b.metricType.equals(metricType))
          ..orderBy([(b) => OrderingTerm.asc(b.date)]))
        .get();
    return rows.map((m) => MetricPoint(cycle.dateOnly(m.date), m.value)).toList();
  }

  static List<TypeCount> _toTypeCounts(Map<String, int> map) {
    final list = map.entries
        .map((e) => TypeCount(e.key, e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    return list;
  }

  /// ── 有记录的日期集合（供日期选择弹窗标注）────────────────────────────

  /// 返回 [from, to] 范围内有任意记录（经期/症状/情绪/性生活/指标/备注）的日期集合。
  Future<Set<DateTime>> datesWithRecords(int userId,
      {required DateTime from, required DateTime to}) async {
    final f = cycle.dateOnly(from);
    final t = cycle.dateOnly(to);
    final dates = <DateTime>{};
    final periodDays = await periodDaysByRange(userId, from: f, to: t);
    for (final r in periodDays) {
      dates.add(cycle.dateOnly(r.date));
    }
    final symptoms = await symptomsByRange(userId, from: f, to: t);
    for (final r in symptoms) {
      dates.add(cycle.dateOnly(r.date));
    }
    final moods = await moodsByRange(userId, from: f, to: t);
    for (final r in moods) {
      dates.add(cycle.dateOnly(r.date));
    }
    final sex = await sexByRange(userId, from: f, to: t);
    for (final r in sex) {
      dates.add(cycle.dateOnly(r.date));
    }
    final metrics = await metricsByRange(userId, from: f, to: t);
    for (final r in metrics) {
      dates.add(cycle.dateOnly(r.date));
    }
    return dates;
  }

  /// ── 私有 ────────────────────────────────────────────────────────────

  Future<List<PeriodDay>> _allPeriodDays(int userId) {
    return (_db.select(_db.periodDays)
          ..where((d) => d.userId.equals(userId))
          ..orderBy([(d) => OrderingTerm.asc(d.date)]))
        .get();
  }

  Future<List<SymptomRecord>> _allSymptoms(int userId) {
    return (_db.select(_db.symptomRecords)
          ..where((s) => s.userId.equals(userId)))
        .get();
  }

  Future<List<MoodRecord>> _allMoods(int userId) {
    return (_db.select(_db.moodRecords)..where((m) => m.userId.equals(userId)))
        .get();
  }

  Future<List<SexRecord>> _allSex(int userId) {
    return (_db.select(_db.sexRecords)..where((s) => s.userId.equals(userId)))
        .get();
  }

  Future<List<BodyMetric>> _allMetrics(int userId) {
    return (_db.select(_db.bodyMetrics)..where((b) => b.userId.equals(userId)))
        .get();
  }
}