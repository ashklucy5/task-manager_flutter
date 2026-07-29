import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';

enum _RegistrationMode { company, individual }

class RegisterCompanyScreen extends ConsumerStatefulWidget {
  const RegisterCompanyScreen({super.key});

  @override
  ConsumerState<RegisterCompanyScreen> createState() => _RegisterCompanyScreenState();
}

class _RegisterCompanyScreenState extends ConsumerState<RegisterCompanyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _companyNameController = TextEditingController();
  final _companyCodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _positionController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _RegistrationMode _mode = _RegistrationMode.individual;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyCodeController.dispose();
    _descriptionController.dispose();
    _positionController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isCompany => _mode == _RegistrationMode.company;

  /// Derives a short, reasonably-unique company code from the person's
  /// name + a timestamp tail, for Individual mode where we don't ask
  /// for one. If it collides (rare), the backend returns a clear 400
  /// and re-submitting regenerates a fresh one since it's time-based.
  String _generateIndividualCode(String fullName) {
    final letters = fullName.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final prefix = letters.isEmpty ? 'IND' : letters.substring(0, letters.length >= 4 ? 4 : letters.length);
    final tail = DateTime.now().millisecondsSinceEpoch.toString();
    return '$prefix${tail.substring(tail.length - 5)}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final fullName = _fullNameController.text.trim();
    final companyName = _isCompany ? _companyNameController.text.trim() : "$fullName's Workspace";
    final companyCode =
        _isCompany ? _companyCodeController.text.trim().toUpperCase() : _generateIndividualCode(fullName);
    final position = _isCompany ? _positionController.text.trim() : 'Owner';

    final controller = ref.read(authControllerProvider);
    final result = await controller.registerCompany(
      companyName: companyName,
      companyCode: companyCode,
      companyDescription: _isCompany ? _descriptionController.text.trim() : null,
      adminEmail: _emailController.text.trim(),
      adminFullName: fullName,
      adminPassword: _passwordController.text,
      adminPosition: position,
    );

    // On success, app_router's redirect (refreshListenable on
    // AuthController) handles navigation automatically — this call is
    // just a fallback/formality, same pattern as login_screen.
    if (result != null && mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colors.backgroundGrouped,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.brandPrimary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.hub_outlined, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create your account',
                      style: AppTypography.title2(context, colors.labelPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    SegmentedButton<_RegistrationMode>(
                      segments: const [
                        ButtonSegment(
                          value: _RegistrationMode.individual,
                          label: Text('Just Me'),
                          icon: Icon(Icons.person_outline),
                        ),
                        ButtonSegment(
                          value: _RegistrationMode.company,
                          label: Text('Company'),
                          icon: Icon(Icons.apartment_outlined),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: (s) => setState(() => _mode = s.first),
                    ),
                    const SizedBox(height: 20),

                    if (authState.errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.systemRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          authState.errorMessage!,
                          style: AppTypography.footnote(context, colors.systemRed),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (_isCompany) ...[
                      Text('Company', style: AppTypography.footnote(context, colors.labelSecondary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _companyNameController,
                        decoration: const InputDecoration(
                          hintText: 'Company name',
                          prefixIcon: Icon(Icons.apartment_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _companyCodeController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          hintText: 'Company code (e.g. TECH1)',
                          prefixIcon: Icon(Icons.tag_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(hintText: 'Description (optional)'),
                      ),
                      const SizedBox(height: 20),
                    ],

                    Text('Your Info', style: AppTypography.footnote(context, colors.labelSecondary)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        hintText: 'Full name',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),

                    if (_isCompany) ...[
                      TextFormField(
                        controller: _positionController,
                        decoration: const InputDecoration(
                          hintText: 'Your position (e.g. CEO, Founder)',
                          prefixIcon: Icon(Icons.work_outline),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                    ],

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 8) ? 'Minimum 8 characters' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        hintText: 'Confirm password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _submit,
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Create Account'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Already have an account? Sign In'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}