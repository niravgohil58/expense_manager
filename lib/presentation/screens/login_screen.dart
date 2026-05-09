import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/design_constants.dart';
import '../../core/preferences/app_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

/// Mandatory sign-in entry (Android/iOS when Firebase is enabled).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _registerMode = false;
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _navigateAfterAuth(BuildContext context, User user) async {
    final auth = context.read<AuthProvider>();
    final prefs = context.read<AppPreferences>();
    await auth.handleSuccessfulLogin(context, user);
    if (!context.mounted) return;
    final target = prefs.onboardingCompleted ? '/home' : '/onboarding';
    context.go(target);
  }

  Future<void> _submitEmailPassword(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final auth = context.read<AuthProvider>();
      final credential = _registerMode
          ? await auth.registerWithEmailPassword(
              email: _emailController.text,
              password: _passwordController.text,
            )
          : await auth.signInWithEmailPassword(
              email: _emailController.text,
              password: _passwordController.text,
            );
      final user = credential.user;
      if (user != null && context.mounted) {
        await _navigateAfterAuth(context, user);
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? l10n.loginErrorGeneric)),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loginErrorGeneric)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInGoogle(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final auth = context.read<AuthProvider>();
      final credential = await auth.signInWithGoogle();
      final user = credential.user;
      if (user != null && context.mounted) {
        await _navigateAfterAuth(context, user);
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? l10n.loginErrorGeneric)),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loginErrorGeneric)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _busy,
          child: SingleChildScrollView(
            padding: DesignConstants.paddingLg,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: DesignConstants.spacingXl),
                  Icon(Icons.account_balance_wallet_rounded,
                      size: 64, color: scheme.primary),
                  const SizedBox(height: DesignConstants.spacingLg),
                  Text(
                    _registerMode ? l10n.loginRegisterTitle : l10n.loginTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DesignConstants.spacingSm),
                  Text(
                    l10n.loginSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DesignConstants.spacingXl),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: l10n.loginEmailLabel,
                    ),
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty || !s.contains('@')) {
                        return l10n.loginEmailInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: DesignConstants.spacingMd),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    autofillHints: _registerMode
                        ? const [AutofillHints.newPassword]
                        : const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: l10n.loginPasswordLabel,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      if ((v ?? '').length < 6) {
                        return l10n.loginPasswordTooShort;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: DesignConstants.spacingLg),
                  FilledButton(
                    onPressed: _busy ? null : () => _submitEmailPassword(context),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: DesignConstants.borderRadiusMd,
                      ),
                    ),
                    child: _busy
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _registerMode
                                ? l10n.loginPrimaryRegister
                                : l10n.loginPrimarySignIn,
                          ),
                  ),
                  const SizedBox(height: DesignConstants.spacingMd),
                  OutlinedButton(
                    onPressed: _busy ? null : () => _signInGoogle(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: DesignConstants.borderRadiusMd,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'G',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(l10n.loginGoogle),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignConstants.spacingMd),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() => _registerMode = !_registerMode),
                    child: Text(
                      _registerMode
                          ? l10n.loginToggleToSignIn
                          : l10n.loginToggleToRegister,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: DesignConstants.spacingXl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed:
                            _busy ? null : () => context.push('/terms'),
                        child: Text(l10n.drawerTermsConditions),
                      ),
                      Text(' · ',
                          style: TextStyle(color: scheme.outline)),
                      TextButton(
                        onPressed:
                            _busy ? null : () => context.push('/privacy'),
                        child: Text(l10n.drawerPrivacyPolicy),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
