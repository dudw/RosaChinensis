import 'package:flutter/material.dart';

import '../../core/di/injection.dart';
import '../../data/current_user.dart';
import '../../l10n/app_localizations.dart';

/// 同步与账号页（PRD 17.4 / 26.1 收敛项落地为真实页面）。
/// 本版本坚持「本地优先」，无真实云同步；展示匿名标识与迁移指引。
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late Future<int> _userId;

  @override
  void initState() {
    super.initState();
    _userId = getIt<CurrentUser>().id();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: FutureBuilder<int>(
        future: _userId,
        builder: (context, snap) {
          final idText = snap.hasData ? '${snap.data}' : '—';
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                color: t.colorScheme.primaryContainer.withValues(alpha: 0.4),
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(l10n.currentMode),
                  subtitle: Text(l10n.localFreeMode),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: Text(l10n.accountId),
                  subtitle: Text(l10n.anonymousUser(idText)),
                  trailing: Text(l10n.noLoginRequired),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.accountPrivacyBody,
                    style: t.textTheme.bodySmall,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, color: t.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.accountMigrateHint,
                          style: t.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}