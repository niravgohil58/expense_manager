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
      body: user == null
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
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  ),
                ),
              ],
            ),
    );
  }
}
