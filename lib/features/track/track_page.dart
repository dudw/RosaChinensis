import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../core/db/app_database.dart';
import '../../core/di/injection.dart';
import '../../core/i18n/format.dart';
import '../../core/theme/app_theme.dart';
import '../../data/current_user.dart';
import '../../data/repositories/record_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../prediction/cycle_math.dart' as cycle;
import '../../prediction/prediction_service.dart';
import 'track_category_config.dart';
import 'track_options.dart';

/// 跟踪页：单日视图 + 分类卡片（行经期血量 / 症状 / 指标 / 情绪 / 备注）。
///
/// 交互：无保存按钮，点选/再点选即为增删并自动保存；切换日期自动回显该日已有记录，
/// 支持指定 [initialDate] 打开（如从日历点击某一天）。
class TrackPage extends StatefulWidget {
  const TrackPage({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  State<TrackPage> createState() => _TrackPageState();
}

/// 性生活选项（标签 + 图标）。
class _SexOption {
  const _SexOption(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _TrackPageState extends State<TrackPage> {
  late DateTime _date;
  final Set<String> _symptoms = {};
  String? _mood;
  int? _flow;
  final Set<String> _sexTags = {};
  final _weightCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _loading = false;
  Timer? _metricDebounce;
  Timer? _noteDebounce;
  TrackCategoryConfig? _config;
  List<CategoryItem> _categories = [];
  Set<DateTime> _recordDates = {};

  RecordRepository get _repo => getIt<RecordRepository>();

  static const _symptomOptions = ['腹痛', '头痛', '疲劳', '乳房胀痛', '情绪波动', '失眠', '痘痘', '腰痛'];
  static const _moodOptions = ['开心', '平静', '低落', '烦躁', '焦虑', '敏感', '疲劳'];

  /// 性生活标签（「今天没性行为」与其他性行为标签互斥）。
  static const _noSexTag = '今天没性行为';
  static const _sexOptions = <_SexOption>[
    _SexOption('有保护措施性行为', Icons.umbrella_outlined),
    _SexOption('无保护措施性行为', Icons.umbrella),
    _SexOption('拔出射精', Icons.water_drop_outlined),
    _SexOption(_noSexTag, Icons.do_not_disturb_on_outlined),
    _SexOption('高潮', Icons.auto_awesome),
    _SexOption('没有高潮', Icons.trending_flat),
    _SexOption('性幻想', Icons.auto_awesome_mosaic),
    _SexOption('性交疼痛', Icons.bolt),
    _SexOption('性欲高涨', Icons.trending_up),
    _SexOption('性欲低落', Icons.trending_down),
    _SexOption('自慰', Icons.wb_sunny_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _date = cycle.dateOnly(widget.initialDate ?? DateTime.now());
    _loadConfig();
    _load();
    AppSettingsController.instance.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() async {
    await _loadConfig();
    if (mounted) _load();
  }

  Future<void> _loadConfig() async {
    _config = await TrackCategoryConfig.instance;
    if (mounted) setState(() => _categories = _config!.load());
  }

  @override
  void dispose() {
    AppSettingsController.instance.removeListener(_onSettingsChanged);
    _metricDebounce?.cancel();
    _noteDebounce?.cancel();
    _weightCtrl.dispose();
    _tempCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  /// 加载指定日期的全部记录并回显。
  Future<void> _load() async {
    _cancelDebounces();
    setState(() => _loading = true);
    final uid = await getIt<CurrentUser>().id();
    final d = _date;
    final now = DateTime.now();
    final results = await Future.wait([
      _repo.periodDaysByRange(uid, from: d, to: d),
      _repo.symptomsByRange(uid, from: d, to: d),
      _repo.moodsByRange(uid, from: d, to: d),
      _repo.metricsByRange(uid, from: d, to: d),
      _repo.sexByRange(uid, from: d, to: d),
      _repo.datesWithRecords(
        uid,
        from: DateTime(now.year - 10),
        to: now,
      ),
    ]);
    final periodDays = results[0] as List<PeriodDay>;
    final symptoms = results[1] as List<SymptomRecord>;
    final moods = results[2] as List<MoodRecord>;
    final metrics = results[3] as List<BodyMetric>;
    final sex = results[4] as List<SexRecord>;
    _recordDates = results[5] as Set<DateTime>;

    _flow = periodDays.isEmpty ? null : (periodDays.first.isPeriod ? periodDays.first.flowLevel : null);
    _noteCtrl.text = periodDays.isEmpty ? '' : (periodDays.first.note ?? '');
    _symptoms
      ..clear()
      ..addAll(symptoms.map((s) => s.symptomType));
    _mood = moods.isEmpty ? null : moods.first.moodType;
    _sexTags
      ..clear()
      ..addAll(sex.map((s) => s.tag));
    _weightCtrl.text = '';
    _tempCtrl.text = '';
    for (final m in metrics) {
      if (m.metricType == '体重') _weightCtrl.text = _numText(m.value);
      if (m.metricType == '体温') _tempCtrl.text = _numText(m.value);
    }
    if (mounted) setState(() => _loading = false);
  }

  String _numText(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  void _cancelDebounces() {
    _metricDebounce?.cancel();
    _noteDebounce?.cancel();
  }

  Future<int> _uid() => getIt<CurrentUser>().id();

  Future<void> _recompute(int uid) async {
    try {
      await getIt<PredictionService>().recompute(uid);
    } catch (_) {
      // 预测为侧效应，失败不阻断记录保存。
    }
  }

  /// 切换日期：更新选中并重新回显。
  Future<void> _setDate(DateTime d) async {
    final target = cycle.dateOnly(d);
    if (target == _date) return;
    setState(() => _date = target);
    await _load();
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final uid = await _uid();
    if (!mounted) return;
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (ctx) => _RecordDatePicker(
        initialDate: _date,
        firstDate: today.subtract(const Duration(days: 365 * 10)),
        lastDate: today,
        recordDates: _repo.datesWithRecords(
          uid,
          from: today.subtract(const Duration(days: 365 * 10)),
          to: today,
        ),
      ),
    );
    if (picked != null) await _setDate(picked);
  }

  // ── 各分类自动保存 ─────────────────────────────────────────────────────

  Future<void> _persistPeriodDay() async {
    final uid = await _uid();
    final d = cycle.dateOnly(_date);
    final noteText = _noteCtrl.text.trim();
    if (_flow == null && noteText.isEmpty) {
      await _repo.deletePeriodDay(userId: uid, date: d);
    } else {
      await _repo.upsertPeriodDay(
        userId: uid,
        date: d,
        isPeriod: _flow != null,
        flowLevel: _flow,
        note: noteText.isEmpty ? null : noteText,
      );
    }
    await _recompute(uid);
  }

  Future<void> _toggleFlow(int i) async {
    setState(() => _flow = (i == _flow ? null : i));
    await _persistPeriodDay();
  }

  Future<void> _toggleSymptom(String s) async {
    setState(() {
      _symptoms.contains(s) ? _symptoms.remove(s) : _symptoms.add(s);
    });
    final uid = await _uid();
    if (_symptoms.contains(s)) {
      await _repo.upsertSymptom(userId: uid, date: _date, symptomType: s);
    } else {
      await _repo.deleteSymptom(userId: uid, date: _date, symptomType: s);
    }
    await _recompute(uid);
  }

  Future<void> _toggleMood(String m) async {
    setState(() => _mood = (_mood == m ? null : m));
    final uid = await _uid();
    if (_mood == m) {
      await _repo.upsertMood(userId: uid, date: _date, moodType: m);
    } else {
      await _repo.deleteMood(userId: uid, date: _date, moodType: m);
    }
    await _recompute(uid);
  }

  Future<void> _toggleSex(String tag) async {
    setState(() {
      if (tag == _noSexTag) {
        // 选「今天没性行为」则清空其他性行为标签。
        if (_sexTags.contains(_noSexTag)) {
          _sexTags.remove(_noSexTag);
        } else {
          _sexTags
            ..clear()
            ..add(_noSexTag);
        }
      } else {
        // 选其他标签则移除「今天没性行为」。
        _sexTags.remove(_noSexTag);
        _sexTags.contains(tag) ? _sexTags.remove(tag) : _sexTags.add(tag);
      }
    });
    final uid = await _uid();
    await _repo.clearSexByDate(userId: uid, date: _date);
    for (final t in _sexTags) {
      await _repo.upsertSex(userId: uid, date: _date, tag: t);
    }
    await _recompute(uid);
  }

  void _onMetricChanged() {
    _metricDebounce?.cancel();
    _metricDebounce = Timer(const Duration(milliseconds: 500), _persistMetrics);
  }

  Future<void> _persistMetrics() async {
    final uid = await _uid();
    final d = cycle.dateOnly(_date);
    final w = double.tryParse(_weightCtrl.text.trim());
    final t = double.tryParse(_tempCtrl.text.trim());
    if (w == null) {
      await _repo.deleteBodyMetric(userId: uid, date: d, metricType: '体重');
    } else {
      await _repo.upsertBodyMetric(userId: uid, date: d, metricType: '体重', value: w);
    }
    if (t == null) {
      await _repo.deleteBodyMetric(userId: uid, date: d, metricType: '体温');
    } else {
      await _repo.upsertBodyMetric(userId: uid, date: d, metricType: '体温', value: t);
    }
    await _recompute(uid);
  }

  void _onNoteChanged() {
    _noteDebounce?.cancel();
    _noteDebounce = Timer(const Duration(milliseconds: 500), _persistPeriodDay);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onHorizontalDragEnd: (details) {
            // 左右滑动切换一周。
            final dx = details.primaryVelocity ?? 0;
            if (dx > 0) {
              _setDate(_date.subtract(const Duration(days: 7)));
            } else if (dx < 0) {
              _setDate(_date.add(const Duration(days: 7)));
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () =>
                    _setDate(_date.subtract(const Duration(days: 7))),
              ),
              TextButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(DateFormat.yMMMd(dateLocale(context)).format(_date)),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () =>
                    _setDate(_date.add(const Duration(days: 7))),
              ),
            ],
          ),
        ),
        actions: const [],
      ),
      body: Column(
        children: [
          // 顶部周条：点击可切换日期，左右滑动切换周，有记录的日期带小圆点。
          _WeekStrip(selected: _date, recordDates: _recordDates, onSelect: _setDate),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  ..._buildCategoryCards(),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      l10n.autoSaveHint,
                      style: t.textTheme.labelSmall
                          ?.copyWith(color: t.colorScheme.outline),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 按配置顺序构建已启用类别的卡片列表。
  List<Widget> _buildCategoryCards() {
    if (_categories.isEmpty) {
      // 配置未加载完成时，展示全部默认类别。
      return _allCards();
    }
    final cards = <Widget>[];
    final enabled = _categories.where((c) => c.enabled).toList();
    if (enabled.isEmpty) {
      return [
        const SizedBox(height: 40),
        Center(
          child: Text(
            AppLocalizations.of(context).allCategoriesOff,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ];
    }
    for (final item in enabled) {
      if (cards.isNotEmpty) cards.add(const SizedBox(height: 14));
      cards.add(_cardForCategory(item.category));
    }
    return cards;
  }

  Widget _cardForCategory(TrackCategory c) {
    switch (c) {
      case TrackCategory.period:
        return _FlowCard(
          selected: _flow,
          onSelect: _toggleFlow,
        );
      case TrackCategory.symptoms:
        return _SymptomCard(
          options: _symptomOptions,
          selected: _symptoms,
          onToggle: _toggleSymptom,
        );
      case TrackCategory.mood:
        return _MoodCard(
          options: _moodOptions,
          selected: _mood,
          onSelect: _toggleMood,
        );
      case TrackCategory.sex:
        return _SexCard(
          options: _sexOptions,
          noSexTag: _noSexTag,
          selected: _sexTags,
          onToggle: _toggleSex,
        );
      case TrackCategory.metrics:
        return _MetricCard(
          weightCtrl: _weightCtrl,
          tempCtrl: _tempCtrl,
          onChanged: _onMetricChanged,
        );
      case TrackCategory.note:
        return _NoteCard(controller: _noteCtrl, onChanged: _onNoteChanged);
    }
  }

  /// 配置未加载时的默认全部卡片。
  List<Widget> _allCards() => [
        _FlowCard(
          selected: _flow,
          onSelect: _toggleFlow,
        ),
        const SizedBox(height: 14),
        _SymptomCard(
          options: _symptomOptions,
          selected: _symptoms,
          onToggle: _toggleSymptom,
        ),
        const SizedBox(height: 14),
        _MoodCard(
          options: _moodOptions,
          selected: _mood,
          onSelect: _toggleMood,
        ),
        const SizedBox(height: 14),
        _SexCard(
          options: _sexOptions,
          noSexTag: _noSexTag,
          selected: _sexTags,
          onToggle: _toggleSex,
        ),
        const SizedBox(height: 14),
        _MetricCard(
          weightCtrl: _weightCtrl,
          tempCtrl: _tempCtrl,
          onChanged: _onMetricChanged,
        ),
        const SizedBox(height: 14),
        _NoteCard(controller: _noteCtrl, onChanged: _onNoteChanged),
      ];
}

class _WeekStrip extends StatefulWidget {
  const _WeekStrip({required this.selected, required this.recordDates, required this.onSelect});
  final DateTime selected;
  final Set<DateTime> recordDates;
  final ValueChanged<DateTime> onSelect;

  @override
  State<_WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<_WeekStrip> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    // 以 2000-01-03（周一）为第 0 周，计算当前选中日期所在周的页码。
    _controller = PageController(initialPage: _weekIndex(widget.selected));
  }

  @override
  void didUpdateWidget(covariant _WeekStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    final idx = _weekIndex(widget.selected);
    if (idx != _controller.page?.round()) {
      _controller.animateToPage(
        idx,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 以 2000-01-03（周一）为第 0 周的索引。
  static final DateTime _epoch = DateTime(2000, 1, 3);
  static int _weekIndex(DateTime d) {
    final monday = d.subtract(Duration(days: (d.weekday - 1) % 7));
    return monday.difference(_epoch).inDays ~/ 7;
  }

  static DateTime _mondayOf(int weekIndex) =>
      _epoch.add(Duration(days: weekIndex * 7));

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: PageView.builder(
        controller: _controller,
        itemBuilder: (context, index) {
          final monday = _mondayOf(index);
          return _buildWeek(monday);
        },
      ),
    );
  }

  Widget _buildWeek(DateTime monday) {
    final t = Theme.of(context);
    final today = cycle.dateOnly(DateTime.now());
    final labels = weekdayShortLabels(context);
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: _DayDot(
              date: monday.add(Duration(days: i)),
              selected: widget.selected,
              today: today,
              hasRecord: widget.recordDates.contains(
                  cycle.dateOnly(monday.add(Duration(days: i)))),
              onSelect: widget.onSelect,
              weekdayLabel: labels[i],
              colorScheme: t.colorScheme,
              brandColor: AppColors.brand,
            ),
          ),
      ],
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.date,
    required this.selected,
    required this.today,
    required this.hasRecord,
    required this.onSelect,
    required this.weekdayLabel,
    required this.colorScheme,
    required this.brandColor,
  });
  final DateTime date;
  final DateTime selected;
  final DateTime today;
  final bool hasRecord;
  final ValueChanged<DateTime> onSelect;
  final String weekdayLabel;
  final ColorScheme colorScheme;
  final Color brandColor;

  @override
  Widget build(BuildContext context) {
    final d = cycle.dateOnly(date);
    final isSelected = d == cycle.dateOnly(selected);
    final isToday = d == today;
    final isFuture = d.isAfter(today);

    return InkWell(
      onTap: isFuture ? null : () => onSelect(d),
      borderRadius: BorderRadius.circular(10),
      child: Opacity(
        opacity: isFuture ? 0.35 : 1.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(weekdayLabel,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                )),
            const SizedBox(height: 3),
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? colorScheme.primary : Colors.transparent,
                border: isToday && !isSelected
                    ? Border.all(color: brandColor, width: 1.5)
                    : null,
                boxShadow: isSelected
                    ? AppShadows.accent(
                        Theme.of(context).brightness,
                        brandColor,
                      )
                    : null,
              ),
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                  fontWeight: isSelected || isToday
                      ? FontWeight.w700
                      : null,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 2),
            // 有记录的日期显示小圆点
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: hasRecord
                    ? (isSelected ? colorScheme.onPrimary : brandColor)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 行经期血量卡片。
class _FlowCard extends StatelessWidget {
  const _FlowCard({required this.selected, required this.onSelect});
  final int? selected;
  final ValueChanged<int> onSelect;

  static const _icons = [Icons.water_drop_outlined, Icons.water_drop, Icons.water_drop, Icons.water_damage_outlined];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n.flowLight,
      l10n.flowMedium,
      l10n.flowHeavy,
      l10n.flowVeryHeavy,
    ];
    return _Section(
      title: l10n.categoryPeriod,
      accentColor: AppColors.danger,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: _IconTile(
                label: labels[i],
                icon: _icons[i],
                selected: selected == i,
                color: AppColors.danger,
                onTap: () => onSelect(i),
              ),
            ),
        ],
      ),
    );
  }
}

/// 症状多选卡片。
class _SymptomCard extends StatelessWidget {
  const _SymptomCard({required this.options, required this.selected, required this.onToggle});
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Section(
      title: l10n.categorySymptoms,
      accentColor: AppColors.amber,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final o in options)
            _ChipTile(
              label: symptomLabel(l10n, o),
              selected: selected.contains(o),
              color: AppColors.amber,
              onTap: () => onToggle(o),
            ),
        ],
      ),
    );
  }
}

