// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '月季';

  @override
  String get tabToday => '今日';

  @override
  String get tabCalendar => '日历';

  @override
  String get tabTrack => '跟踪';

  @override
  String get tabStats => '分析';

  @override
  String get tabMore => '更多';

  @override
  String loadFailed(String error) {
    return '加载失败：$error';
  }

  @override
  String get cancel => '取消';

  @override
  String get close => '关闭';

  @override
  String get ok => '好的';

  @override
  String get delete => '删除';

  @override
  String get import => '导入';

  @override
  String get save => '保存';

  @override
  String get nextStep => '下一步';

  @override
  String get prevStep => '上一步';

  @override
  String get confirm => '确定';

  @override
  String get currentCycleTitle => '当前生理周期';

  @override
  String get howAreYouToday => '你今天感觉如何？';

  @override
  String periodDayN(int n) {
    return '经期 · 第 $n 天';
  }

  @override
  String get yourNextPeriodIs => '你的下次经期是在';

  @override
  String get daysUntilNextPeriod => '距离你的下次经期还有';

  @override
  String get possibleFertileDays => '可能的受孕日';

  @override
  String daysCount(int n) {
    return '$n 天';
  }

  @override
  String get backToTodayHint => '点击圆环空白处回到今日';

  @override
  String get dayUnitShort => '天';

  @override
  String get predictedChip => '预测态';

  @override
  String get confirmedChip => '已确认';

  @override
  String predictedPeriodSubtitle(int n) {
    return '距上次预测区间 ±$n 天（预测态）';
  }

  @override
  String get ovulationSubtitle => '今天是最佳受孕窗口中心（预测态）';

  @override
  String get fertileWindowSubtitleToday => '预计排卵 就在今天';

  @override
  String fertileWindowSubtitleInDays(int n) {
    return '预计排卵 还有 $n 天';
  }

  @override
  String normalSubtitle(int n) {
    return '距下期预测 $n 天';
  }

  @override
  String get fertileWindowLabel => '受孕期';

  @override
  String get predictedOvulationLabel => '预测排卵日';

  @override
  String get fertileDisclaimer => '受孕期是指排卵前和包括可能排卵日在内的天数。它只是一个估计，不应该用于避孕或尝试怀孕。';

  @override
  String get prevMonth => '上月';

  @override
  String get nextMonth => '下月';

  @override
  String get backToToday => '回到今天';

  @override
  String get legendPeriod => '经期';

  @override
  String get legendPredictedPeriod => '预测经期';

  @override
  String get legendFertileWindow => '易孕期';

  @override
  String get legendOvulation => '排卵日';

  @override
  String get categoryPeriod => '行经期';

  @override
  String get categorySymptoms => '症状';

  @override
  String get categoryMood => '情绪';

  @override
  String get categorySex => '性生活';

  @override
  String get categoryMetrics => '身体指标';

  @override
  String get categoryNote => '每天备注';

  @override
  String get categoryFilter => '类别筛选';

  @override
  String get categoryFilterHint => '打开或关闭类别，过滤你的视图。按住并拖动类别可重新排列顺序。';

  @override
  String get allCategories => '所有类别';

  @override
  String get flowLight => '少量';

  @override
  String get flowMedium => '中等';

  @override
  String get flowHeavy => '大量';

  @override
  String get flowVeryHeavy => '超大量';

  @override
  String get symptomAbdominalPain => '腹痛';

  @override
  String get symptomHeadache => '头痛';

  @override
  String get symptomFatigue => '疲劳';

  @override
  String get symptomBreastTenderness => '乳房胀痛';

  @override
  String get symptomMoodSwings => '情绪波动';

  @override
  String get symptomInsomnia => '失眠';

  @override
  String get symptomAcne => '痘痘';

  @override
  String get symptomLowerBackPain => '腰痛';

  @override
  String get moodHappy => '开心';

  @override
  String get moodCalm => '平静';

  @override
  String get moodLow => '低落';

  @override
  String get moodIrritable => '烦躁';

  @override
  String get moodAnxious => '焦虑';

  @override
  String get moodSensitive => '敏感';

  @override
  String get moodTired => '疲劳';

  @override
  String get sexProtected => '有保护措施性行为';

  @override
  String get sexUnprotected => '无保护措施性行为';

  @override
  String get sexWithdrawal => '拔出射精';

  @override
  String get sexNoSex => '今天没性行为';

  @override
  String get sexOrgasm => '高潮';

  @override
  String get sexNoOrgasm => '没有高潮';

  @override
  String get sexFantasy => '性幻想';

  @override
  String get sexPainfulSex => '性交疼痛';

  @override
  String get sexHighLibido => '性欲高涨';

  @override
  String get sexLowLibido => '性欲低落';

  @override
  String get sexMasturbation => '自慰';

  @override
  String get metricWeight => '体重';

  @override
  String get metricTemperature => '体温';

  @override
  String get weightKg => '体重 kg';

  @override
  String get tempC => '体温 ℃';

  @override
  String get noteHint => '今天还有其他细节要补充吗？';

  @override
  String get autoSaveHint => '改动即时保存';

  @override
  String get allCategoriesOff => '所有类别已关闭，点击右上角筛选图标开启';

  @override
  String get chooseYear => '选择年份';

  @override
  String get statsTitle => '统计';

  @override
  String get last6Cycles => '近 6 周期';

  @override
  String get avgCycle => '平均周期';

  @override
  String get avgPeriod => '平均经期';

  @override
  String get dayUnit => '天';

  @override
  String get cycleLengthTrend => '周期长度趋势';

  @override
  String get statsHint => '说明：数据越多预测越准，建议记录完整周期。';

  @override
  String get statsEmpty => '记录 1~2 个完整周期后可查看趋势';

  @override
  String get statsOverview => '记录概览';

  @override
  String get trackedDays => '记录天数';

  @override
  String get periodDays => '经期天数';

  @override
  String get symptomDays => '症状天数';

  @override
  String get moodDays => '情绪天数';

  @override
  String get sexDays => '性生活天数';

  @override
  String get metricDays => '指标天数';

  @override
  String get symptomFrequency => '症状频率';

  @override
  String get moodDistribution => '情绪分布';

  @override
  String get weightTrend => '体重趋势';

  @override
  String get tempTrend => '体温趋势';

  @override
  String get noTrackingData => '暂无数据';

  @override
  String metricRangeStats(String min, String max, String avg) {
    return '最低 $min · 最高 $max · 平均 $avg';
  }

  @override
  String get appearance => '外观模式';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色模式';

  @override
  String get themeDark => '深色模式';

  @override
  String get customizeTracking => '自定义跟踪';

  @override
  String get customizeTrackingSubtitle => '设置类别开关与顺序';

  @override
  String get cyclePersonalization => '生理周期个人化';

  @override
  String get cyclePersonalizationSubtitle => '排卵 / 受孕期显示开关';

  @override
  String get importData => '导入数据';

  @override
  String get importDataSubtitle => 'JSON 合并去重';

  @override
  String get autoBackup => '自动备份';

  @override
  String get autoBackupSubtitle => '每次退出 App 时静默导出 JSON';

  @override
  String get backupDir => '备份目录';

  @override
  String get backupDirNotSelected => '未选择（点击选择目录并授权）';

  @override
  String get backupNow => '立即备份一次';

  @override
  String get exportJson => '导出 JSON';

  @override
  String get exportJsonSubtitle => '全量数据 → 剪贴板';

  @override
  String get clearAllData => '清除全部数据';

  @override
  String get privacyPolicy => '隐私说明';

  @override
  String get privacyPolicySubtitle => '本地优先存储 · 可随时导出/删除';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageZh => '简体中文';

  @override
  String get languageEn => 'English';

  @override
  String exportFailed(String error) {
    return '导出失败：$error';
  }

  @override
  String exportSaved(String label) {
    return '$label 已保存';
  }

  @override
  String exportSavedCount(String count) {
    return '共 $count';
  }

  @override
  String get exportCopyHint => '如需发送给别人，可复制内容。';

  @override
  String get shareSaveToSystem => '分享 / 保存到系统';

  @override
  String get copyContent => '复制内容';

  @override
  String get copiedToClipboard => '内容已复制到剪贴板';

  @override
  String exportShareText(String label) {
    return '经期记录数据导出（$label）';
  }

  @override
  String get importFromFile => '选择文件导入';

  @override
  String get importFromFileSubtitle => '选择本地 .json 导出文件';

  @override
  String get pasteJson => '粘贴 JSON';

  @override
  String get pasteJsonSubtitle => '从剪贴板或手动粘贴';

  @override
  String importFailed(String error) {
    return '导入失败：$error';
  }

  @override
  String get importErrorJsonParse => 'JSON 解析失败，请粘贴正确的导出文件';

  @override
  String get importErrorInvalidJson => 'JSON 格式不正确';

  @override
  String importErrorSchemaMismatch(String imported, String current) {
    return 'schema 版本不匹配：导入为 $imported，当前为 $current';
  }

  @override
  String get importErrorMissingData => '缺少 data 根节点';

  @override
  String get importErrorInvalidDate => '日期字段无法解析';

  @override
  String get importDedupeHint => '按唯一键合并去重，已存在的记录不会被覆盖。';

  @override
  String get pasteJsonHint => '粘贴 JSON…';

  @override
  String get importDone => '导入完成';

  @override
  String importSummary(int inserted, int skipped) {
    return '新增 $inserted 条 · 跳过 $skipped 条';
  }

  @override
  String addedCount(int n) {
    return '新增 $n';
  }

  @override
  String skippedCount(int n) {
    return '跳过 $n';
  }

  @override
  String get importSkippedHint => '跳过 = 本地已有相同唯一键，予以保留不覆盖。';

  @override
  String backupFailed(String error) {
    return '备份失败：$error';
  }

  @override
  String get unknownError => '未知错误';

  @override
  String get backupDone => '备份完成';

  @override
  String get backupShareText => '经期记录备份';

  @override
  String get shareSaveAs => '分享 / 另存';

  @override
  String get clearAllConfirmTitle => '清除全部数据？';

  @override
  String get clearAllConfirmBody => '将删除本机所有经期记录、症状、情绪与预测数据，且不可恢复。';

  @override
  String get clearedAllData => '已清除全部数据';

  @override
  String get tablePeriodDays => '经期记录';

  @override
  String get tableSymptoms => '症状';

  @override
  String get tableBodyMetrics => '身体指标';

  @override
  String get tableMoods => '情绪';

  @override
  String get tablePredictions => '预测快照';

  @override
  String charsCount(int n) {
    return '$n 字符';
  }

  @override
  String get displaySection => '显示';

  @override
  String get showOvulation => '显示排卵';

  @override
  String get showFertileWindow => '显示受孕期';

  @override
  String get restoreDefault => '恢复默认';

  @override
  String get recordTitle => '记录';

  @override
  String get recordDate => '记录日期';

  @override
  String get stepPeriod => '经期';

  @override
  String get stepFlow => '流量';

  @override
  String get stepSymptoms => '症状';

  @override
  String get stepMetrics => '指标';

  @override
  String get stepMood => '情绪';

  @override
  String get stepPeriodHint => '这一天是否处于经期？';

  @override
  String get stepFlowHint => '当天的出血量？';

  @override
  String get stepSymptomsHint => '当天有哪些症状？';

  @override
  String get stepMetricsHint => '身体指标（可选）';

  @override
  String get stepMoodHint => '当天的心情？';

  @override
  String get yesPeriodToday => '是，今天来经期';

  @override
  String get no => '否';

  @override
  String get weightKgOptional => '体重（kg，可选）';

  @override
  String get tempCOptional => '基础体温（℃，可选）';

  @override
  String get recordSaved => '记录已保存';

  @override
  String get recordFlowSpotting => '点滴';

  @override
  String get recordFlowLight => '轻';

  @override
  String get recordFlowMedium => '中';

  @override
  String get recordFlowHeavy => '多';

  @override
  String get accountTitle => '同步与账号';

  @override
  String get currentMode => '当前模式';

  @override
  String get localFreeMode => '本地模式 · 全功能免费';

  @override
  String get accountId => '账号标识';

  @override
  String anonymousUser(String id) {
    return '匿名用户 #$id';
  }

  @override
  String get noLoginRequired => '不要求登录';

  @override
  String get accountPrivacyBody =>
      '出于隐私优先考量，本版本不进行云端同步。所有经期、症状、情绪与预测数据仅保存在本设备。如需迁移到其他设备，使用「导出 JSON」后在目标设备通过「导入数据」合并即可。';

  @override
  String get accountMigrateHint => '需要迁移时，返回「更多」页使用「导出 / 导入」即可。';

  @override
  String get privacyTitle => '隐私说明';

  @override
  String get privacyLocalTitle => '本地优先存储';

  @override
  String get privacyLocalBody =>
      '全部经期、症状、情绪与预测数据仅保存在本设备数据库中，不经过网络上传，无广告追踪与第三方共享。';

  @override
  String get privacyEncryptedTitle => '加密存储';

  @override
  String get privacyEncryptedBody =>
      '数据库在正式版本通过系统安全存储（iOS Keychain / Android Keystore）持有密钥启用的加密方案保护；日常数据仅在设备内解密。';

  @override
  String get privacyClearTitle => '可控清除';

  @override
  String get privacyClearBody => '可在「清除全部数据」中永久删除本机全部记录；清除不可恢复，请先导出备份。';

  @override
  String get privacyMigrateTitle => '随时迁移';

  @override
  String get privacyMigrateBody => '支持导出为 JSON 并保存或分享到系统，换机时在新设备导入即可合并去重恢复。';

  @override
  String placeholderModule(String title) {
    return '「$title」模块将在对应 Stage 实现';
  }
}
