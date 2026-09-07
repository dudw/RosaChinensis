import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Users 表（配置基准，对应 PRD 19.2 / 26.1 Onboarding 收敛项）。
@DataClassName('UserRow')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 用户的可选识别串（本地无账号时为匿名 UUID）。
  TextColumn get localId => text().withDefault(const Constant(''))();

  IntColumn get expectCycleLength => integer().withDefault(const Constant(28))();
  IntColumn get expectPeriodLength => integer().withDefault(const Constant(5))();

  /// 最近一次经期首日；为 null 表示尚未录入。
  DateTimeColumn get lastPeriodStart => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// PeriodDays 表（经期日记录，对应 PRD 19.2；去重唯一键 = (userId, date)）。
@DataClassName('PeriodDay')
class PeriodDays extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  DateTimeColumn get date => dateTime()();

  /// 该日是否为经期（经期首日判定由此派生）。
  BoolColumn get isPeriod => boolean().withDefault(const Constant(false))();

  /// 流量强度 0-3（0=点滴 1=轻 2=中 3=多）；null 表示未记录。
  IntColumn get flowLevel => integer().nullable()();

  TextColumn get note => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, date},
      ];
}

/// SymptomRecords 表（症状，对应 PRD 10.3 合并去重唯一键 = (symptom, date, symptomType)）。
@DataClassName('SymptomRecord')
class SymptomRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  DateTimeColumn get date => dateTime()();

  /// 症状类别文本，如 "头痛" / "腹痛" / "疲劳"。
  TextColumn get symptomType => text()();

  /// 强度 0-3；null 表示未评级。
  IntColumn get severity => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, date, symptomType},
      ];
}

/// BodyMetrics 表（身体指标，对应 PRD 10.3 唯一键 = (metric, date, metricType)）。
@DataClassName('BodyMetric')
class BodyMetrics extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  DateTimeColumn get date => dateTime()();

  /// 指标类型文本，如 "体重" / "体温"。
  TextColumn get metricType => text()();

  RealColumn get value => real()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, date, metricType},
      ];
}

/// MoodRecords 表（情绪，对应 PRD 10.3 唯一键 = (mood, date, moodType)）。
@DataClassName('MoodRecord')
class MoodRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  DateTimeColumn get date => dateTime()();

  /// 情绪类型文本，如 "开心" / "低落" / "平静"。
  TextColumn get moodType => text()();

  /// 强度 0-3；null 表示未评级。
  IntColumn get intensity => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, date, moodType},
      ];
}

/// SexRecords 表（性生活记录，对应 PRD 10.4）。
/// 采用标签模型：每个 (userId, date, tag) 一行。
/// 去重唯一键 = (userId, date, tag)。
@DataClassName('SexRecord')
class SexRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  DateTimeColumn get date => dateTime()();

  /// 标签文本，如 "protected" / "unprotected" / "withdrawal" / "orgasm" 等。
  TextColumn get tag => text()();

  /// 可选备注（预留扩展）。
  TextColumn get note => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, date, tag},
      ];
}

/// PredictionSnapshots 表（预测快照，仅缓存展示，推断不依赖于此，对应 PRD 21.3）。
/// 去重唯一键 = (userId, predictedEvent, predictedDate)。
@DataClassName('PredictionSnapshot')
class PredictionSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();

  /// 事件类型枚举文本：nextPeriod / ovulation / windowStart / windowEnd。
  TextColumn get predictedEvent => text()();

  DateTimeColumn get predictedDate => dateTime()();

  /// 置信区间文本，如 "+-2d"；null 表示未评估。
  TextColumn get confidenceRange => text().nullable()();

  TextColumn get modelVersion => text().withDefault(const Constant('0'))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, predictedEvent, predictedDate},
      ];
}

/// 应用数据库（对应 PRD 19.1 迁移策略 / 23.3 drift+加密集成）。
///
/// schemaVersion = 1。
/// 注意：体验版默认使用 drift_flutter 的标准本地数据库路径
/// （未启用 sqlcipher）。后续接入 sqlcipher 加密（PRD 14.4/19.4）时，
/// 只需替换 [connector] 的底层实现，并在打开前用 [SecureStore]
/// 提供的 Keychain 密钥完成 `asKey` 配置，表结构与调用方无需改动。
@DriftDatabase(tables: [
  Users,
  PeriodDays,
  SymptomRecords,
  BodyMetrics,
  MoodRecords,
  SexRecords,
  PredictionSnapshots,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // v1 -> v2：新增 SexRecords 表。
          if (from < 2) {
            await m.createTable(sexRecords);
          }
          // schemaVersion 后续变更时在此补充迁移逻辑；
          // 迁移前需自动备份、失败回滚（PRD 19.1），上线前落实。
        },
        beforeOpen: (details) async {
          // PRD 19.4：正式版在打开加密库前在此用 Keychain 密钥初始化。
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _open() => driftDatabase(name: 'period_tracker_db');
}