/// 情绪单选卡片。
class _MoodCard extends StatelessWidget {
  const _MoodCard({required this.options, required this.selected, required this.onSelect});
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  static const _emojis = ['😊', '😐', '😞', '😤', '😰', '🥺', '😴'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Section(
      title: l10n.categoryMood,
      accentColor: AppColors.teal,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var i = 0; i < options.length; i++)
            _ChipTile(
              emoji: _emojis[i],
              label: moodLabel(l10n, options[i]),
              selected: selected == options[i],
              color: AppColors.teal,
              onTap: () => onSelect(options[i]),
            ),
        ],
      ),
    );
  }
}

/// 性生活卡片（方形图标宫格，标签多选）。
class _SexCard extends StatelessWidget {
  const _SexCard({
    required this.options,
    required this.noSexTag,
    required this.selected,
    required this.onToggle,
  });
  final List<_SexOption> options;
  final String noSexTag;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Section(
      title: l10n.categorySex,
      accentColor: AppColors.teal,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final o in options)
            SizedBox(
              width: 88,
              child: _IconTile(
                label: sexLabel(l10n, o.label),
                icon: o.icon,
                selected: selected.contains(o.label),
                color: AppColors.teal,
                onTap: () => onToggle(o.label),
              ),
            ),
        ],
      ),
    );
  }
}

