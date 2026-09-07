import 'package:get_it/get_it.dart';

import '../../data/current_user.dart';
import '../../data/data_transfer_service.dart';
import '../../data/repositories/record_repository.dart';
import '../../prediction/prediction_service.dart';
import '../db/app_database.dart';
import '../secure/secure_store.dart';

/// 服务定位器（对应 PRD 23.1/23.3 依赖注入骨架）。
/// 各 feature 通过 `getIt<T>()` 按需获取，便于替换与单测。
final GetIt getIt = GetIt.instance;

/// 初始化核心模块的单例注册。在 runApp 前调用一次。
Future<void> configureDependencies() async {
  // 数据层（同一数据库实例被各 feature 复用）
  getIt.registerLazySingleton<AppDatabase>(AppDatabase.new);
  // 记录仓库（数据访问层，见 B Stage）
  getIt.registerLazySingleton<RecordRepository>(
    () => RecordRepository(getIt<AppDatabase>()),
  );
  // 当前用户（本地单用户）
  getIt.registerLazySingleton<CurrentUser>(
    () => CurrentUser(repository: getIt<RecordRepository>()),
  );
  // 预测服务（G Stage）
  getIt.registerLazySingleton<PredictionService>(
    () => PredictionService(repository: getIt<RecordRepository>()),
  );
  // 数据迁移（导出 JSON + 合并去重导入，见 DataTransferService）
  getIt.registerLazySingleton<DataTransferService>(
    () => DataTransferService(getIt<AppDatabase>()),
  );
  // 安全存储
  getIt.registerLazySingleton<SecureStore>(SecureStore.new);
}