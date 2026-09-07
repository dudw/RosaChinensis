import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Stage A 阶段的占位页壳：用于尚未实现的具体功能页，
/// 保持底部导航可达并在后续 Stage 中被真实页面替换。
class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    super.key,
    required this.title,
    required this.icon,
    this.description,
  });

  final String title;
  final IconData icon;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: scheme.primary),
              const SizedBox(height: 16),
              Text(l10n.placeholderModule(title),
                  textAlign: TextAlign.center),
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}