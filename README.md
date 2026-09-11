# 月季（period_tracker）

一款**本地优先**的经期记录与周期预测 App，全功能免费、无广告、无内购。基于 Flutter 构建，支持 Android / iOS。

> 核心定位：面向女性用户的经期记录 + 智能预测工具 —— 科学记录、隐私第一。

- 当前版本：`1.0.3+4`
- 数据全程仅存本地 SQLite，无云端上传、无第三方追踪

## 功能特性

- **今日**：大圆环周期指示器，一眼掌握当前生理阶段与距下次经期天数；点击圆环锚点可查看未来任一天的阶段。
- **日历**：垂直滚动月视图，经期（实心红）、预测经期（浅红）、排卵日（琥珀）、易孕期（青绿）、性生活记录（青点）多维标记；点击标题可弹出年月选择器快速跳转（上限为当月，有记录的月份带圆点提示）。
- **跟踪记录**：分类卡片式录入，覆盖经期流量、症状、情绪、性生活、身体指标（体重 / 体温）、备注六类，支持强度分级与类别自定义。
- **智能预测**：自适应加权平均算法（近期权重更高、自动剔除异常值，非固定 28 天），预测下期经期、排卵日与易孕期，并展示置信区间与免责声明。
- **统计分析**：记录概览、平均周期 / 平均经期（近 6 周期口径）、周期长度趋势、症状频率与情绪分布、体重 / 体温折线图。
- **数据导入导出**：JSON 全量导出到文件；导入前 schema 校验，单事务内按唯一键合并去重（默认不覆盖本地数据）。
- **自动备份**：可指定备份目录（Android 走 SAF 授权），退出时静默导出 JSON，按日期命名保留最新一份。
- **隐私安全**：本地 SQLite 存储 + 系统安全存储（Keychain / EncryptedSharedPreferences）保护密钥，无第三方广告与统计。
- **国际化**：中 / 英双语，跟随系统深色模式。

## 技术栈

| 层 | 技术 |
|----|------|
| UI 框架 | Flutter（Dart SDK `^3.12.1`） |
| 本地数据库 | drift（SQLite） |
| 加密存储 | flutter_secure_storage |
| 依赖注入 | get_it |
| 状态管理 | ChangeNotifier + 全局单例控制器 |
| 本地化 | flutter_localizations + intl（arb） |
| 键值存储 | shared_preferences（UI 偏好） |
| 文件 / 分享 | file_selector、share_plus |
| 目标平台 | Android（armv7 / armv8）、iOS |

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
│   ├── current_user.dart             # 本地单用户标识
│   ├── data_transfer_service.dart    # JSON 导入导出 + 合并去重
│   └── auto_backup_controller.dart   # 自动备份
├── prediction/                  # 周期预测引擎（独立可测试模块）
│   ├── cycle_math.dart          # 加权平均、异常值剔除等算法
│   └── prediction_service.dart  # 预测编排与写库
├── features/                    # 业务页面
│   ├── today/                   # 今日（周期圆环）
│   ├── calendar/                # 日历
│   ├── track/                   # 跟踪记录 + 类别配置
│   ├── stats/                   # 统计分析
│   ├── settings/                # 设置与周期个性化
│   ├── privacy/                 # 隐私说明
│   ├── record/                  # 记录向导（预留）
│   └── account/                 # 本地账号信息（预留）
└── l10n/                        # 本地化资源（zh / en）
```

### 数据模型

drift 表（`schemaVersion` 见 [app_database.dart](lib/core/db/app_database.dart)，当前为 2）：

| 表 | 说明 | 唯一键 |
|----|------|--------|
| `Users` | 用户周期基准配置 | `id` |
| `PeriodDays` | 经期日记录（含流量等级） | `(userId, date)` |
| `SymptomRecords` | 症状记录 | `(userId, date, symptomType)` |
| `BodyMetrics` | 身体指标（体重 / 体温） | `(userId, date, metricType)` |
| `MoodRecords` | 情绪记录 | `(userId, date, moodType)` |
| `SexRecords` | 性生活标签 | `(userId, date, tag)` |
| `PredictionSnapshots` | 预测快照（仅缓存展示） | `(userId, predictedEvent, predictedDate)` |

## 快速开始

前置要求：安装 [Flutter SDK](https://docs.flutter.dev/get-started/install)（3.47.2，含 Dart SDK `^3.12.1`）。

```bash
# 1. 安装依赖
flutter pub get

# 2. 生成 drift / l10n 代码（表结构或 arb 变更后需重跑）
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n

# 3. 运行（选择目标设备）
flutter run
```

> 签名材料与 PRD 位于 `rosa_file` 子模块，构建 release 包前需先初始化：
> `git submodule update --init`

## 构建与发布

```bash
# 方式一：使用构建脚本（分别产出 armv7 / armv8 的 APK）
pwsh -File script/build-android.ps1 -Mode release
# 指定输出目录
pwsh -File script/build-android.ps1 -Mode release -Output D:\releases

# 方式二：手动构建
flutter build apk --release --split-per-abi --target-platform=android-arm,android-arm64
```

**CI 自动发布**：推送形如 `v*` 的 tag 会触发 [release.yml](.github/workflows/release.yml)，自动构建 armv7 / armv8 两个 APK 并创建 GitHub Release。

```bash
git tag -a v1.0.3 -m "release: 1.0.3"
git push origin main --follow-tags
```

## 测试

```bash
flutter analyze
flutter test
```

测试覆盖：

| 文件 | 范围 |
|------|------|
| `cycle_math_test` | 周期长度计算、加权平均、异常值剔除 |
| `prediction_service_test` | 预测编排与输出 |
| `record_repository_test` | 数据仓库读写与唯一键合并 |
| `data_transfer_service_test` | JSON 导入导出与 schema 校验 |
| `persistence_test` | drift 持久化与迁移 |
| `track_page_test` | 跟踪页类别渲染回归 |
| `widget_test` | 应用冒烟测试 |

## 隐私说明

- 所有经期数据仅存本地 SQLite，不上传任何服务器，无第三方广告与追踪。
- 敏感密钥经系统安全存储（iOS Keychain / Android EncryptedSharedPreferences）保护。
- 应用提供数据导出（个人数据归属凭据）与一键删除全部数据入口。

## 许可证

本项目基于 [Apache License 2.0](LICENSE) 开源。
