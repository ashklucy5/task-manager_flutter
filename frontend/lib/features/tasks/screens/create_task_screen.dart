import 'dart:io';
import 'package:dio/dio.dart' show MultipartFile;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/enums/task_priority.dart';
import '../../../core/models/app_currency.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/create_task_provider.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _paymentController = TextEditingController();

  String? _selectedAssigneeId;
  String? _selectedAssigneeName;
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.medium;
  AppCurrency _currency = AppCurrency.usd;
  final List<XFile> _pickedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _paymentController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickAssignee() async {
    final membersAsync = ref.read(assignableMembersProvider);
    final members = membersAsync.value ?? [];

    if (!mounted) return;
    final selected = await showModalBottomSheet<({String id, String name})>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: members
              .map((m) => ListTile(
                    title: Text(m.fullName),
                    subtitle: Text(m.position ?? m.role.displayLabel),
                    onTap: () => Navigator.pop(context, (id: m.id, name: m.fullName)),
                  ))
              .toList(),
        ),
      ),
    );
    if (selected != null) {
      setState(() {
        _selectedAssigneeId = selected.id;
        _selectedAssigneeName = selected.name;
      });
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(limit: 6);
    if (images.isNotEmpty) {
      setState(() {
        _pickedImages.clear();
        _pickedImages.addAll(images.take(6));
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAssigneeId == null || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an assignee and due date')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final paymentAmount = double.tryParse(_paymentController.text);
    List<MultipartFile>? multipartImages;
    if (_pickedImages.isNotEmpty) {
      multipartImages = await Future.wait(
        _pickedImages.map((img) => MultipartFile.fromFile(img.path, filename: img.name)),
      );
    }

    final success = await ref.read(createTaskControllerProvider).submit(
          title: _titleController.text.trim(),
          assigneeId: _selectedAssigneeId!,
          dueDate: _dueDate!,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          priority: _priority.value,
          paymentAmount: paymentAmount,
          currency: _currency.code,
          images: multipartImages,
        );

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create task. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final spacing = AppSpacing.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(title: Text('Create Task', style: AppTypography.title2(context, colors.labelPrimary))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: spacing.screenPadding, vertical: spacing.md),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Title'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            SizedBox(height: spacing.sm),

            InkWell(
              onTap: _pickAssignee,
              child: InputDecorator(
                decoration: const InputDecoration(hintText: 'Select assignee'),
                child: Text(_selectedAssigneeName ?? 'Select assignee'),
              ),
            ),
            SizedBox(height: spacing.sm),

            InkWell(
              onTap: _pickDueDate,
              child: InputDecorator(
                decoration: const InputDecoration(hintText: 'Due date', suffixIcon: Icon(Icons.calendar_today_outlined)),
                child: Text(_dueDate != null ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}' : 'Select due date'),
              ),
            ),
            SizedBox(height: spacing.sm),

            SegmentedButton<TaskPriority>(
              segments: const [
                ButtonSegment(value: TaskPriority.low, label: Text('Low')),
                ButtonSegment(value: TaskPriority.medium, label: Text('Medium')),
                ButtonSegment(value: TaskPriority.high, label: Text('High')),
              ],
              selected: {_priority},
              onSelectionChanged: (s) => setState(() => _priority = s.first),
            ),
            SizedBox(height: spacing.sm),

            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Requirements / description'),
            ),
            SizedBox(height: spacing.sm),

            // ── Payment amount + currency picker, side by side ──
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _paymentController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(hintText: 'Payment Amount (optional)'),
                  ),
                ),
                SizedBox(width: spacing.xs),
                Expanded(
                  child: DropdownButtonFormField<AppCurrency>(
                    initialValue: _currency,
                    decoration: const InputDecoration(),
                    items: AppCurrency.all
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.code)))
                        .toList(),
                    onChanged: (c) => setState(() => _currency = c ?? AppCurrency.usd),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.sm),

            // ── Optional photos ──
            Text('Photos (optional)', style: AppTypography.footnote(context, colors.labelSecondary)),
            SizedBox(height: spacing.xs),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._pickedImages.map((img) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(img.path), width: 80, height: 80, fit: BoxFit.cover),
                        ),
                      )),
                  InkWell(
                    onTap: _pickImages,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.separator),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add_a_photo_outlined, color: colors.labelSecondary),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.xl),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}