import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/change_password_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  double get _strength {
    final value = _newController.text;
    var score = 0.0;
    if (value.length >= 8) score += 0.4;
    if (RegExp(r'[0-9]').hasMatch(value) && RegExp(r'[a-zA-Z]').hasMatch(value)) score += 0.3;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) score += 0.3;
    return score.clamp(0, 1);
  }

  String get _strengthLabel {
    if (_strength >= 0.9) return 'Strong';
    if (_strength >= 0.4) return 'Medium';
    return 'Weak';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final error = await ref.read(changePasswordControllerProvider).submit(
          currentPassword: _currentController.text,
          newPassword: _newController.text,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated')));
      Navigator.of(context).pop();
    } else {
      setState(() => _errorMessage = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final spacing = AppSpacing.of(context);
    final hasLength = _newController.text.length >= 8;
    final hasMix = RegExp(r'[0-9]').hasMatch(_newController.text) && RegExp(r'[a-zA-Z]').hasMatch(_newController.text);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_newController.text);

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(title: Text('Change Password', style: AppTypography.title2(context, colors.labelPrimary))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding, vertical: spacing.md),
          children: [
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: colors.systemRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(_errorMessage!, style: AppTypography.footnote(context, colors.systemRed)),
              ),
              SizedBox(height: spacing.sm),
            ],

            TextFormField(
              controller: _currentController,
              obscureText: _obscureCurrent,
              decoration: InputDecoration(
                hintText: 'Current Password',
                suffixIcon: IconButton(
                  icon: Icon(_obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            SizedBox(height: spacing.sm),

            TextFormField(
              controller: _newController,
              obscureText: _obscureNew,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'New Password',
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              validator: (v) => (v == null || v.length < 8) ? 'Minimum 8 characters' : null,
            ),
            SizedBox(height: spacing.xs),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Text(_strengthLabel, style: AppTypography.caption1(context, colors.labelSecondary))],
            ),
            SizedBox(height: spacing.xs / 2),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _strength,
                minHeight: 8,
                backgroundColor: colors.fillQuaternary,
                color: _strength >= 0.9 ? colors.systemGreen : (_strength >= 0.4 ? colors.systemOrange : colors.systemRed),
              ),
            ),
            SizedBox(height: spacing.sm),

            _RequirementRow(met: hasLength, label: 'At least 8 characters'),
            _RequirementRow(met: hasMix, label: 'Mix of letters and numbers'),
            _RequirementRow(met: hasSpecial, label: 'Include special character'),
            SizedBox(height: spacing.sm),

            TextFormField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                hintText: 'Confirm New Password',
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (v) => (v != _newController.text) ? 'Passwords do not match' : null,
            ),
            SizedBox(height: spacing.xl),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Update Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final bool met;
  final String label;
  const _RequirementRow({required this.met, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(met ? Icons.check_circle : Icons.circle_outlined, size: 16, color: met ? colors.systemGreen : colors.labelTertiary),
          const SizedBox(width: 8),
          Text(label, style: AppTypography.caption1(context, met ? colors.labelPrimary : colors.labelSecondary)),
        ],
      ),
    );
  }
}