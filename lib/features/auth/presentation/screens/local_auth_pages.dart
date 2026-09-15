import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../data/repositories/phone_auth_service.dart';
import '../../../../data/repositories/local_session_repository.dart';

class LocalLoginPage extends StatefulWidget {
  const LocalLoginPage({required this.session, required this.auth, super.key});

  final LocalSessionRepository session;
  final PhoneAuthService auth;

  @override
  State<LocalLoginPage> createState() => _LocalLoginPageState();
}

class _LocalLoginPageState extends State<LocalLoginPage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool _isSending = false;
  String? _error;

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSending = true;
      _error = null;
    });
    try {
      final verificationId = await widget.auth.sendCode(
        _phoneController.text.trim(),
      );
      if (mounted) {
        context.go(
          '/otp',
          extra: PhoneVerificationArgs(
            phoneNumber: _phoneController.text.trim(),
            verificationId: verificationId,
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _error = l10nFrom(context).otpFailed);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  AppLocalizations l10nFrom(BuildContext context) =>
      AppLocalizations.of(context);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _AuthScaffold(
      title: l10n.welcomeTitle,
      subtitle: l10n.welcomeSubtitle,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: l10n.phoneNumber,
                hintText: l10n.phoneNumberHint,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              validator: (value) {
                final phone = value?.trim() ?? '';
                if (phone.length < 7) return l10n.invalidPhone;
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSending ? null : _continue,
                child: _isSending
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.continueAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PhoneVerificationArgs {
  const PhoneVerificationArgs({
    required this.phoneNumber,
    required this.verificationId,
  });

  final String phoneNumber;
  final String verificationId;
}

class LocalOtpPage extends StatefulWidget {
  const LocalOtpPage({required this.auth, required this.args, super.key});

  final PhoneAuthService auth;
  final PhoneVerificationArgs args;

  @override
  State<LocalOtpPage> createState() => _LocalOtpPageState();
}

class _LocalOtpPageState extends State<LocalOtpPage> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isVerifying = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isVerifying = true;
      _error = null;
    });
    try {
      await widget.auth.verifyCode(
        verificationId: widget.args.verificationId,
        smsCode: _codeController.text.trim(),
      );
      if (mounted) {
        context.go('/profile', extra: widget.args.phoneNumber);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).otpInvalid);
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _AuthScaffold(
      title: l10n.otpTitle,
      subtitle: '${l10n.otpSubtitle} ${widget.args.phoneNumber}',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: l10n.otpCode,
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              validator: (value) =>
                  value?.trim().length == 6 ? null : l10n.otpInvalid,
            ),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isVerifying ? null : _verify,
                child: _isVerifying
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.verifyCode),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocalProfileSetupPage extends StatefulWidget {
  const LocalProfileSetupPage({
    required this.session,
    required this.phoneNumber,
    this.onProfileSaved,
    super.key,
  });

  final LocalSessionRepository session;
  final String phoneNumber;
  final Future<void> Function({
    required String phoneNumber,
    required String displayName,
  })?
  onProfileSaved;

  @override
  State<LocalProfileSetupPage> createState() => _LocalProfileSetupPageState();
}

class _LocalProfileSetupPageState extends State<LocalProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _realNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _aboutController = TextEditingController();

  @override
  void dispose() {
    _realNameController.dispose();
    _displayNameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.session.saveProfile(
      phoneNumber: widget.phoneNumber,
      realName: _realNameController.text.trim(),
      displayName: _displayNameController.text.trim(),
      about: _aboutController.text.trim(),
    );
    await widget.onProfileSaved?.call(
      phoneNumber: widget.phoneNumber,
      displayName: _displayNameController.text.trim(),
    );
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _AuthScaffold(
      title: l10n.profileSetupTitle,
      subtitle: l10n.profileSetupSubtitle,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _realNameController,
              decoration: InputDecoration(
                labelText: l10n.realName,
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
              validator: _requiredValidator(l10n.requiredField),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _displayNameController,
              decoration: InputDecoration(
                labelText: l10n.displayName,
                prefixIcon: const Icon(Icons.alternate_email),
              ),
              validator: _requiredValidator(l10n.requiredField),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _aboutController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.about,
                prefixIcon: const Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: Text(l10n.saveProfile),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? Function(String?) _requiredValidator(String message) {
    return (value) => value?.trim().isEmpty ?? true ? message : null;
  }
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CircleAvatar(
                    radius: 34,
                    child: Icon(Icons.forum_outlined, size: 32),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(subtitle, textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