/// 身体指标卡片。
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.weightCtrl,
    required this.tempCtrl,
    required this.onChanged,
  });
  final TextEditingController weightCtrl;
  final TextEditingController tempCtrl;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Section(
      title: l10n.categoryMetrics,
      accentColor: AppColors.brand,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: weightCtrl,
              onChanged: (_) => onChanged(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.weightKg,
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: tempCtrl,
              onChanged: (_) => onChanged(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.tempC,
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 每天备注卡片。
class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Section(
      title: l10n.categoryNote,
      accentColor: AppColors.brand,
      child: TextField(
        controller: controller,
        onChanged: (_) => onChanged(),
        maxLines: 3,
        decoration: InputDecoration(
          hintText: l10n.noteHint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.accentColor});
  final String title;
  final Widget child;

  /// 分类语义色，画在卡片左侧 4px 色条上。null = 无色条。
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(
          color: t.brightness == Brightness.dark
              ? Colors.white12
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      // 裁掉色条超出圆角的部分。
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        // IntrinsicHeight 是必须的：本卡片位于 ListView（高度无界）中，
        // Row 的 stretch 在无界高度下会把子项撑成无限高，
        // 导致 SliverList 无法布局后续卡片（只剩第一张可见）。
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (accentColor != null)
              Container(width: 4, color: accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: t.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    child,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 带图标的正方形选项（行经期血量用）。
class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? color : t.colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(14),
            color: selected ? t.brightness.softBg(color, lightAlpha: 0.12, darkAlpha: 0.22) : null,
            boxShadow: selected ? AppShadows.accent(t.brightness, color) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? color : t.colorScheme.outline, size: 22),
              const SizedBox(height: 4),
              // maxLines 防止长标签（如英文多行换行）撑爆固定高格子。
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? color : null,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 小尺寸 Chip 选项（症状/情绪用）。
class _ChipTile extends StatelessWidget {
  const _ChipTile({
    required this.label,
    this.emoji,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final String? emoji;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? color : t.colorScheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
          color: selected ? t.brightness.softBg(color, lightAlpha: 0.12, darkAlpha: 0.22) : null,
          boxShadow: selected ? AppShadows.accent(t.brightness, color) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
            ],
            Text(label,
                style: TextStyle(
                  color: selected ? color : null,
                  fontSize: 13,
                )),
          ],
        ),
      ),
    );
  }
}

/// 自定义日期选择弹窗：月历视图，有记录的日期下方显示小圆点。
/// 未来日期禁用，支持月份翻页与年份快速跳转。
class _RecordDatePicker extends StatefulWidget {
  const _RecordDatePicker({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.recordDates,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Future<Set<DateTime>> recordDates;

  @override
  State<_RecordDatePicker> createState() => _RecordDatePickerState();
}

class _RecordDatePickerState extends State<_RecordDatePicker> {
  late DateTime _displayedMonth;
  late DateTime _selected;
  Set<DateTime> _recordDates = {};

  @override
  void initState() {
    super.initState();
    _selected = cycle.dateOnly(widget.initialDate);
    _displayedMonth = DateTime(_selected.year, _selected.month, 1);
    _loadRecordDates();
  }

  Future<void> _loadRecordDates() async {
    try {
      _recordDates = await widget.recordDates;
    } catch (_) {
      _recordDates = {};
    }
    if (mounted) setState(() {});
  }

  bool _isEnabled(DateTime day) {
    final d = cycle.dateOnly(day);
    return !d.isAfter(cycle.dateOnly(widget.lastDate)) &&
        !d.isBefore(cycle.dateOnly(widget.firstDate));
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    final next = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    if (!next.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month, 1))) {
      setState(() => _displayedMonth = next);
    }
  }

  Future<void> _pickYear() async {
    final now = DateTime.now();
    final picked = await showDialog<int>(
      context: context,
      builder: (ctx) {
        final years = List.generate(
          now.year - widget.firstDate.year + 1,
          (i) => now.year - i,
        );
        return SimpleDialog(
          title: Text(AppLocalizations.of(context).chooseYear),
          children: [
            SizedBox(
              width: 320,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.2,
                ),
                itemCount: years.length,
                itemBuilder: (_, i) {
                  final y = years[i];
                  final isCurrent = y == _displayedMonth.year;
                  return InkWell(
                    onTap: () => Navigator.pop(ctx, y),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Theme.of(ctx).colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isCurrent
                            ? null
                            : Border.all(
                                color: Theme.of(ctx)
                                    .colorScheme
                                    .outlineVariant),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$y',
                        style: TextStyle(
                          color: isCurrent
                              ? Theme.of(ctx).colorScheme.onPrimary
                              : null,
                          fontWeight:
                              isCurrent ? FontWeight.w700 : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
    if (picked != null) {
      setState(() => _displayedMonth = DateTime(picked, _displayedMonth.month, 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final firstWeekday =
        (DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday - 1) % 7;
    final today = cycle.dateOnly(DateTime.now());

    final cells = <DateTime?>[];
    for (var i = 0; i < firstWeekday; i++) {
      cells.add(null);
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_displayedMonth.year, _displayedMonth.month, d));
    }

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部：月份导航
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _prevMonth,
                ),
                Expanded(
                  child: InkWell(
                    onTap: _pickYear,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat.yMMMM(dateLocale(context)).format(_displayedMonth),
                            style: t.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down,
                              size: 20, color: t.colorScheme.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 星期表头
            Row(
              children: [
                for (final l in weekdayShortLabels(context))
                  Expanded(
                    child: Center(
                      child: Text(l,
                          style: t.textTheme.labelSmall
                              ?.copyWith(color: t.colorScheme.outline)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // 日期网格
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 7,
              childAspectRatio: 0.9,
              children: [
                for (final day in cells)
                  if (day == null)
                    const SizedBox.shrink()
                  else
                    _buildDayCell(day, today, t),
              ],
            ),
            const SizedBox(height: 12),
            // 底部：取消 / 确定
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context).cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, _selected),
                  child: Text(AppLocalizations.of(context).confirm),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime day, DateTime today, ThemeData t) {
    final d = cycle.dateOnly(day);
    final enabled = _isEnabled(d);
    final isSelected = d == _selected;
    final isToday = d == today;
    final hasRecord = _recordDates.contains(d);

    return InkWell(
      onTap: enabled
          ? () => setState(() => _selected = d)
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? t.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: AppColors.brand, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: !enabled
                    ? t.colorScheme.outlineVariant
                    : isSelected
                        ? t.colorScheme.onPrimary
                        : null,
                fontWeight: isSelected || isToday ? FontWeight.w700 : null,
              ),
            ),
            const SizedBox(height: 2),
            // 有记录的日期显示小圆点
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: hasRecord
                    ? (isSelected ? t.colorScheme.onPrimary : AppColors.brand)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}