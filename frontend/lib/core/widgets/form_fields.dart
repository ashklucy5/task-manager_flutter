import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_spacing.dart';


import '../enums/task_priority.dart';
import '../enums/task_status.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';


// ── Text Field (with ValueListenable support) ──
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int? maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary( // ✅ Prevent repaints on parent rebuild
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(hintText: hint),
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }
}

// ── Picker Field ──
class AppPickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData icon;

  const AppPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    
    return RepaintBoundary( // ✅ Prevent repaints
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: InputDecorator(
          decoration: InputDecoration(hintText: label),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: value == label ? c.labelTertiary : c.labelPrimary,
                  ),
                ),
              ),
              Icon(icon, color: c.labelTertiary, size: 20), // ✅ Fixed size
            ],
          ),
        ),
      ),
    );
  }
}

// ── Priority Selector (optimized) ──
class PrioritySelector extends StatelessWidget {
  final TaskPriority value;
  final ValueChanged<TaskPriority> onChanged;

  const PrioritySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Priority',
            style: AppTypography.footnote(context, c.labelSecondary),
          ),
          const SizedBox(height: 6),
          SegmentedButton<TaskPriority>(
            segments: const [
              ButtonSegment(value: TaskPriority.low, label: Text('Low')),
              ButtonSegment(value: TaskPriority.medium, label: Text('Med')),
              ButtonSegment(value: TaskPriority.high, label: Text('High')),
              ButtonSegment(value: TaskPriority.urgent, label: Text('!')),
            ],
            selected: {value},
            onSelectionChanged: (s) => onChanged(s.first),
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: c.brandPrimary.withValues(alpha: 0.15),
              selectedForegroundColor: c.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status Selector (optimized) ──
class StatusSelector extends StatelessWidget {
  final TaskStatus value;
  final ValueChanged<TaskStatus> onChanged;

  const StatusSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status',
            style: AppTypography.footnote(context, c.labelSecondary),
          ),
          const SizedBox(height: 6),
          SegmentedButton<TaskStatus>(
            segments: const [
              ButtonSegment(value: TaskStatus.pending, label: Text('Pending')),
              ButtonSegment(value: TaskStatus.inProgress, label: Text('Active')),
              ButtonSegment(value: TaskStatus.onHold, label: Text('Hold')),
              ButtonSegment(value: TaskStatus.completed, label: Text('Done')),
            ],
            selected: {value},
            onSelectionChanged: (s) => onChanged(s.first),
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: c.brandPrimary.withValues(alpha: 0.15),
              selectedForegroundColor: c.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Form Actions (optimized) ──
class FormActions extends StatelessWidget {
  final bool loading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final String submitLabel;

  const FormActions({
    super.key,
    required this.loading,
    required this.onCancel,
    required this.onSubmit,
    this.submitLabel = 'Save',
  });

  @override
  Widget build(BuildContext context) {
    final s = AppSpacing.of(context);
    
    return RepaintBoundary(
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: loading ? null : onCancel,
              child: const Text('Cancel'),
            ),
          ),
          SizedBox(width: s.sm),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: loading ? null : onSubmit,
              child: loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}