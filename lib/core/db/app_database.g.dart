// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _expectCycleLengthMeta = const VerificationMeta(
    'expectCycleLength',
  );
  @override
  late final GeneratedColumn<int> expectCycleLength = GeneratedColumn<int>(
    'expect_cycle_length',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(28),
  );
  static const VerificationMeta _expectPeriodLengthMeta =
      const VerificationMeta('expectPeriodLength');
  @override
  late final GeneratedColumn<int> expectPeriodLength = GeneratedColumn<int>(
    'expect_period_length',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _lastPeriodStartMeta = const VerificationMeta(
    'lastPeriodStart',
  );
  @override
  late final GeneratedColumn<DateTime> lastPeriodStart =
      GeneratedColumn<DateTime>(
        'last_period_start',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localId,
    expectCycleLength,
    expectPeriodLength,
    lastPeriodStart,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('expect_cycle_length')) {
      context.handle(
        _expectCycleLengthMeta,
        expectCycleLength.isAcceptableOrUnknown(
          data['expect_cycle_length']!,
          _expectCycleLengthMeta,
        ),
      );
    }
    if (data.containsKey('expect_period_length')) {
      context.handle(
        _expectPeriodLengthMeta,
        expectPeriodLength.isAcceptableOrUnknown(
          data['expect_period_length']!,
          _expectPeriodLengthMeta,
        ),
      );
    }
    if (data.containsKey('last_period_start')) {
      context.handle(
        _lastPeriodStartMeta,
        lastPeriodStart.isAcceptableOrUnknown(
          data['last_period_start']!,
          _lastPeriodStartMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      expectCycleLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expect_cycle_length'],
      )!,
      expectPeriodLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expect_period_length'],
      )!,
      lastPeriodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_period_start'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final int id;

  /// 用户的可选识别串（本地无账号时为匿名 UUID）。
  final String localId;
  final int expectCycleLength;
  final int expectPeriodLength;

  /// 最近一次经期首日；为 null 表示尚未录入。
  final DateTime? lastPeriodStart;
  final DateTime createdAt;
  const UserRow({
    required this.id,
    required this.localId,
    required this.expectCycleLength,
    required this.expectPeriodLength,
    this.lastPeriodStart,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['local_id'] = Variable<String>(localId);
    map['expect_cycle_length'] = Variable<int>(expectCycleLength);
    map['expect_period_length'] = Variable<int>(expectPeriodLength);
    if (!nullToAbsent || lastPeriodStart != null) {
      map['last_period_start'] = Variable<DateTime>(lastPeriodStart);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      localId: Value(localId),
      expectCycleLength: Value(expectCycleLength),
      expectPeriodLength: Value(expectPeriodLength),
      lastPeriodStart: lastPeriodStart == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPeriodStart),
      createdAt: Value(createdAt),
    );
  }

  factory UserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<int>(json['id']),
      localId: serializer.fromJson<String>(json['localId']),
      expectCycleLength: serializer.fromJson<int>(json['expectCycleLength']),
      expectPeriodLength: serializer.fromJson<int>(json['expectPeriodLength']),
      lastPeriodStart: serializer.fromJson<DateTime?>(json['lastPeriodStart']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'localId': serializer.toJson<String>(localId),
      'expectCycleLength': serializer.toJson<int>(expectCycleLength),
      'expectPeriodLength': serializer.toJson<int>(expectPeriodLength),
      'lastPeriodStart': serializer.toJson<DateTime?>(lastPeriodStart),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserRow copyWith({
    int? id,
    String? localId,
    int? expectCycleLength,
    int? expectPeriodLength,
    Value<DateTime?> lastPeriodStart = const Value.absent(),
    DateTime? createdAt,
  }) => UserRow(
    id: id ?? this.id,
    localId: localId ?? this.localId,
    expectCycleLength: expectCycleLength ?? this.expectCycleLength,
    expectPeriodLength: expectPeriodLength ?? this.expectPeriodLength,
    lastPeriodStart: lastPeriodStart.present
        ? lastPeriodStart.value
        : this.lastPeriodStart,
    createdAt: createdAt ?? this.createdAt,
  );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      id: data.id.present ? data.id.value : this.id,
      localId: data.localId.present ? data.localId.value : this.localId,
      expectCycleLength: data.expectCycleLength.present
          ? data.expectCycleLength.value
          : this.expectCycleLength,
      expectPeriodLength: data.expectPeriodLength.present
          ? data.expectPeriodLength.value
          : this.expectPeriodLength,
      lastPeriodStart: data.lastPeriodStart.present
          ? data.lastPeriodStart.value
          : this.lastPeriodStart,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('localId: $localId, ')
          ..write('expectCycleLength: $expectCycleLength, ')
          ..write('expectPeriodLength: $expectPeriodLength, ')
          ..write('lastPeriodStart: $lastPeriodStart, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    localId,
    expectCycleLength,
    expectPeriodLength,
    lastPeriodStart,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.localId == this.localId &&
          other.expectCycleLength == this.expectCycleLength &&
          other.expectPeriodLength == this.expectPeriodLength &&
          other.lastPeriodStart == this.lastPeriodStart &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<int> id;
  final Value<String> localId;
  final Value<int> expectCycleLength;
  final Value<int> expectPeriodLength;
  final Value<DateTime?> lastPeriodStart;
  final Value<DateTime> createdAt;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.localId = const Value.absent(),
    this.expectCycleLength = const Value.absent(),
    this.expectPeriodLength = const Value.absent(),
    this.lastPeriodStart = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    this.localId = const Value.absent(),
    this.expectCycleLength = const Value.absent(),
    this.expectPeriodLength = const Value.absent(),
    this.lastPeriodStart = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<UserRow> custom({
    Expression<int>? id,
    Expression<String>? localId,
    Expression<int>? expectCycleLength,
    Expression<int>? expectPeriodLength,
    Expression<DateTime>? lastPeriodStart,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localId != null) 'local_id': localId,
      if (expectCycleLength != null) 'expect_cycle_length': expectCycleLength,
      if (expectPeriodLength != null)
        'expect_period_length': expectPeriodLength,
      if (lastPeriodStart != null) 'last_period_start': lastPeriodStart,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? localId,
    Value<int>? expectCycleLength,
    Value<int>? expectPeriodLength,
    Value<DateTime?>? lastPeriodStart,
    Value<DateTime>? createdAt,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      expectCycleLength: expectCycleLength ?? this.expectCycleLength,
      expectPeriodLength: expectPeriodLength ?? this.expectPeriodLength,
      lastPeriodStart: lastPeriodStart ?? this.lastPeriodStart,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (expectCycleLength.present) {
      map['expect_cycle_length'] = Variable<int>(expectCycleLength.value);
    }
    if (expectPeriodLength.present) {
      map['expect_period_length'] = Variable<int>(expectPeriodLength.value);
    }
    if (lastPeriodStart.present) {
      map['last_period_start'] = Variable<DateTime>(lastPeriodStart.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('localId: $localId, ')
          ..write('expectCycleLength: $expectCycleLength, ')
          ..write('expectPeriodLength: $expectPeriodLength, ')
          ..write('lastPeriodStart: $lastPeriodStart, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PeriodDaysTable extends PeriodDays
    with TableInfo<$PeriodDaysTable, PeriodDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeriodDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPeriodMeta = const VerificationMeta(
    'isPeriod',
  );
  @override
  late final GeneratedColumn<bool> isPeriod = GeneratedColumn<bool>(
    'is_period',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_period" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _flowLevelMeta = const VerificationMeta(
    'flowLevel',
  );
  @override
  late final GeneratedColumn<int> flowLevel = GeneratedColumn<int>(
    'flow_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    date,
    isPeriod,
    flowLevel,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'period_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeriodDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('is_period')) {
      context.handle(
        _isPeriodMeta,
        isPeriod.isAcceptableOrUnknown(data['is_period']!, _isPeriodMeta),
      );
    }
    if (data.containsKey('flow_level')) {
      context.handle(
        _flowLevelMeta,
        flowLevel.isAcceptableOrUnknown(data['flow_level']!, _flowLevelMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId, date},
  ];
  @override
  PeriodDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeriodDay(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      isPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_period'],
      )!,
      flowLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flow_level'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $PeriodDaysTable createAlias(String alias) {
    return $PeriodDaysTable(attachedDatabase, alias);
  }
}

class PeriodDay extends DataClass implements Insertable<PeriodDay> {
  final int id;
  final int userId;
  final DateTime date;

  /// 该日是否为经期（经期首日判定由此派生）。
  final bool isPeriod;

  /// 流量强度 0-3（0=点滴 1=轻 2=中 3=多）；null 表示未记录。
  final int? flowLevel;
  final String? note;
  const PeriodDay({
    required this.id,
    required this.userId,
    required this.date,
    required this.isPeriod,
    this.flowLevel,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['date'] = Variable<DateTime>(date);
    map['is_period'] = Variable<bool>(isPeriod);
    if (!nullToAbsent || flowLevel != null) {
      map['flow_level'] = Variable<int>(flowLevel);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  PeriodDaysCompanion toCompanion(bool nullToAbsent) {
    return PeriodDaysCompanion(
      id: Value(id),
      userId: Value(userId),
      date: Value(date),
      isPeriod: Value(isPeriod),
      flowLevel: flowLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(flowLevel),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory PeriodDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeriodDay(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      isPeriod: serializer.fromJson<bool>(json['isPeriod']),
      flowLevel: serializer.fromJson<int?>(json['flowLevel']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'date': serializer.toJson<DateTime>(date),
      'isPeriod': serializer.toJson<bool>(isPeriod),
      'flowLevel': serializer.toJson<int?>(flowLevel),
      'note': serializer.toJson<String?>(note),
    };
  }

  PeriodDay copyWith({
    int? id,
    int? userId,
    DateTime? date,
    bool? isPeriod,
    Value<int?> flowLevel = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => PeriodDay(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    isPeriod: isPeriod ?? this.isPeriod,
    flowLevel: flowLevel.present ? flowLevel.value : this.flowLevel,
    note: note.present ? note.value : this.note,
  );
  PeriodDay copyWithCompanion(PeriodDaysCompanion data) {
    return PeriodDay(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      isPeriod: data.isPeriod.present ? data.isPeriod.value : this.isPeriod,
      flowLevel: data.flowLevel.present ? data.flowLevel.value : this.flowLevel,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeriodDay(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('isPeriod: $isPeriod, ')
          ..write('flowLevel: $flowLevel, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, date, isPeriod, flowLevel, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeriodDay &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.isPeriod == this.isPeriod &&
          other.flowLevel == this.flowLevel &&
          other.note == this.note);
}

class PeriodDaysCompanion extends UpdateCompanion<PeriodDay> {
  final Value<int> id;
  final Value<int> userId;
  final Value<DateTime> date;
  final Value<bool> isPeriod;
  final Value<int?> flowLevel;
  final Value<String?> note;
  const PeriodDaysCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.isPeriod = const Value.absent(),
    this.flowLevel = const Value.absent(),
    this.note = const Value.absent(),
  });
  PeriodDaysCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required DateTime date,
    this.isPeriod = const Value.absent(),
    this.flowLevel = const Value.absent(),
    this.note = const Value.absent(),
  }) : userId = Value(userId),
       date = Value(date);
  static Insertable<PeriodDay> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<DateTime>? date,
    Expression<bool>? isPeriod,
    Expression<int>? flowLevel,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (isPeriod != null) 'is_period': isPeriod,
      if (flowLevel != null) 'flow_level': flowLevel,
      if (note != null) 'note': note,
    });
  }

  PeriodDaysCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<DateTime>? date,
    Value<bool>? isPeriod,
    Value<int?>? flowLevel,
    Value<String?>? note,
  }) {
    return PeriodDaysCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      isPeriod: isPeriod ?? this.isPeriod,
      flowLevel: flowLevel ?? this.flowLevel,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (isPeriod.present) {
      map['is_period'] = Variable<bool>(isPeriod.value);
    }
    if (flowLevel.present) {
      map['flow_level'] = Variable<int>(flowLevel.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeriodDaysCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('isPeriod: $isPeriod, ')
          ..write('flowLevel: $flowLevel, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $SymptomRecordsTable extends SymptomRecords
    with TableInfo<$SymptomRecordsTable, SymptomRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SymptomRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _symptomTypeMeta = const VerificationMeta(
    'symptomType',
  );
  @override
  late final GeneratedColumn<String> symptomType = GeneratedColumn<String>(
    'symptom_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<int> severity = GeneratedColumn<int>(
    'severity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    date,
    symptomType,
    severity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'symptom_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SymptomRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('symptom_type')) {
      context.handle(
        _symptomTypeMeta,
        symptomType.isAcceptableOrUnknown(
          data['symptom_type']!,
          _symptomTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_symptomTypeMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId, date, symptomType},
  ];
  @override
  SymptomRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SymptomRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      symptomType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptom_type'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}severity'],
      ),
    );
  }

  @override
  $SymptomRecordsTable createAlias(String alias) {
    return $SymptomRecordsTable(attachedDatabase, alias);
  }
}

class SymptomRecord extends DataClass implements Insertable<SymptomRecord> {
  final int id;
  final int userId;
  final DateTime date;

  /// 症状类别文本，如 "头痛" / "腹痛" / "疲劳"。
  final String symptomType;

  /// 强度 0-3；null 表示未评级。
  final int? severity;
  const SymptomRecord({
    required this.id,
    required this.userId,
    required this.date,
    required this.symptomType,
    this.severity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['date'] = Variable<DateTime>(date);
    map['symptom_type'] = Variable<String>(symptomType);
    if (!nullToAbsent || severity != null) {
      map['severity'] = Variable<int>(severity);
    }
    return map;
  }

  SymptomRecordsCompanion toCompanion(bool nullToAbsent) {
    return SymptomRecordsCompanion(
      id: Value(id),
      userId: Value(userId),
      date: Value(date),
      symptomType: Value(symptomType),
      severity: severity == null && nullToAbsent
          ? const Value.absent()
          : Value(severity),
    );
  }

  factory SymptomRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SymptomRecord(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      symptomType: serializer.fromJson<String>(json['symptomType']),
      severity: serializer.fromJson<int?>(json['severity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'date': serializer.toJson<DateTime>(date),
      'symptomType': serializer.toJson<String>(symptomType),
      'severity': serializer.toJson<int?>(severity),
    };
  }

  SymptomRecord copyWith({
    int? id,
    int? userId,
    DateTime? date,
    String? symptomType,
    Value<int?> severity = const Value.absent(),
  }) => SymptomRecord(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    symptomType: symptomType ?? this.symptomType,
    severity: severity.present ? severity.value : this.severity,
  );
  SymptomRecord copyWithCompanion(SymptomRecordsCompanion data) {
    return SymptomRecord(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      symptomType: data.symptomType.present
          ? data.symptomType.value
          : this.symptomType,
      severity: data.severity.present ? data.severity.value : this.severity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SymptomRecord(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('symptomType: $symptomType, ')
          ..write('severity: $severity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, date, symptomType, severity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SymptomRecord &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.symptomType == this.symptomType &&
          other.severity == this.severity);
}

class SymptomRecordsCompanion extends UpdateCompanion<SymptomRecord> {
  final Value<int> id;
  final Value<int> userId;
  final Value<DateTime> date;
  final Value<String> symptomType;
  final Value<int?> severity;
  const SymptomRecordsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.symptomType = const Value.absent(),
    this.severity = const Value.absent(),
  });
  SymptomRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required DateTime date,
    required String symptomType,
    this.severity = const Value.absent(),
  }) : userId = Value(userId),
       date = Value(date),
       symptomType = Value(symptomType);
  static Insertable<SymptomRecord> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<DateTime>? date,
    Expression<String>? symptomType,
    Expression<int>? severity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (symptomType != null) 'symptom_type': symptomType,
      if (severity != null) 'severity': severity,
    });
  }

  SymptomRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<DateTime>? date,
    Value<String>? symptomType,
    Value<int?>? severity,
  }) {
    return SymptomRecordsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      symptomType: symptomType ?? this.symptomType,
      severity: severity ?? this.severity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (symptomType.present) {
      map['symptom_type'] = Variable<String>(symptomType.value);
    }
    if (severity.present) {
      map['severity'] = Variable<int>(severity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SymptomRecordsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('symptomType: $symptomType, ')
          ..write('severity: $severity')
          ..write(')'))
        .toString();
  }
}

class $BodyMetricsTable extends BodyMetrics
    with TableInfo<$BodyMetricsTable, BodyMetric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyMetricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metricTypeMeta = const VerificationMeta(
    'metricType',
  );
  @override
  late final GeneratedColumn<String> metricType = GeneratedColumn<String>(
    'metric_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, date, metricType, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_metrics';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyMetric> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('metric_type')) {
      context.handle(
        _metricTypeMeta,
        metricType.isAcceptableOrUnknown(data['metric_type']!, _metricTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_metricTypeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId, date, metricType},
  ];
  @override
  BodyMetric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyMetric(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      metricType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric_type'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $BodyMetricsTable createAlias(String alias) {
    return $BodyMetricsTable(attachedDatabase, alias);
  }
}

class BodyMetric extends DataClass implements Insertable<BodyMetric> {
  final int id;
  final int userId;
  final DateTime date;

  /// 指标类型文本，如 "体重" / "体温"。
  final String metricType;
  final double value;
  const BodyMetric({
    required this.id,
    required this.userId,
    required this.date,
    required this.metricType,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['date'] = Variable<DateTime>(date);
    map['metric_type'] = Variable<String>(metricType);
    map['value'] = Variable<double>(value);
    return map;
  }

  BodyMetricsCompanion toCompanion(bool nullToAbsent) {
    return BodyMetricsCompanion(
      id: Value(id),
      userId: Value(userId),
      date: Value(date),
      metricType: Value(metricType),
      value: Value(value),
    );
  }

  factory BodyMetric.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyMetric(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      metricType: serializer.fromJson<String>(json['metricType']),
      value: serializer.fromJson<double>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'date': serializer.toJson<DateTime>(date),
      'metricType': serializer.toJson<String>(metricType),
      'value': serializer.toJson<double>(value),
    };
  }

  BodyMetric copyWith({
    int? id,
    int? userId,
    DateTime? date,
    String? metricType,
    double? value,
  }) => BodyMetric(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    metricType: metricType ?? this.metricType,
    value: value ?? this.value,
  );
  BodyMetric copyWithCompanion(BodyMetricsCompanion data) {
    return BodyMetric(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      metricType: data.metricType.present
          ? data.metricType.value
          : this.metricType,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyMetric(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('metricType: $metricType, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, date, metricType, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyMetric &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.metricType == this.metricType &&
          other.value == this.value);
}

class BodyMetricsCompanion extends UpdateCompanion<BodyMetric> {
  final Value<int> id;
  final Value<int> userId;
  final Value<DateTime> date;
  final Value<String> metricType;
  final Value<double> value;
  const BodyMetricsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.metricType = const Value.absent(),
    this.value = const Value.absent(),
  });
  BodyMetricsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required DateTime date,
    required String metricType,
    required double value,
  }) : userId = Value(userId),
       date = Value(date),
       metricType = Value(metricType),
       value = Value(value);
  static Insertable<BodyMetric> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<DateTime>? date,
    Expression<String>? metricType,
    Expression<double>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (metricType != null) 'metric_type': metricType,
      if (value != null) 'value': value,
    });
  }

  BodyMetricsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<DateTime>? date,
    Value<String>? metricType,
    Value<double>? value,
  }) {
    return BodyMetricsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      metricType: metricType ?? this.metricType,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (metricType.present) {
      map['metric_type'] = Variable<String>(metricType.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyMetricsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('metricType: $metricType, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $MoodRecordsTable extends MoodRecords
    with TableInfo<$MoodRecordsTable, MoodRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoodRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodTypeMeta = const VerificationMeta(
    'moodType',
  );
  @override
  late final GeneratedColumn<String> moodType = GeneratedColumn<String>(
    'mood_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intensityMeta = const VerificationMeta(
    'intensity',
  );
  @override
  late final GeneratedColumn<int> intensity = GeneratedColumn<int>(
    'intensity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, date, moodType, intensity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mood_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoodRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('mood_type')) {
      context.handle(
        _moodTypeMeta,
        moodType.isAcceptableOrUnknown(data['mood_type']!, _moodTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_moodTypeMeta);
    }
    if (data.containsKey('intensity')) {
      context.handle(
        _intensityMeta,
        intensity.isAcceptableOrUnknown(data['intensity']!, _intensityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId, date, moodType},
  ];
  @override
  MoodRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoodRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      moodType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood_type'],
      )!,
      intensity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intensity'],
      ),
    );
  }

  @override
  $MoodRecordsTable createAlias(String alias) {
    return $MoodRecordsTable(attachedDatabase, alias);
  }
}

class MoodRecord extends DataClass implements Insertable<MoodRecord> {
  final int id;
  final int userId;
  final DateTime date;

  /// 情绪类型文本，如 "开心" / "低落" / "平静"。
  final String moodType;

  /// 强度 0-3；null 表示未评级。
  final int? intensity;
  const MoodRecord({
    required this.id,
    required this.userId,
    required this.date,
    required this.moodType,
    this.intensity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['date'] = Variable<DateTime>(date);
    map['mood_type'] = Variable<String>(moodType);
    if (!nullToAbsent || intensity != null) {
      map['intensity'] = Variable<int>(intensity);
    }
    return map;
  }

  MoodRecordsCompanion toCompanion(bool nullToAbsent) {
    return MoodRecordsCompanion(
      id: Value(id),
      userId: Value(userId),
      date: Value(date),
      moodType: Value(moodType),
      intensity: intensity == null && nullToAbsent
          ? const Value.absent()
          : Value(intensity),
    );
  }

  factory MoodRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoodRecord(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      moodType: serializer.fromJson<String>(json['moodType']),
      intensity: serializer.fromJson<int?>(json['intensity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'date': serializer.toJson<DateTime>(date),
      'moodType': serializer.toJson<String>(moodType),
      'intensity': serializer.toJson<int?>(intensity),
    };
  }

  MoodRecord copyWith({
    int? id,
    int? userId,
    DateTime? date,
    String? moodType,
    Value<int?> intensity = const Value.absent(),
  }) => MoodRecord(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    moodType: moodType ?? this.moodType,
    intensity: intensity.present ? intensity.value : this.intensity,
  );
  MoodRecord copyWithCompanion(MoodRecordsCompanion data) {
    return MoodRecord(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      moodType: data.moodType.present ? data.moodType.value : this.moodType,
      intensity: data.intensity.present ? data.intensity.value : this.intensity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoodRecord(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('moodType: $moodType, ')
          ..write('intensity: $intensity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, date, moodType, intensity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoodRecord &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.moodType == this.moodType &&
          other.intensity == this.intensity);
}

class MoodRecordsCompanion extends UpdateCompanion<MoodRecord> {
  final Value<int> id;
  final Value<int> userId;
  final Value<DateTime> date;
  final Value<String> moodType;
  final Value<int?> intensity;
  const MoodRecordsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.moodType = const Value.absent(),
    this.intensity = const Value.absent(),
  });
  MoodRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required DateTime date,
    required String moodType,
    this.intensity = const Value.absent(),
  }) : userId = Value(userId),
       date = Value(date),
       moodType = Value(moodType);
  static Insertable<MoodRecord> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<DateTime>? date,
    Expression<String>? moodType,
    Expression<int>? intensity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (moodType != null) 'mood_type': moodType,
      if (intensity != null) 'intensity': intensity,
    });
  }

  MoodRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<DateTime>? date,
    Value<String>? moodType,
    Value<int?>? intensity,
  }) {
    return MoodRecordsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      moodType: moodType ?? this.moodType,
      intensity: intensity ?? this.intensity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (moodType.present) {
      map['mood_type'] = Variable<String>(moodType.value);
    }
    if (intensity.present) {
      map['intensity'] = Variable<int>(intensity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoodRecordsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('moodType: $moodType, ')
          ..write('intensity: $intensity')
          ..write(')'))
        .toString();
  }
}

