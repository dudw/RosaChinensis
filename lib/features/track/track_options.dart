import '../../l10n/app_localizations.dart';

/// 跟踪选项的「规范化存储值 → 本地化显示」映射。
///
/// 数据库存储值保持中文规范串（既有数据无需迁移），仅显示时按语言翻译。
/// 未知值原样返回，保证向前兼容（如用户自定义 / 旧数据）。

String symptomLabel(AppLocalizations l10n, String canonical) =>
    switch (canonical) {
      '腹痛' => l10n.symptomAbdominalPain,
      '头痛' => l10n.symptomHeadache,
      '疲劳' => l10n.symptomFatigue,
      '乳房胀痛' => l10n.symptomBreastTenderness,
      '情绪波动' => l10n.symptomMoodSwings,
      '失眠' => l10n.symptomInsomnia,
      '痘痘' => l10n.symptomAcne,
      '腰痛' => l10n.symptomLowerBackPain,
      _ => canonical,
    };

String moodLabel(AppLocalizations l10n, String canonical) =>
    switch (canonical) {
      '开心' => l10n.moodHappy,
      '平静' => l10n.moodCalm,
      '低落' => l10n.moodLow,
      '烦躁' => l10n.moodIrritable,
      '焦虑' => l10n.moodAnxious,
      '敏感' => l10n.moodSensitive,
      '疲劳' => l10n.moodTired,
      _ => canonical,
    };

String sexLabel(AppLocalizations l10n, String canonical) =>
    switch (canonical) {
      '有保护措施性行为' => l10n.sexProtected,
      '无保护措施性行为' => l10n.sexUnprotected,
      '拔出射精' => l10n.sexWithdrawal,
      '今天没性行为' => l10n.sexNoSex,
      '高潮' => l10n.sexOrgasm,
      '没有高潮' => l10n.sexNoOrgasm,
      '性幻想' => l10n.sexFantasy,
      '性交疼痛' => l10n.sexPainfulSex,
      '性欲高涨' => l10n.sexHighLibido,
      '性欲低落' => l10n.sexLowLibido,
      '自慰' => l10n.sexMasturbation,
      _ => canonical,
    };

String metricLabel(AppLocalizations l10n, String canonical) =>
    switch (canonical) {
      '体重' => l10n.metricWeight,
      '体温' => l10n.metricTemperature,
      _ => canonical,
    };
