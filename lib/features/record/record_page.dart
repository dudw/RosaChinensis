import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/injection.dart';
import '../../core/i18n/format.dart';
import '../../data/current_user.dart';
import '../../data/repositories/record_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../prediction/prediction_service.dart';
import '../track/track_options.dart';

/// 记录向导（PRD 7.4 / 20 章）：经期 → 流量 → 症状 → 指标 → 情绪。
/// 支持回填日期与可选身体指标（体重/体温）；提交后写库并触发预测重算。
class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  int _step = 0;
  bool _isPeriod = true;
  int? _flow;
  final Set<String> _symptoms = {};
  String? _mood;
  bool _saving = false;

  // 回填日期（默认今天，可改为过去某天）。
  late DateTime _date;

  // 身体指标（可选）：体重 kg / 体温 ℃。
  final _weightCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();

  static const _stepCount = 5;
  static const _symptomOptions = ['腹痛', '头痛', '疲劳', '乳房胀痛', '情绪波动', '失眠'];
  static const _moodOptions = ['开心', '平静', '低落', '烦躁', '焦虑'];

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _tempCtrl.dispose();
    super.dispose();
  }

  bool get _isLast => _step == _stepCount - 1;

  Future<void> _next() async {
    if (_isLast) {
      await _save();
      return;
    }
    setState(() => _step++);
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: today.subtract(const Duration(days: 365 * 2)),
      lastDate: today,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final user = getIt<CurrentUser>();
    final repo = getIt<RecordRepository>();
    final prediction = getIt<PredictionService>();
    final userId = await user.id();
    final date = _date;

    await repo.upsertPeriodDay(
      userId: userId,
      date: date,
      isPeriod: _isPeriod,
      flowLevel: _isPeriod ? _flow : null,
    );
    for (final s in _symptoms) {
      await repo.upsertSymptom(userId: userId, date: date, symptomType: s);
    }
    await _saveMetrics(userId: userId, date: date, repo: repo);
    if (_mood != null) {
      await repo.upsertMood(userId: userId, date: date, moodType: _mood!);
    }
    await prediction.recompute(userId);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).recordSaved)),
    );
    Navigator.of(context).pop();
  }

  Future<void> _saveMetrics({
    required int userId,
    required DateTime date,
    required RecordRepository repo,
  }) async {
    final weight = double.tryParse(_weightCtrl.text.trim());
    if (weight != null) {
      await repo.upsertBodyMetric(
        userId: userId, date: date, metricType: '体重', value: weight);
    }
    final temp = double.tryParse(_tempCtrl.text.trim());
    if (temp != null) {
      await repo.upsertBodyMetric(
        userId: userId, date: date, metricType: '体温', value: temp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stepTitles = [
      l10n.stepPeriod,
      l10n.stepFlow,
      l10n.stepSymptoms,
      l10n.stepMetrics,
      l10n.stepMood,
    ];
    final stepHints = [
      l10n.stepPeriodHint,
      l10n.stepFlowHint,
      l10n.stepSymptomsHint,
      l10n.stepMetricsHint,
      l10n.stepMoodHint,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.recordTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(l10n.recordDate),
                trailing: Text(
                  DateFormat.yMMMd(dateLocale(context)).format(_date),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: _pickDate,
              ),
              _ProgressHeader(step: _step, titles: stepTitles),
              const SizedBox(height: 8),
              Text(stepHints[_step],
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Flexible(child: _buildStep()),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _step == 0
                          ? null
                          : () => setState(() => _step--),
                      child: Text(l10n.prevStep),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _next,
                      child: Text(_isLast ? l10n.save : l10n.nextStep),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    final l10n = AppLocalizations.of(context);
    final flowLabels = [
      l10n.recordFlowSpotting,
      l10n.recordFlowLight,
      l10n.recordFlowMedium,
      l10n.recordFlowHeavy,
    ];
    return switch (_step) {
      0 => _choiceList<String>(
          options: [l10n.yesPeriodToday, l10n.no],
          selected: _isPeriod ? 0 : 1,
          onSelect: (i) => setState(() => _isPeriod = i == 0),
          textOf: (o) => o,
        ),
      1 => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < flowLabels.length; i++)
              ChoiceChip(
                label: Text(flowLabels[i]),
                selected: _flow == i,
                onSelected: (_) => setState(() => _flow = i),
              ),
          ],
        ),
      2 => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in _symptomOptions)
              FilterChip(
                label: Text(symptomLabel(l10n, o)),
                selected: _symptoms.contains(o),
                onSelected: (v) => setState(() {
                  v ? _symptoms.add(o) : _symptoms.remove(o);
                }),
              ),
          ],
        ),
      3 => _metricFields(),
      4 => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in _moodOptions)
              ChoiceChip(
                label: Text(moodLabel(l10n, o)),
                selected: _mood == o,
                onSelected: (_) => setState(() => _mood = o),
              ),
          ],
        ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _metricFields() {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        TextField(
          controller: _weightCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.weightKgOptional,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _tempCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.tempCOptional,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _choiceList<T>({
    required List<T> options,
    required int selected,
    required void Function(int) onSelect,
    required String Function(T) textOf,
  }) {
    return Column(
      children: [
        for (var i = 0; i < options.length; i++)
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: selected == i
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
                width: selected == i ? 2 : 1,
              ),
            ),
            title: Text(textOf(options[i])),
            trailing: selected == i ? const Icon(Icons.check_circle) : null,
            onTap: () => onSelect(i),
          ),
      ],
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.step, required this.titles});

  final int step;
  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < titles.length; i++) ...[
          if (i > 0) Expanded(child: Divider(color: Theme.of(context).dividerColor)),
          CircleAvatar(
            radius: 14,
            backgroundColor: i <= step
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              '${i + 1}',
              style: TextStyle(
                color: i <= step ? Colors.white : null,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }
}