class $SexRecordsTable extends SexRecords
    with TableInfo<$SexRecordsTable, SexRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SexRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, date, tag, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sex_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SexRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId, date, tag},
  ];
  @override
  SexRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SexRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $SexRecordsTable createAlias(String alias) {
    return $SexRecordsTable(attachedDatabase, alias);
  }
}

class SexRecord extends DataClass implements Insertable<SexRecord> {
  final int id;
  final int userId;
  final DateTime date;

  /// 标签文本，如 "protected" / "unprotected" / "withdrawal" / "orgasm" 等。
  final String tag;

  /// 可选备注（预留扩展）。
  final String? note;
  const SexRecord({
    required this.id,
    required this.userId,
    required this.date,
    required this.tag,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['date'] = Variable<DateTime>(date);
    map['tag'] = Variable<String>(tag);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  SexRecordsCompanion toCompanion(bool nullToAbsent) {
    return SexRecordsCompanion(
      id: Value(id),
      userId: Value(userId),
      date: Value(date),
      tag: Value(tag),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory SexRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SexRecord(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      tag: serializer.fromJson<String>(json['tag']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'date': serializer.toJson<DateTime>(date),
      'tag': serializer.toJson<String>(tag),
      'note': serializer.toJson<String?>(note),
    };
  }

  SexRecord copyWith({
    int? id,
    int? userId,
    DateTime? date,
    String? tag,
    Value<String?> note = const Value.absent(),
  }) => SexRecord(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    tag: tag ?? this.tag,
    note: note.present ? note.value : this.note,
  );
  SexRecord copyWithCompanion(SexRecordsCompanion data) {
    return SexRecord(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      tag: data.tag.present ? data.tag.value : this.tag,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SexRecord(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('tag: $tag, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, date, tag, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SexRecord &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.tag == this.tag &&
          other.note == this.note);
}

class SexRecordsCompanion extends UpdateCompanion<SexRecord> {
  final Value<int> id;
  final Value<int> userId;
  final Value<DateTime> date;
  final Value<String> tag;
  final Value<String?> note;
  const SexRecordsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.tag = const Value.absent(),
    this.note = const Value.absent(),
  });
  SexRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required DateTime date,
    required String tag,
    this.note = const Value.absent(),
  }) : userId = Value(userId),
       date = Value(date),
       tag = Value(tag);
  static Insertable<SexRecord> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<DateTime>? date,
    Expression<String>? tag,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (tag != null) 'tag': tag,
      if (note != null) 'note': note,
    });
  }

  SexRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<DateTime>? date,
    Value<String>? tag,
    Value<String?>? note,
  }) {
    return SexRecordsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      tag: tag ?? this.tag,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SexRecordsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('tag: $tag, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $PredictionSnapshotsTable extends PredictionSnapshots
    with TableInfo<$PredictionSnapshotsTable, PredictionSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PredictionSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _predictedEventMeta = const VerificationMeta(
    'predictedEvent',
  );
  @override
  late final GeneratedColumn<String> predictedEvent = GeneratedColumn<String>(
    'predicted_event',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _predictedDateMeta = const VerificationMeta(
    'predictedDate',
  );
  @override
  late final GeneratedColumn<DateTime> predictedDate =
      GeneratedColumn<DateTime>(
        'predicted_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _confidenceRangeMeta = const VerificationMeta(
    'confidenceRange',
  );
  @override
  late final GeneratedColumn<String> confidenceRange = GeneratedColumn<String>(
    'confidence_range',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    predictedEvent,
    predictedDate,
    confidenceRange,
    modelVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prediction_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<PredictionSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('predicted_event')) {
      context.handle(
        _predictedEventMeta,
        predictedEvent.isAcceptableOrUnknown(
          data['predicted_event']!,
          _predictedEventMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_predictedEventMeta);
    }
    if (data.containsKey('predicted_date')) {
      context.handle(
        _predictedDateMeta,
        predictedDate.isAcceptableOrUnknown(
          data['predicted_date']!,
          _predictedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_predictedDateMeta);
    }
    if (data.containsKey('confidence_range')) {
      context.handle(
        _confidenceRangeMeta,
        confidenceRange.isAcceptableOrUnknown(
          data['confidence_range']!,
          _confidenceRangeMeta,
        ),
      );
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId, predictedEvent, predictedDate},
  ];
  @override
  PredictionSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PredictionSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      predictedEvent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}predicted_event'],
      )!,
      predictedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}predicted_date'],
      )!,
      confidenceRange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confidence_range'],
      ),
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      )!,
    );
  }

  @override
  $PredictionSnapshotsTable createAlias(String alias) {
    return $PredictionSnapshotsTable(attachedDatabase, alias);
  }
}

