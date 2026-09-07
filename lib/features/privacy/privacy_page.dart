import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// 隐私说明页（PRD 隐私章节落地为真实页面）。
/// 说明本地优先、存储加密、可控导出/删除。
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section(t, Icons.storage_outlined, l10n.privacyLocalTitle,
              l10n.privacyLocalBody),
          _section(t, Icons.lock_outline, l10n.privacyEncryptedTitle,
              l10n.privacyEncryptedBody),
          _section(t, Icons.phonelink_erase_outlined, l10n.privacyClearTitle,
              l10n.privacyClearBody),
          _section(t, Icons.upload_file_outlined, l10n.privacyMigrateTitle,
              l10n.privacyMigrateBody),
        ],
      ),
    );
  }

  Widget _section(
      ThemeData t, IconData icon, String title, String body) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: t.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(body, style: t.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}