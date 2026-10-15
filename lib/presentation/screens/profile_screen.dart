import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/design_constants.dart';
import '../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

/// Signed-in user summary + sign out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();
    final user = auth.firebaseUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
      ),
      body: SafeArea(
        top: false,
        child: user == null
            ? Center(child: Text(l10n.profileNotSignedIn))
          : ListView(
              padding: DesignConstants.paddingLg,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor:
                        scheme.primaryContainer.withValues(alpha: 0.6),
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? Icon(Icons.person_rounded,
                            size: 48, color: scheme.primary)
                        : null,
                  ),
                ),
                const SizedBox(height: DesignConstants.spacingLg),
                Text(
                  user.displayName ?? l10n.profileNoDisplayName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (user.email != null) ...[
                  const SizedBox(height: DesignConstants.spacingSm),
                  Text(
                    user.email!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
                const SizedBox(height: DesignConstants.spacingXl),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.badge_outlined, color: scheme.primary),
                  title: Text(l10n.profileUserIdLabel),
                  subtitle: SelectableText(
                    user.uid,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: DesignConstants.spacingXl),
                FilledButton.icon(
                  onPressed: () async {
                    await auth.signOut();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(l10n.profileSignOut),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                  ),
                ),
                const SizedBox(height: DesignConstants.spacingMd),
                OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Account'),
                        content: const Text(
                          'Are you sure you want to delete your account? '
                          'This will permanently delete your cloud profile and authentication credentials. '
                          'Your local device ledger will remain intact.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: scheme.error),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete Permanently'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed != true || !context.mounted) return;

                    try {
                      final messenger = ScaffoldMessenger.of(context);
                      final ok = await auth.deleteAccount(context);
                      if (ok && context.mounted) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Account deleted successfully.')),
                        );
                        context.go('/login');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().contains('requires-recent-login')
                                  ? 'For security, please log out and log in again before deleting your account.'
                                  : 'Could not delete account: $e',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_forever_rounded),
                  label: const Text('Delete Account'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: scheme.error,
                    side: BorderSide(color: scheme.error),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