class PredictionSnapshot extends DataClass
    implements Insertable<PredictionSnapshot> {
  final int id;
  final int userId;

  /// 事件类型枚举文本：nextPeriod / ovulation / windowStart / windowEnd。
  final String predictedEvent;
  final DateTime predictedDate;

  /// 置信区间文本，如 "+-2d"；null 表示未评估。
  final String? confidenceRange;
  final String modelVersion;
  const PredictionSnapshot({
    required this.id,
    required this.userId,
    required this.predictedEvent,
    required this.predictedDate,
    this.confidenceRange,
    required this.modelVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['predicted_event'] = Variable<String>(predictedEvent);
    map['predicted_date'] = Variable<DateTime>(predictedDate);
    if (!nullToAbsent || confidenceRange != null) {
      map['confidence_range'] = Variable<String>(confidenceRange);
    }
    map['model_version'] = Variable<String>(modelVersion);
    return map;
  }

  PredictionSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return PredictionSnapshotsCompanion(
      id: Value(id),
      userId: Value(userId),
      predictedEvent: Value(predictedEvent),
      predictedDate: Value(predictedDate),
      confidenceRange: confidenceRange == null && nullToAbsent
          ? const Value.absent()
          : Value(confidenceRange),
      modelVersion: Value(modelVersion),
    );
  }

  factory PredictionSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PredictionSnapshot(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      predictedEvent: serializer.fromJson<String>(json['predictedEvent']),
      predictedDate: serializer.fromJson<DateTime>(json['predictedDate']),
      confidenceRange: serializer.fromJson<String?>(json['confidenceRange']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'predictedEvent': serializer.toJson<String>(predictedEvent),
      'predictedDate': serializer.toJson<DateTime>(predictedDate),
      'confidenceRange': serializer.toJson<String?>(confidenceRange),
      'modelVersion': serializer.toJson<String>(modelVersion),
    };
  }

  PredictionSnapshot copyWith({
    int? id,
    int? userId,
    String? predictedEvent,
    DateTime? predictedDate,
    Value<String?> confidenceRange = const Value.absent(),
    String? modelVersion,
  }) => PredictionSnapshot(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    predictedEvent: predictedEvent ?? this.predictedEvent,
    predictedDate: predictedDate ?? this.predictedDate,
    confidenceRange: confidenceRange.present
        ? confidenceRange.value
        : this.confidenceRange,
    modelVersion: modelVersion ?? this.modelVersion,
  );
  PredictionSnapshot copyWithCompanion(PredictionSnapshotsCompanion data) {
    return PredictionSnapshot(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      predictedEvent: data.predictedEvent.present
          ? data.predictedEvent.value
          : this.predictedEvent,
      predictedDate: data.predictedDate.present
          ? data.predictedDate.value
          : this.predictedDate,
      confidenceRange: data.confidenceRange.present
          ? data.confidenceRange.value
          : this.confidenceRange,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PredictionSnapshot(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('predictedEvent: $predictedEvent, ')
          ..write('predictedDate: $predictedDate, ')
          ..write('confidenceRange: $confidenceRange, ')
          ..write('modelVersion: $modelVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    predictedEvent,
    predictedDate,
    confidenceRange,
    modelVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PredictionSnapshot &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.predictedEvent == this.predictedEvent &&
          other.predictedDate == this.predictedDate &&
          other.confidenceRange == this.confidenceRange &&
          other.modelVersion == this.modelVersion);
}

class PredictionSnapshotsCompanion extends UpdateCompanion<PredictionSnapshot> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> predictedEvent;
  final Value<DateTime> predictedDate;
  final Value<String?> confidenceRange;
  final Value<String> modelVersion;
  const PredictionSnapshotsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.predictedEvent = const Value.absent(),
    this.predictedDate = const Value.absent(),
    this.confidenceRange = const Value.absent(),
    this.modelVersion = const Value.absent(),
  });
  PredictionSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String predictedEvent,
    required DateTime predictedDate,
    this.confidenceRange = const Value.absent(),
    this.modelVersion = const Value.absent(),
  }) : userId = Value(userId),
       predictedEvent = Value(predictedEvent),
       predictedDate = Value(predictedDate);
  static Insertable<PredictionSnapshot> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? predictedEvent,
    Expression<DateTime>? predictedDate,
    Expression<String>? confidenceRange,
    Expression<String>? modelVersion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (predictedEvent != null) 'predicted_event': predictedEvent,
      if (predictedDate != null) 'predicted_date': predictedDate,
      if (confidenceRange != null) 'confidence_range': confidenceRange,
      if (modelVersion != null) 'model_version': modelVersion,
    });
  }

  PredictionSnapshotsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<String>? predictedEvent,
    Value<DateTime>? predictedDate,
    Value<String?>? confidenceRange,
    Value<String>? modelVersion,
  }) {
    return PredictionSnapshotsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      predictedEvent: predictedEvent ?? this.predictedEvent,
      predictedDate: predictedDate ?? this.predictedDate,
      confidenceRange: confidenceRange ?? this.confidenceRange,
      modelVersion: modelVersion ?? this.modelVersion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (predictedEvent.present) {
      map['predicted_event'] = Variable<String>(predictedEvent.value);
    }
    if (predictedDate.present) {
      map['predicted_date'] = Variable<DateTime>(predictedDate.value);
    }
    if (confidenceRange.present) {
      map['confidence_range'] = Variable<String>(confidenceRange.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PredictionSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('predictedEvent: $predictedEvent, ')
          ..write('predictedDate: $predictedDate, ')
          ..write('confidenceRange: $confidenceRange, ')
          ..write('modelVersion: $modelVersion')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $PeriodDaysTable periodDays = $PeriodDaysTable(this);
  late final $SymptomRecordsTable symptomRecords = $SymptomRecordsTable(this);
  late final $BodyMetricsTable bodyMetrics = $BodyMetricsTable(this);
  late final $MoodRecordsTable moodRecords = $MoodRecordsTable(this);
  late final $SexRecordsTable sexRecords = $SexRecordsTable(this);
  late final $PredictionSnapshotsTable predictionSnapshots =
      $PredictionSnapshotsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    periodDays,
    symptomRecords,
    bodyMetrics,
    moodRecords,
    sexRecords,
    predictionSnapshots,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> localId,
      Value<int> expectCycleLength,
      Value<int> expectPeriodLength,
      Value<DateTime?> lastPeriodStart,
      Value<DateTime> createdAt,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> localId,
      Value<int> expectCycleLength,
      Value<int> expectPeriodLength,
      Value<DateTime?> lastPeriodStart,
      Value<DateTime> createdAt,
    });

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, UserRow> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PeriodDaysTable, List<PeriodDay>>
  _periodDaysRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.periodDays,
    aliasName: 'users__id__period_days__user_id',
  );

  $$PeriodDaysTableProcessedTableManager get periodDaysRefs {
    final manager = $$PeriodDaysTableTableManager(
      $_db,
      $_db.periodDays,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_periodDaysRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SymptomRecordsTable, List<SymptomRecord>>
  _symptomRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.symptomRecords,
    aliasName: 'users__id__symptom_records__user_id',
  );

  $$SymptomRecordsTableProcessedTableManager get symptomRecordsRefs {
    final manager = $$SymptomRecordsTableTableManager(
      $_db,
      $_db.symptomRecords,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_symptomRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BodyMetricsTable, List<BodyMetric>>
  _bodyMetricsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bodyMetrics,
    aliasName: 'users__id__body_metrics__user_id',
  );

  $$BodyMetricsTableProcessedTableManager get bodyMetricsRefs {
    final manager = $$BodyMetricsTableTableManager(
      $_db,
      $_db.bodyMetrics,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bodyMetricsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MoodRecordsTable, List<MoodRecord>>
  _moodRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.moodRecords,
    aliasName: 'users__id__mood_records__user_id',
  );

  $$MoodRecordsTableProcessedTableManager get moodRecordsRefs {
    final manager = $$MoodRecordsTableTableManager(
      $_db,
      $_db.moodRecords,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_moodRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SexRecordsTable, List<SexRecord>>
  _sexRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sexRecords,
    aliasName: 'users__id__sex_records__user_id',
  );

  $$SexRecordsTableProcessedTableManager get sexRecordsRefs {
    final manager = $$SexRecordsTableTableManager(
      $_db,
      $_db.sexRecords,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sexRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PredictionSnapshotsTable,
    List<PredictionSnapshot>
  >
  _predictionSnapshotsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.predictionSnapshots,
        aliasName: 'users__id__prediction_snapshots__user_id',
      );

  $$PredictionSnapshotsTableProcessedTableManager get predictionSnapshotsRefs {
    final manager = $$PredictionSnapshotsTableTableManager(
      $_db,
      $_db.predictionSnapshots,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _predictionSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectCycleLength => $composableBuilder(
    column: $table.expectCycleLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectPeriodLength => $composableBuilder(
    column: $table.expectPeriodLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPeriodStart => $composableBuilder(
    column: $table.lastPeriodStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> periodDaysRefs(
    Expression<bool> Function($$PeriodDaysTableFilterComposer f) f,
  ) {
    final $$PeriodDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.periodDays,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodDaysTableFilterComposer(
            $db: $db,
            $table: $db.periodDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> symptomRecordsRefs(
    Expression<bool> Function($$SymptomRecordsTableFilterComposer f) f,
  ) {
    final $$SymptomRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.symptomRecords,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SymptomRecordsTableFilterComposer(
            $db: $db,
            $table: $db.symptomRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bodyMetricsRefs(
    Expression<bool> Function($$BodyMetricsTableFilterComposer f) f,
  ) {
    final $$BodyMetricsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bodyMetrics,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BodyMetricsTableFilterComposer(
            $db: $db,
            $table: $db.bodyMetrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> moodRecordsRefs(
    Expression<bool> Function($$MoodRecordsTableFilterComposer f) f,
  ) {
    final $$MoodRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moodRecords,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodRecordsTableFilterComposer(
            $db: $db,
            $table: $db.moodRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sexRecordsRefs(
    Expression<bool> Function($$SexRecordsTableFilterComposer f) f,
  ) {
    final $$SexRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sexRecords,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SexRecordsTableFilterComposer(
            $db: $db,
            $table: $db.sexRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> predictionSnapshotsRefs(
    Expression<bool> Function($$PredictionSnapshotsTableFilterComposer f) f,
  ) {
    final $$PredictionSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.predictionSnapshots,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PredictionSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.predictionSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectCycleLength => $composableBuilder(
    column: $table.expectCycleLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectPeriodLength => $composableBuilder(
    column: $table.expectPeriodLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPeriodStart => $composableBuilder(
    column: $table.lastPeriodStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get expectCycleLength => $composableBuilder(
    column: $table.expectCycleLength,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectPeriodLength => $composableBuilder(
    column: $table.expectPeriodLength,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPeriodStart => $composableBuilder(
    column: $table.lastPeriodStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> periodDaysRefs<T extends Object>(
    Expression<T> Function($$PeriodDaysTableAnnotationComposer a) f,
  ) {
    final $$PeriodDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.periodDays,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.periodDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> symptomRecordsRefs<T extends Object>(
    Expression<T> Function($$SymptomRecordsTableAnnotationComposer a) f,
  ) {
    final $$SymptomRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.symptomRecords,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SymptomRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.symptomRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bodyMetricsRefs<T extends Object>(
    Expression<T> Function($$BodyMetricsTableAnnotationComposer a) f,
  ) {
    final $$BodyMetricsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bodyMetrics,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BodyMetricsTableAnnotationComposer(
            $db: $db,
            $table: $db.bodyMetrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> moodRecordsRefs<T extends Object>(
    Expression<T> Function($$MoodRecordsTableAnnotationComposer a) f,
  ) {
    final $$MoodRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moodRecords,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.moodRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sexRecordsRefs<T extends Object>(
    Expression<T> Function($$SexRecordsTableAnnotationComposer a) f,
  ) {
    final $$SexRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sexRecords,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SexRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.sexRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> predictionSnapshotsRefs<T extends Object>(
    Expression<T> Function($$PredictionSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$PredictionSnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.predictionSnapshots,
          getReferencedColumn: (t) => t.userId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PredictionSnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.predictionSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          UserRow,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserRow, $$UsersTableReferences),
          UserRow,
          PrefetchHooks Function({
            bool periodDaysRefs,
            bool symptomRecordsRefs,
            bool bodyMetricsRefs,
            bool moodRecordsRefs,
            bool sexRecordsRefs,
            bool predictionSnapshotsRefs,
          })
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> localId = const Value.absent(),
                Value<int> expectCycleLength = const Value.absent(),
                Value<int> expectPeriodLength = const Value.absent(),
                Value<DateTime?> lastPeriodStart = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                localId: localId,
                expectCycleLength: expectCycleLength,
                expectPeriodLength: expectPeriodLength,
                lastPeriodStart: lastPeriodStart,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> localId = const Value.absent(),
                Value<int> expectCycleLength = const Value.absent(),
                Value<int> expectPeriodLength = const Value.absent(),
                Value<DateTime?> lastPeriodStart = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                localId: localId,
                expectCycleLength: expectCycleLength,
                expectPeriodLength: expectPeriodLength,
                lastPeriodStart: lastPeriodStart,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTable, UserRow>(table),
                  $$UsersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                periodDaysRefs = false,
                symptomRecordsRefs = false,
                bodyMetricsRefs = false,
                moodRecordsRefs = false,
                sexRecordsRefs = false,
                predictionSnapshotsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (periodDaysRefs) db.periodDays,
                    if (symptomRecordsRefs) db.symptomRecords,
                    if (bodyMetricsRefs) db.bodyMetrics,
                    if (moodRecordsRefs) db.moodRecords,
                    if (sexRecordsRefs) db.sexRecords,
                    if (predictionSnapshotsRefs) db.predictionSnapshots,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (periodDaysRefs)
                        await $_getPrefetchedData<
                          UserRow,
                          $UsersTable,
                          PeriodDay
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._periodDaysRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).periodDaysRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (symptomRecordsRefs)
                        await $_getPrefetchedData<
                          UserRow,
                          $UsersTable,
                          SymptomRecord
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._symptomRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).symptomRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bodyMetricsRefs)
                        await $_getPrefetchedData<
                          UserRow,
                          $UsersTable,
                          BodyMetric
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._bodyMetricsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).bodyMetricsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (moodRecordsRefs)
                        await $_getPrefetchedData<
                          UserRow,
                          $UsersTable,
                          MoodRecord
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._moodRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).moodRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sexRecordsRefs)
                        await $_getPrefetchedData<
                          UserRow,
                          $UsersTable,
                          SexRecord
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._sexRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).sexRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (predictionSnapshotsRefs)
                        await $_getPrefetchedData<
                          UserRow,
                          $UsersTable,
                          PredictionSnapshot
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._predictionSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).predictionSnapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      UserRow,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserRow, $$UsersTableReferences),
      UserRow,
      PrefetchHooks Function({
        bool periodDaysRefs,
        bool symptomRecordsRefs,
        bool bodyMetricsRefs,
        bool moodRecordsRefs,
        bool sexRecordsRefs,
        bool predictionSnapshotsRefs,
      })
    >;
typedef $$PeriodDaysTableCreateCompanionBuilder =
    PeriodDaysCompanion Function({
      Value<int> id,
      required int userId,
      required DateTime date,
      Value<bool> isPeriod,
      Value<int?> flowLevel,
      Value<String?> note,
    });
typedef $$PeriodDaysTableUpdateCompanionBuilder =
    PeriodDaysCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<DateTime> date,
      Value<bool> isPeriod,
      Value<int?> flowLevel,
      Value<String?> note,
    });

final class $$PeriodDaysTableReferences
    extends BaseReferences<_$AppDatabase, $PeriodDaysTable, PeriodDay> {
  $$PeriodDaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('period_days__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PeriodDaysTableFilterComposer
    extends Composer<_$AppDatabase, $PeriodDaysTable> {
  $$PeriodDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPeriod => $composableBuilder(
    column: $table.isPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flowLevel => $composableBuilder(
    column: $table.flowLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PeriodDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $PeriodDaysTable> {
  $$PeriodDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPeriod => $composableBuilder(
    column: $table.isPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flowLevel => $composableBuilder(
    column: $table.flowLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PeriodDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeriodDaysTable> {
  $$PeriodDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get isPeriod =>
      $composableBuilder(column: $table.isPeriod, builder: (column) => column);

  GeneratedColumn<int> get flowLevel =>
      $composableBuilder(column: $table.flowLevel, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PeriodDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeriodDaysTable,
          PeriodDay,
          $$PeriodDaysTableFilterComposer,
          $$PeriodDaysTableOrderingComposer,
          $$PeriodDaysTableAnnotationComposer,
          $$PeriodDaysTableCreateCompanionBuilder,
          $$PeriodDaysTableUpdateCompanionBuilder,
          (PeriodDay, $$PeriodDaysTableReferences),
          PeriodDay,
          PrefetchHooks Function({bool userId})
        > {
  $$PeriodDaysTableTableManager(_$AppDatabase db, $PeriodDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeriodDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeriodDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeriodDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<bool> isPeriod = const Value.absent(),
                Value<int?> flowLevel = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => PeriodDaysCompanion(
                id: id,
                userId: userId,
                date: date,
                isPeriod: isPeriod,
                flowLevel: flowLevel,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required DateTime date,
                Value<bool> isPeriod = const Value.absent(),
                Value<int?> flowLevel = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => PeriodDaysCompanion.insert(
                id: id,
                userId: userId,
                date: date,
                isPeriod: isPeriod,
                flowLevel: flowLevel,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PeriodDaysTable, PeriodDay>(table),
                  $$PeriodDaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$PeriodDaysTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$PeriodDaysTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PeriodDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeriodDaysTable,
      PeriodDay,
      $$PeriodDaysTableFilterComposer,
      $$PeriodDaysTableOrderingComposer,
      $$PeriodDaysTableAnnotationComposer,
      $$PeriodDaysTableCreateCompanionBuilder,
      $$PeriodDaysTableUpdateCompanionBuilder,
      (PeriodDay, $$PeriodDaysTableReferences),
      PeriodDay,
      PrefetchHooks Function({bool userId})
    >;
typedef $$SymptomRecordsTableCreateCompanionBuilder =
    SymptomRecordsCompanion Function({
      Value<int> id,
      required int userId,
      required DateTime date,
      required String symptomType,
      Value<int?> severity,
    });
typedef $$SymptomRecordsTableUpdateCompanionBuilder =
    SymptomRecordsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<DateTime> date,
      Value<String> symptomType,
      Value<int?> severity,
    });

final class $$SymptomRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $SymptomRecordsTable, SymptomRecord> {
  $$SymptomRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('symptom_records__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SymptomRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SymptomRecordsTable> {
  $$SymptomRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symptomType => $composableBuilder(
    column: $table.symptomType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SymptomRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SymptomRecordsTable> {
  $$SymptomRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptomType => $composableBuilder(
    column: $table.symptomType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SymptomRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SymptomRecordsTable> {
  $$SymptomRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get symptomType => $composableBuilder(
    column: $table.symptomType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SymptomRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SymptomRecordsTable,
          SymptomRecord,
          $$SymptomRecordsTableFilterComposer,
          $$SymptomRecordsTableOrderingComposer,
          $$SymptomRecordsTableAnnotationComposer,
          $$SymptomRecordsTableCreateCompanionBuilder,
          $$SymptomRecordsTableUpdateCompanionBuilder,
          (SymptomRecord, $$SymptomRecordsTableReferences),
          SymptomRecord,
          PrefetchHooks Function({bool userId})
        > {
  $$SymptomRecordsTableTableManager(
    _$AppDatabase db,
    $SymptomRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SymptomRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SymptomRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SymptomRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> symptomType = const Value.absent(),
                Value<int?> severity = const Value.absent(),
              }) => SymptomRecordsCompanion(
                id: id,
                userId: userId,
                date: date,
                symptomType: symptomType,
                severity: severity,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required DateTime date,
                required String symptomType,
                Value<int?> severity = const Value.absent(),
              }) => SymptomRecordsCompanion.insert(
                id: id,
                userId: userId,
                date: date,
                symptomType: symptomType,
                severity: severity,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SymptomRecordsTable, SymptomRecord>(table),
                  $$SymptomRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$SymptomRecordsTableReferences
                                    ._userIdTable(db),
                                referencedColumn:
                                    $$SymptomRecordsTableReferences
                                        ._userIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SymptomRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SymptomRecordsTable,
      SymptomRecord,
      $$SymptomRecordsTableFilterComposer,
      $$SymptomRecordsTableOrderingComposer,
      $$SymptomRecordsTableAnnotationComposer,
      $$SymptomRecordsTableCreateCompanionBuilder,
      $$SymptomRecordsTableUpdateCompanionBuilder,
      (SymptomRecord, $$SymptomRecordsTableReferences),
      SymptomRecord,
      PrefetchHooks Function({bool userId})
    >;
typedef $$BodyMetricsTableCreateCompanionBuilder =
    BodyMetricsCompanion Function({
      Value<int> id,
      required int userId,
      required DateTime date,
      required String metricType,
      required double value,
    });
typedef $$BodyMetricsTableUpdateCompanionBuilder =
    BodyMetricsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<DateTime> date,
      Value<String> metricType,
      Value<double> value,
    });

final class $$BodyMetricsTableReferences
    extends BaseReferences<_$AppDatabase, $BodyMetricsTable, BodyMetric> {
  $$BodyMetricsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('body_metrics__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BodyMetricsTableFilterComposer
    extends Composer<_$AppDatabase, $BodyMetricsTable> {
  $$BodyMetricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metricType => $composableBuilder(
    column: $table.metricType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BodyMetricsTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyMetricsTable> {
  $$BodyMetricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricType => $composableBuilder(
    column: $table.metricType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BodyMetricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyMetricsTable> {
  $$BodyMetricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get metricType => $composableBuilder(
    column: $table.metricType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BodyMetricsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyMetricsTable,
          BodyMetric,
          $$BodyMetricsTableFilterComposer,
          $$BodyMetricsTableOrderingComposer,
          $$BodyMetricsTableAnnotationComposer,
          $$BodyMetricsTableCreateCompanionBuilder,
          $$BodyMetricsTableUpdateCompanionBuilder,
          (BodyMetric, $$BodyMetricsTableReferences),
          BodyMetric,
          PrefetchHooks Function({bool userId})
        > {
  $$BodyMetricsTableTableManager(_$AppDatabase db, $BodyMetricsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyMetricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyMetricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyMetricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> metricType = const Value.absent(),
                Value<double> value = const Value.absent(),
              }) => BodyMetricsCompanion(
                id: id,
                userId: userId,
                date: date,
                metricType: metricType,
                value: value,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required DateTime date,
                required String metricType,
                required double value,
              }) => BodyMetricsCompanion.insert(
                id: id,
                userId: userId,
                date: date,
                metricType: metricType,
                value: value,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BodyMetricsTable, BodyMetric>(table),
                  $$BodyMetricsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$BodyMetricsTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$BodyMetricsTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BodyMetricsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyMetricsTable,
      BodyMetric,
      $$BodyMetricsTableFilterComposer,
      $$BodyMetricsTableOrderingComposer,
      $$BodyMetricsTableAnnotationComposer,
      $$BodyMetricsTableCreateCompanionBuilder,
      $$BodyMetricsTableUpdateCompanionBuilder,
      (BodyMetric, $$BodyMetricsTableReferences),
      BodyMetric,
      PrefetchHooks Function({bool userId})
    >;
typedef $$MoodRecordsTableCreateCompanionBuilder =
    MoodRecordsCompanion Function({
      Value<int> id,
      required int userId,
      required DateTime date,
      required String moodType,
      Value<int?> intensity,
    });
typedef $$MoodRecordsTableUpdateCompanionBuilder =
    MoodRecordsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<DateTime> date,
      Value<String> moodType,
      Value<int?> intensity,
    });

final class $$MoodRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $MoodRecordsTable, MoodRecord> {
  $$MoodRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('mood_records__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MoodRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MoodRecordsTable> {
  $$MoodRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moodType => $composableBuilder(
    column: $table.moodType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoodRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MoodRecordsTable> {
  $$MoodRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moodType => $composableBuilder(
    column: $table.moodType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoodRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoodRecordsTable> {
  $$MoodRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get moodType =>
      $composableBuilder(column: $table.moodType, builder: (column) => column);

  GeneratedColumn<int> get intensity =>
      $composableBuilder(column: $table.intensity, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoodRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoodRecordsTable,
          MoodRecord,
          $$MoodRecordsTableFilterComposer,
          $$MoodRecordsTableOrderingComposer,
          $$MoodRecordsTableAnnotationComposer,
          $$MoodRecordsTableCreateCompanionBuilder,
          $$MoodRecordsTableUpdateCompanionBuilder,
          (MoodRecord, $$MoodRecordsTableReferences),
          MoodRecord,
          PrefetchHooks Function({bool userId})
        > {
  $$MoodRecordsTableTableManager(_$AppDatabase db, $MoodRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoodRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoodRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoodRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> moodType = const Value.absent(),
                Value<int?> intensity = const Value.absent(),
              }) => MoodRecordsCompanion(
                id: id,
                userId: userId,
                date: date,
                moodType: moodType,
                intensity: intensity,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required DateTime date,
                required String moodType,
                Value<int?> intensity = const Value.absent(),
              }) => MoodRecordsCompanion.insert(
                id: id,
                userId: userId,
                date: date,
                moodType: moodType,
                intensity: intensity,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MoodRecordsTable, MoodRecord>(table),
                  $$MoodRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$MoodRecordsTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$MoodRecordsTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MoodRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoodRecordsTable,
      MoodRecord,
      $$MoodRecordsTableFilterComposer,
      $$MoodRecordsTableOrderingComposer,
      $$MoodRecordsTableAnnotationComposer,
      $$MoodRecordsTableCreateCompanionBuilder,
      $$MoodRecordsTableUpdateCompanionBuilder,
      (MoodRecord, $$MoodRecordsTableReferences),
      MoodRecord,
      PrefetchHooks Function({bool userId})
    >;
typedef $$SexRecordsTableCreateCompanionBuilder =
    SexRecordsCompanion Function({
      Value<int> id,
      required int userId,
      required DateTime date,
      required String tag,
      Value<String?> note,
    });
typedef $$SexRecordsTableUpdateCompanionBuilder =
    SexRecordsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<DateTime> date,
      Value<String> tag,
      Value<String?> note,
    });

final class $$SexRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $SexRecordsTable, SexRecord> {
  $$SexRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('sex_records__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SexRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SexRecordsTable> {
  $$SexRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SexRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SexRecordsTable> {
  $$SexRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SexRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SexRecordsTable> {
  $$SexRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SexRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SexRecordsTable,
          SexRecord,
          $$SexRecordsTableFilterComposer,
          $$SexRecordsTableOrderingComposer,
          $$SexRecordsTableAnnotationComposer,
          $$SexRecordsTableCreateCompanionBuilder,
          $$SexRecordsTableUpdateCompanionBuilder,
          (SexRecord, $$SexRecordsTableReferences),
          SexRecord,
          PrefetchHooks Function({bool userId})
        > {
  $$SexRecordsTableTableManager(_$AppDatabase db, $SexRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SexRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SexRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SexRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> tag = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => SexRecordsCompanion(
                id: id,
                userId: userId,
                date: date,
                tag: tag,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required DateTime date,
                required String tag,
                Value<String?> note = const Value.absent(),
              }) => SexRecordsCompanion.insert(
                id: id,
                userId: userId,
                date: date,
                tag: tag,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SexRecordsTable, SexRecord>(table),
                  $$SexRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$SexRecordsTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$SexRecordsTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SexRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SexRecordsTable,
      SexRecord,
      $$SexRecordsTableFilterComposer,
      $$SexRecordsTableOrderingComposer,
      $$SexRecordsTableAnnotationComposer,
      $$SexRecordsTableCreateCompanionBuilder,
      $$SexRecordsTableUpdateCompanionBuilder,
      (SexRecord, $$SexRecordsTableReferences),
      SexRecord,
      PrefetchHooks Function({bool userId})
    >;
typedef $$PredictionSnapshotsTableCreateCompanionBuilder =
    PredictionSnapshotsCompanion Function({
      Value<int> id,
      required int userId,
      required String predictedEvent,
      required DateTime predictedDate,
      Value<String?> confidenceRange,
      Value<String> modelVersion,
    });
typedef $$PredictionSnapshotsTableUpdateCompanionBuilder =
    PredictionSnapshotsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<String> predictedEvent,
      Value<DateTime> predictedDate,
      Value<String?> confidenceRange,
      Value<String> modelVersion,
    });

final class $$PredictionSnapshotsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PredictionSnapshotsTable,
          PredictionSnapshot
        > {
  $$PredictionSnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('prediction_snapshots__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PredictionSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $PredictionSnapshotsTable> {
  $$PredictionSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get predictedEvent => $composableBuilder(
    column: $table.predictedEvent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get predictedDate => $composableBuilder(
    column: $table.predictedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confidenceRange => $composableBuilder(
    column: $table.confidenceRange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PredictionSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $PredictionSnapshotsTable> {
  $$PredictionSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get predictedEvent => $composableBuilder(
    column: $table.predictedEvent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get predictedDate => $composableBuilder(
    column: $table.predictedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidenceRange => $composableBuilder(
    column: $table.confidenceRange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PredictionSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PredictionSnapshotsTable> {
  $$PredictionSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get predictedEvent => $composableBuilder(
    column: $table.predictedEvent,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get predictedDate => $composableBuilder(
    column: $table.predictedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confidenceRange => $composableBuilder(
    column: $table.confidenceRange,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PredictionSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PredictionSnapshotsTable,
          PredictionSnapshot,
          $$PredictionSnapshotsTableFilterComposer,
          $$PredictionSnapshotsTableOrderingComposer,
          $$PredictionSnapshotsTableAnnotationComposer,
          $$PredictionSnapshotsTableCreateCompanionBuilder,
          $$PredictionSnapshotsTableUpdateCompanionBuilder,
          (PredictionSnapshot, $$PredictionSnapshotsTableReferences),
          PredictionSnapshot,
          PrefetchHooks Function({bool userId})
        > {
  $$PredictionSnapshotsTableTableManager(
    _$AppDatabase db,
    $PredictionSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PredictionSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PredictionSnapshotsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PredictionSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> predictedEvent = const Value.absent(),
                Value<DateTime> predictedDate = const Value.absent(),
                Value<String?> confidenceRange = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
              }) => PredictionSnapshotsCompanion(
                id: id,
                userId: userId,
                predictedEvent: predictedEvent,
                predictedDate: predictedDate,
                confidenceRange: confidenceRange,
                modelVersion: modelVersion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required String predictedEvent,
                required DateTime predictedDate,
                Value<String?> confidenceRange = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
              }) => PredictionSnapshotsCompanion.insert(
                id: id,
                userId: userId,
                predictedEvent: predictedEvent,
                predictedDate: predictedDate,
                confidenceRange: confidenceRange,
                modelVersion: modelVersion,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PredictionSnapshotsTable, PredictionSnapshot>(
                    table,
                  ),
                  $$PredictionSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable:
                                    $$PredictionSnapshotsTableReferences
                                        ._userIdTable(db),
                                referencedColumn:
                                    $$PredictionSnapshotsTableReferences
                                        ._userIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PredictionSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PredictionSnapshotsTable,
      PredictionSnapshot,
      $$PredictionSnapshotsTableFilterComposer,
      $$PredictionSnapshotsTableOrderingComposer,
      $$PredictionSnapshotsTableAnnotationComposer,
      $$PredictionSnapshotsTableCreateCompanionBuilder,
      $$PredictionSnapshotsTableUpdateCompanionBuilder,
      (PredictionSnapshot, $$PredictionSnapshotsTableReferences),
      PredictionSnapshot,
      PrefetchHooks Function({bool userId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$PeriodDaysTableTableManager get periodDays =>
      $$PeriodDaysTableTableManager(_db, _db.periodDays);
  $$SymptomRecordsTableTableManager get symptomRecords =>
      $$SymptomRecordsTableTableManager(_db, _db.symptomRecords);
  $$BodyMetricsTableTableManager get bodyMetrics =>
      $$BodyMetricsTableTableManager(_db, _db.bodyMetrics);
  $$MoodRecordsTableTableManager get moodRecords =>
      $$MoodRecordsTableTableManager(_db, _db.moodRecords);
  $$SexRecordsTableTableManager get sexRecords =>
      $$SexRecordsTableTableManager(_db, _db.sexRecords);
  $$PredictionSnapshotsTableTableManager get predictionSnapshots =>
      $$PredictionSnapshotsTableTableManager(_db, _db.predictionSnapshots);
}
