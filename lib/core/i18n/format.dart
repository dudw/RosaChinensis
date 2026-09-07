import 'package:flutter/widgets.dart';

/// 当前 UI 语言对应的日期格式化 locale（DateFormat 使用）。
String dateLocale(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'zh' ? 'zh_CN' : 'en_US';

/// 星期短标签（周一开头），日历 / 跟踪周条共用。
List<String> weekdayShortLabels(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'zh'
        ? const ['一', '二', '三', '四', '五', '六', '日']
        : const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
