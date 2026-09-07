import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../app.dart';
import '../../core/di/injection.dart';
import '../../core/i18n/locale_controller.dart';
import '../../data/auto_backup_controller.dart';
import '../../data/current_user.dart';
import '../../data/data_transfer_service.dart';
import '../../data/repositories/record_repository.dart';
import '../../l10n/app_localizations.dart';
import '../privacy/privacy_page.dart';
import '../track/category_filter_page.dart';
import '../track/track_category_config.dart';
import 'cycle_personalization_page.dart';

/// 更多/设置页（PRD 17.4 / 26.2，H/I Stage）：
/// 同步与账号、数据导出（全量 JSON）、清除全部数据、隐私说明。
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _exportJson() => _exportToFile('JSON', (s, u) => s.exportJsonToFile(u));

  /// 把数据导出为本地文件，成功后弹窗展示保存路径，并提供复制到剪贴板选项。
  Future<void> _exportToFile(
    String label,
    Future<ExportFile> Function(DataTransferService, int) run,
  ) async {
    final l10n = AppLocalizations.of(context);
    final msg = ScaffoldMessenger.of(context);
    late final ExportFile output;
    try {
      final userId = await getIt<CurrentUser>().id();
      output = await run(getIt<DataTransferService>(), userId);
    } catch (e) {
      msg.showSnackBar(SnackBar(content: Text(l10n.exportFailed('$e'))));
      return;
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.exportSaved(label)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(output.path,
                style: Theme.of(ctx).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(l10n.exportSavedCount(_lenText(output))),
            const SizedBox(height: 8),
            Text(l10n.exportCopyHint),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
          FilledButton.tonalIcon(
            onPressed: () async {
              await SharePlus.instance.share(
                ShareParams(
                  files: [XFile(output.path)],
                  text: l10n.exportShareText(label),
                ),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            icon: const Icon(Icons.share),
            label: Text(l10n.shareSaveToSystem),
          ),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: output.content));
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.copiedToClipboard)),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: Text(l10n.copyContent),
          ),
        ],
      ),
    );
  }

  String _lenText(ExportFile file) {
    final l10n = AppLocalizations.of(context);
    final kb = file.content.length ~/ 1024;
    return kb < 1 ? l10n.charsCount(file.content.length) : '$kb KB';
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    final userId = await getIt<CurrentUser>().id();
    if (!mounted) return;

    // 方式选择：从文件导入 / 直接粘贴。
    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: Text(l10n.importFromFile),
              subtitle: Text(l10n.importFromFileSubtitle),
              onTap: () => Navigator.pop(ctx, 'file'),
            ),
            ListTile(
              leading: const Icon(Icons.content_paste),
              title: Text(l10n.pasteJson),
              subtitle: Text(l10n.pasteJsonSubtitle),
              onTap: () => Navigator.pop(ctx, 'paste'),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final String? input;
    if (source == 'file') {
      input = await _pickImportFile();
    } else {
      input = await _pasteImport();
    }
    if (input == null || input.trim().isEmpty || !mounted) return;

    final msg = ScaffoldMessenger.of(context);
    try {
      final report = await getIt<DataTransferService>().import(userId, input);
      if (!mounted) return;
      await _showImportReport(report);
    } on ImportFormatException catch (e) {
      // schema 版本不匹配 / JSON 非法 → 未写入任何数据（事务回滚）。
      if (!mounted) return;
      msg.showSnackBar(
        SnackBar(content: Text(_importErrorMessage(l10n, e))),
      );
    } on FormatException catch (e) {
      if (!mounted) return;
      msg.showSnackBar(SnackBar(content: Text(l10n.importFailed(e.message))));
    } catch (e) {
      if (!mounted) return;
      msg.showSnackBar(SnackBar(content: Text(l10n.importFailed('$e'))));
    }
  }

  String _importErrorMessage(AppLocalizations l10n, ImportFormatException e) {
    switch (e.error) {
      case ImportError.jsonParse:
        return l10n.importErrorJsonParse;
      case ImportError.invalidJson:
        return l10n.importErrorInvalidJson;
      case ImportError.schemaMismatch:
        final parts = e.detail.split('/');
        return l10n.importErrorSchemaMismatch(
          parts.isNotEmpty ? parts.first : '',
          parts.length > 1 ? parts[1] : '',
        );
      case ImportError.missingData:
        return l10n.importErrorMissingData;
      case ImportError.invalidDate:
        return l10n.importErrorInvalidDate;
    }
  }

  /// 用系统文件选择器选取 .json 文件并读取其内容。
  Future<String?> _pickImportFile() async {
    final XFile? file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'JSON',
          extensions: ['json'],
          mimeTypes: ['application/json'],
        ),
      ],
    );
    if (file == null) return null;
    return file.readAsString();
  }

  /// 粘贴 JSON（预填剪贴板内容方便直接导入）。
  Future<String?> _pasteImport() async {
    final l10n = AppLocalizations.of(context);
    var prefill = '';
    try {
      prefill = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    } catch (_) {}
    if (!mounted) return null;

    final controller = TextEditingController(text: prefill);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.pasteJson),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.importDedupeHint),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 8,
              minLines: 4,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: l10n.pasteJsonHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(l10n.import),
          ),
        ],
      ),
    );
  }

  Future<void> _showImportReport(ImportReport report) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.importDone),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.importSummary(report.totalInserted, report.totalSkipped)),
            const SizedBox(height: 8),
            for (final e in report.inserted.entries)
              Text('${_tableLabel(e.key)}：${l10n.addedCount(e.value)}'),
            for (final e in report.skipped.entries.where((e) => e.value > 0))
              Text('${_tableLabel(e.key)}：${l10n.skippedCount(e.value)}'),
            const SizedBox(height: 8),
            Text(l10n.importSkippedHint),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  String _tableLabel(String table) {
    final l10n = AppLocalizations.of(context);
    return switch (table) {
      'period_days' => l10n.tablePeriodDays,
      'symptom_records' => l10n.tableSymptoms,
      'body_metrics' => l10n.tableBodyMetrics,
      'mood_records' => l10n.tableMoods,
      'predictions' => l10n.tablePredictions,
      _ => table,
    };
  }

  String _modeLabel(ThemeMode mode) {
    final l10n = AppLocalizations.of(context);
    return switch (mode) {
      ThemeMode.system => l10n.themeSystem,
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
    };
  }

  Future<void> _showThemePicker(BuildContext ctx) async {
    final l10n = AppLocalizations.of(context);
    final current = ThemeController.instance.mode;
    final picked = await showDialog<ThemeMode>(
      context: ctx,
      builder: (dctx) => AlertDialog(
        title: Text(l10n.appearance),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in [ThemeMode.system, ThemeMode.light, ThemeMode.dark])
              ListTile(
                leading: Icon(
                  current == mode ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: current == mode ? Theme.of(ctx).colorScheme.primary : null,
                ),
                title: Text(_modeLabel(mode)),
                onTap: () => Navigator.pop(ctx, mode),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
    if (picked != null) ThemeController.instance.setMode(picked);
  }

  /// 手动立即备份：写入用户授权的备份目录。
  Future<void> _backupNow() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ctrl = AutoBackupController.instance;
    // 未选目录时直接打开系统目录选择器，完成后继续备份。
    if (!ctrl.hasDir) {
      final picked = await ctrl.pickDirectory();
      if (!picked) return; // 用户取消
    }
    final result = await ctrl.backupManual();
    if (!mounted) return;
    if (!result.ok || result.path == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.backupFailed(result.error ?? l10n.unknownError))),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.backupDone),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(result.path!,
                style: Theme.of(ctx).textTheme.bodySmall),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
          FilledButton.tonalIcon(
            onPressed: () async {
              final shareFile = result.sharePath ?? result.path!;
              await SharePlus.instance.share(
                ShareParams(
                  files: [XFile(shareFile)],
                  text: l10n.backupShareText,
                ),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            icon: const Icon(Icons.share),
            label: Text(l10n.shareSaveAs),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAll() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearAllConfirmTitle),
        content: Text(l10n.clearAllConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final userId = await getIt<CurrentUser>().id();
    await getIt<RecordRepository>().clearUserData(userId);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.clearedAllData)));
  }

  String _languageLabel() {
    final l10n = AppLocalizations.of(context);
    return switch (LocaleController.instance.choice) {
      LocaleController.zh => l10n.languageZh,
      LocaleController.en => l10n.languageEn,
      _ => l10n.languageSystem,
    };
  }

  Future<void> _showLanguagePicker() async {
    final l10n = AppLocalizations.of(context);
    final current = LocaleController.instance.choice;
    final options = [
      (LocaleController.system, l10n.languageSystem),
      (LocaleController.zh, l10n.languageZh),
      (LocaleController.en, l10n.languageEn),
    ];
    final picked = await showDialog<String>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (value, label) in options)
              ListTile(
                leading: Icon(
                  current == value
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: current == value
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(label),
                onTap: () => Navigator.pop(dctx, value),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
    if (picked != null) await LocaleController.instance.setChoice(picked);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabMore)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 主题模式切换
          Card(
            child: AnimatedBuilder(
              animation: ThemeController.instance,
              builder: (_, _) => ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: Text(l10n.appearance),
                subtitle: Text(_modeLabel(ThemeController.instance.mode)),
                onTap: () => _showThemePicker(context),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 语言选择
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              subtitle: Text(_languageLabel()),
              onTap: _showLanguagePicker,
            ),
          ),
          const SizedBox(height: 8),
          // 跟踪与预测
          Card(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.track_changes_outlined),
                title: Text(l10n.customizeTracking),
                subtitle: Text(l10n.customizeTrackingSubtitle),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final cfg = await TrackCategoryConfig.instance;
                  if (!mounted) return;
                  await navigator.push(
                    MaterialPageRoute(builder: (_) => CategoryFilterPage(config: cfg)),
                  );
                  setState(() {});
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: Text(l10n.cyclePersonalization),
                subtitle: Text(l10n.cyclePersonalizationSubtitle),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CyclePersonalizationPage()),
                  );
                },
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.upload_file_outlined),
              title: Text(l10n.importData),
              subtitle: Text(l10n.importDataSubtitle),
              onTap: _import,
            ),
          ),
          const SizedBox(height: 8),
          // 自动备份
          Card(
            child: Column(children: [
              StatefulBuilder(
                builder: (ctx, innerSet) {
                  final ctrl = AutoBackupController.instance;
                  return SwitchListTile.adaptive(
                    secondary: const Icon(Icons.cloud_done_outlined),
                    title: Text(l10n.autoBackup),
                    subtitle: Text(l10n.autoBackupSubtitle),
                    value: ctrl.enabled,
                    onChanged: (v) async {
                      // 开启前必须先选择并授权备份目录。
                      if (v && !ctrl.hasDir) {
                        await ctrl.pickDirectory();
                      }
                      await ctrl.setEnabled(v && ctrl.hasDir);
                      innerSet(() {});
                      if (context.mounted) setState(() {});
                    },
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.folder_open_outlined),
                title: Text(l10n.backupDir),
                subtitle: Text(
                  AutoBackupController.instance.dirDisplay ??
                      l10n.backupDirNotSelected,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () async {
                  await AutoBackupController.instance.pickDirectory();
                  if (mounted) setState(() {});
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: Text(l10n.backupNow),
                onTap: () => _backupNow(),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: Text(l10n.exportJson),
                subtitle: Text(l10n.exportJsonSubtitle),
                onTap: _exportJson,
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.delete_forever_outlined,
                    color: t.colorScheme.error),
                title: Text(l10n.clearAllData,
                    style: TextStyle(color: t.colorScheme.error)),
                onTap: _clearAll,
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(l10n.privacyPolicy),
              subtitle: Text(l10n.privacyPolicySubtitle),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyPage()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}