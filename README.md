# 月季（period_tracker）

一款**本地优先**的经期记录与周期预测 App，全功能免费、无广告、无内购。iOS / Android 双端同发，基于 Flutter 构建。

> 核心定位：面向普通女性用户的经期记录 + 智能预测工具，科学记录、隐私第一、界面克制。

## 功能特性

- **今日页**：周期状态卡片 + 快捷记录入口，一眼掌握当前生理阶段与下次经期/排卵预测。
- **日历**：月视图 / 周视图，经期（实心红）、预测经期（虚线）、排卵日、受孕窗口、性生活记录（青色圆点）多维标记。
- **跟踪记录**：分类漏斗式录入，覆盖经期流量、症状、情绪、性生活、身体指标、备注六类，支持强度分级与自定义标签，单次记录 3 秒内完成。
- **智能预测**：自适应加权平均算法（非固定 28 天），预测下期经期、排卵日与受孕窗口，并展示置信区间与免责声明。
- **统计分析**：周期长度 / 经期长度趋势、症状频率、情绪曲线等图表可视化。
- **数据导入导出**：JSON 全量导出 + 合并去重导入，导入前自动备份、支持回滚。
- **隐私安全**：本地 SQLite 存储 + 系统安全存储（Keychain / EncryptedSharedPreferences）保护密钥，无第三方追踪。
- **国际化**：中 / 英双语，支持系统深色模式。

## 技术栈

| 层 | 技术 |
|----|------|
| UI 框架 | Flutter（Dart SDK ^3.12.1） |
| 本地数据库 | drift（SQLite） |
| 加密存储 | flutter_secure_storage |
| 依赖注入 | get_it |
| 状态管理 | ChangeNotifier + 全局单例控制器 |
| 本地化 | flutter_localizations + intl（arb） |
| 平台 | Android（armv7 / armv8）、iOS |

## 目录结构

```
lib/
├── main.dart                    # 入口：初始化依赖、本地化、安全存储
├── app.dart                     # 根组件：5-tab 底部导航 + 全局主题/设置控制器
├── core/
│   ├── db/                      # drift 数据库定义与代码生成
│   ├── di/                      # get_it 依赖注入
│   ├── i18n/                    # 语言控制与格式化
│   ├── secure/                  # 安全存储封装
│   ├── theme/                   # 浅色/深色 Design Token 主题
│   └── widgets/                 # 通用组件
├── data/
│   ├── repositories/            # 数据访问层（RecordRepository）
│   ├── data_transfer_service.dart    # JSON 导入导出 + 合并去重
│   └── auto_backup_controller.dart   # 自动备份
├── prediction/                  # 周期预测引擎（独立可测试模块）
│   ├── cycle_math.dart          # 加权平均、异常值剔除等算法
│   └── prediction_service.dart
├── features/                    # 业务页面
│   ├── today/                   # 今日
│   ├── calendar/                # 日历
│   ├── track/                   # 跟踪记录
│   ├── stats/                   # 统计分析
│   ├── settings/                # 设置与周期个性化
│   ├── record/                  # 记录向导
│   ├── privacy/                 # 隐私说明
│   └── account/                 # 账号
└── l10n/                        # 本地化资源（zh / en）
```

### 数据模型

drift 表（`schemaVersion` 见 `lib/core/db/app_database.dart`）：

- `Users` — 用户周期基准配置
- `PeriodDays` — 经期日记录，唯一键 `(userId, date)`
- `SymptomRecords` — 症状，唯一键 `(symptom, date, symptomType)`
- `BodyMetrics` — 身体指标，唯一键 `(metric, date, metricType)`
- `MoodRecords` — 情绪，唯一键 `(mood, date, moodType)`
- `SexRecords` — 性生活标签模型，唯一键 `(userId, date, tag)`
- `PredictionSnapshots` — 预测快照（仅缓存展示）

## 快速开始

前置要求：安装 [Flutter SDK](https://docs.flutter.dev/get-started/install)（含 Dart SDK ^3.12.1）。

```bash
# 安装依赖
flutter pub get

# 生成 drift 数据库代码（表结构变更后需重新执行）
dart run build_runner build --delete-conflicting-outputs

# 运行（选择目标设备）
flutter run
```

## 构建

```bash
# Android（分别产出 armv7 / armv8 的 APK 到 dist/）
pwsh -File script/build-android.ps1 -Mode release

# 或手动构建
flutter build apk --release --split-per-abi --target-platform=android-arm,android-arm64
```

## 测试

```bash
flutter analyze
flutter test
```

测试覆盖：周期算法（`cycle_math_test`）、预测服务（`prediction_service_test`）、数据仓库（`record_repository_test`）、数据迁移（`data_transfer_service_test`）、持久化（`persistence_test`）等。

## 隐私说明

- 所有经期数据仅存本地 SQLite，不上传任何服务器，无第三方广告与追踪。
- 敏感密钥经系统安全存储（iOS Keychain / Android EncryptedSharedPreferences）保护。
- 应用提供数据导出（个人数据归属凭据）与一键删除全部数据入口。
