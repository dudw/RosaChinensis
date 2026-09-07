import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app.dart';
import '../../l10n/app_localizations.dart';

/// 生理周期个人化页面。
///
/// 仅包含**显示**设置：是否在日历上显示排卵日 / 受孕期。
/// 周期长度由预测引擎自适应，无需用户手动填写。
class CyclePersonalizationPage extends StatefulWidget {
  const CyclePersonalizationPage({super.key});

  @override
  State<CyclePersonalizationPage> createState() =>
      _CyclePersonalizationPageState();
}

class _CyclePersonalizationPageState extends State<CyclePersonalizationPage> {
  bool _showOvulation = true;
  bool _showFertile = true;
  bool _loading = true;

  static const _pShowOvulation = 'cycle_show_ovulation';
  static const _pShowFertile = 'cycle_show_fertile';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _showOvulation = p.getBool(_pShowOvulation) ?? true;
      _showFertile = p.getBool(_pShowFertile) ?? true;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_pShowOvulation, _showOvulation);
    await p.setBool(_pShowFertile, _showFertile);
    AppSettingsController.instance.notify();
  }

  Future<void> _reset() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_pShowOvulation);
    await p.remove(_pShowFertile);
    setState(() {
      _showOvulation = true;
      _showFertile = true;
    });
    AppSettingsController.instance.notify();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.cyclePersonalization)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.displaySection,
                    style: t.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Card(
                  child: Column(children: [
                    SwitchListTile.adaptive(
                      title: Text(l10n.showOvulation),
                      value: _showOvulation,
                      onChanged: (v) {
                        setState(() => _showOvulation = v);
                        _save();
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile.adaptive(
                      title: Text(l10n.showFertileWindow),
                      value: _showFertile,
                      onChanged: (v) {
                        setState(() => _showFertile = v);
                        _save();
                      },
                    ),
                  ]),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    l10n.fertileDisclaimer,
                    style: t.textTheme.bodySmall
                        ?.copyWith(color: t.colorScheme.outline),
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: _reset,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(l10n.restoreDefault),
                ),
              ],
            ),
    );
  }
}

/// 对外暴露的设置读取助手，供其他功能模块（日历、预测）调用。
class CycleSettings {
  CycleSettings._();

  /// 安全加载：在测试环境或 binding 未初始化时返回默认值，不抛异常。
  static Future<CycleSettingsData> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      return CycleSettingsData(
        showOvulation: p.getBool('cycle_show_ovulation') ?? true,
        showFertile: p.getBool('cycle_show_fertile') ?? true,
      );
    } catch (_) {
      return const CycleSettingsData(
        showOvulation: true,
        showFertile: true,
      );
    }
  }
}

class CycleSettingsData {
  const CycleSettingsData({
    required this.showOvulation,
    required this.showFertile,
  });
  final bool showOvulation;
  final bool showFertile;
}
