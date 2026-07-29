import 'dart:io';
import 'package:dio/dio.dart' show MultipartFile;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/enums/task_priority.dart';
import '../../../core/enums/task_status.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../presence/providers/team_pulse_provider.dart';
import '../providers/task_detail_provider.dart';
import '../providers/edit_task_provider.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  final int taskId;
  const EditTaskScreen({super.key, required this.taskId});

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'edit_task_form');
  
  // ── Controllers ──
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // ── Assignment State ──
  String _assigneeName = '';
  String? _assigneeId;
  List<({String id, String name, String role})> _assignableMembers = [];
  bool _canAssign = false;
  
  // ── Task Data ──
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.medium;
  TaskStatus _status = TaskStatus.pending;
  
  // ── Image State ──
  List<String> _existingImageUrls = [];
  final List<XFile> _newImages = [];
  final List<String> _imagesToDelete = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final s = AppSpacing.of(context);
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: c.backgroundSecondary,
      appBar: AppBar(
        title: Text('Edit Task', style: AppTypography.title2(context, c.labelPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _isLoading ? null : _confirmDelete,
            color: c.systemRed,
          ),
        ],
      ),
      body: taskAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(taskDetailProvider(widget.taskId)),
        ),
        data: (task) {
          if (!_isInitialized) {
            _loadAssignableMembers(user);
            _titleCtrl.text = task.title;
            _descCtrl.text = task.description ?? '';
            _assigneeId = task.assigneeId;
            _assigneeName = task.assigneeName ?? '';
            _dueDate = task.dueDate;
            _priority = task.priority;
            _status = task.status;
            _existingImageUrls = task.imageUrls ?? [];
            _isInitialized = true;
          }

          return Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: EdgeInsets.all(s.screenPadding),
              children: [
                // ── Title ──
                AppTextField(
                  controller: _titleCtrl,
                  hint: 'Title',
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // ── Assignee ──
                if (_canAssign) ...[
                  AppPickerField(
                    label: 'Assignee',
                    value: _assigneeName.isEmpty ? 'Select assignee' : _assigneeName,
                    icon: Icons.person_outline,
                    onTap: _pickAssignee,
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.of(context).brandPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: AppColors.of(context).brandPrimary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Assigned to: ${_assigneeName.isEmpty ? 'You' : _assigneeName}',
                            style: AppTypography.body(
                              context,
                              AppColors.of(context).labelPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Due Date ──
                AppPickerField(
                  label: 'Due date',
                  value: _dueDate != null 
                      ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}' 
                      : 'Select',
                  icon: Icons.calendar_today,
                  onTap: _pickDueDate,
                ),
                const SizedBox(height: 12),

                // ── Priority ──
                PrioritySelector(
                  value: _priority,
                  onChanged: (v) => setState(() => _priority = v),
                ),
                const SizedBox(height: 12),

                // ── Status ──
                StatusSelector(
                  value: _status,
                  onChanged: (v) => setState(() => _status = v),
                ),
                const SizedBox(height: 12),

                // ── Description ──
                AppTextField(
                  controller: _descCtrl,
                  hint: 'Description',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // ── Images Section ──
                _buildImageSection(context, s),

                const SizedBox(height: 24),

                // ── Actions ──
                FormActions(
                  loading: _isLoading,
                  onCancel: () {
                    if (mounted) context.pop();
                  },
                  onSubmit: _submit,
                  submitLabel: 'Update',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Image Section Widget ──

  Widget _buildImageSection(BuildContext context, AppSpacing s) {
    final c = AppColors.of(context);
    final hasExisting = _existingImageUrls.isNotEmpty;
    final hasNew = _newImages.isNotEmpty;
    final totalImages = _existingImageUrls.length + _newImages.length;

    if (!hasExisting && !hasNew) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Images', style: AppTypography.title3(context, c.labelPrimary)),
          const SizedBox(height: 8),
          _buildAddImageButton(context, s, c),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Images ($totalImages/6)',
              style: AppTypography.title3(context, c.labelPrimary),
            ),
            if (totalImages < 6) _buildAddImageButton(context, s, c),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: totalImages,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              // Determine if this is an existing or new image
              if (index < _existingImageUrls.length) {
                final url = _existingImageUrls[index];
                final isMarkedForDelete = _imagesToDelete.contains(url);
                return _buildImageItem(
                  imageUrl: url,
                  isMarkedForDelete: isMarkedForDelete,
                  onDelete: () => _toggleImageDelete(url),
                  isExisting: true,
                );
              } else {
                final newIndex = index - _existingImageUrls.length;
                final file = _newImages[newIndex];
                return _buildImageItem(
                  file: file,
                  onDelete: () => _removeNewImage(file),
                  isExisting: false,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageItem({
    String? imageUrl,
    XFile? file,
    bool isMarkedForDelete = false,
    required VoidCallback onDelete,
    required bool isExisting,
  }) {
    final c = AppColors.of(context);
    
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: isExisting && imageUrl != null
                  ? NetworkImage(imageUrl)
                  : FileImage(File(file!.path)) as ImageProvider,
              fit: BoxFit.cover,
            ),
            border: isMarkedForDelete
                ? Border.all(color: c.systemRed, width: 3)
                : null,
          ),
        ),
        if (isMarkedForDelete)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black.withValues(alpha: 0.4),
              ),
              child: Icon(
                Icons.delete_forever,
                color: c.systemRed,
                size: 30,
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: CircleAvatar(
            radius: 14,
            backgroundColor: isMarkedForDelete
                ? c.systemGreen
                : Colors.black.withValues(alpha: 0.6),
            child: IconButton(
              icon: Icon(
                isMarkedForDelete ? Icons.undo : Icons.close,
                size: 14,
                color: Colors.white,
              ),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ),
        if (isExisting && !isMarkedForDelete)
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Existing',
                style: AppTypography.caption2(context, Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddImageButton(BuildContext context, AppSpacing s, AppColorSet c) {
    return InkWell(
      onTap: _pickImages,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: c.separator, width: 2),
          borderRadius: BorderRadius.circular(8),
          color: c.backgroundSecondary,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, color: c.labelSecondary),
            const SizedBox(height: 4),
            Text(
              'Add Photos',
              style: AppTypography.caption2(context, c.labelSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ── Image Methods ──

  void _toggleImageDelete(String url) {
    setState(() {
      if (_imagesToDelete.contains(url)) {
        _imagesToDelete.remove(url);
      } else {
        _imagesToDelete.add(url);
      }
    });
  }

  void _removeNewImage(XFile file) {
    setState(() {
      _newImages.remove(file);
    });
  }

  Future<void> _pickImages() async {
    final totalImages = _existingImageUrls.length + _newImages.length;
    final remaining = 6 - totalImages;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 6 images allowed')),
      );
      return;
    }

    final picker = ImagePicker();
    final images = await picker.pickMultiImage(limit: remaining);
    if (images.isNotEmpty && mounted) {
      setState(() {
        _newImages.addAll(images);
      });
    }
  }

  // ── Helper Methods ──

  Future<void> _loadAssignableMembers(UserModel? user) async {
  if (user == null) return;

  final groups = await ref.read(teamPulseProvider.future);
  final allMembers = groups.expand((g) => g.members).toList();

  List<({String id, String name, String role})> members = [];

  switch (user.role) {
    case UserRole.superAdmin:
      members = allMembers.map((m) => (
        id: m.id,
        name: m.fullName,
        role: m.role.displayLabel,
      )).toList();
      _canAssign = true;
      break;

    case UserRole.admin:
      final teamMembers = allMembers.where((m) => m.parentId == user.id).toList();
      members = [
        (id: user.id, name: user.fullName, role: 'Self'),
        ...teamMembers.map((m) => (
          id: m.id,
          name: m.fullName,
          role: m.role.displayLabel,
        )),
      ];
      _canAssign = true;
      break;

    case UserRole.member:
      _canAssign = false;
      // ✅ DON'T set _assigneeId or _assigneeName here
      // Keep the original assignee from the task
      return;
  }

  if (_assigneeName.isEmpty && _assigneeId != null) {
      final match = members.firstWhere(
        (m) => m.id == _assigneeId,
        orElse: () => (id: '', name: '', role: ''),
      );
      if (match.id.isNotEmpty) {
        _assigneeName = match.name;
      }
    }

  final seen = <String>{};
  _assignableMembers = members.where((m) {
    if (seen.contains(m.id)) return false;
    seen.add(m.id);
    return true;
  }).toList();

  if (_assigneeId != null && !_assignableMembers.any((m) => m.id == _assigneeId)) {
    _assignableMembers.insert(0, (
      id: _assigneeId!,
      name: _assigneeName.isNotEmpty ? _assigneeName : 'Unknown',
      role: 'Previous',
    ));
  }
}

  Future<void> _pickAssignee() async {
    if (!_canAssign || _assignableMembers.isEmpty) return;

    final result = await showModalBottomSheet<({String id, String name})>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Assignee',
                style: AppTypography.title3(
                  context,
                  AppColors.of(context).labelPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _assignableMembers.length,
              itemBuilder: (context, index) {
                final m = _assignableMembers[index];
                final isSelected = m.id == _assigneeId;
                return ListTile(
                  title: Text(m.name),
                  subtitle: Text(m.role),
                  trailing: isSelected 
                      ? Icon(Icons.check, color: AppColors.of(context).brandPrimary)
                      : null,
                  onTap: () => Navigator.pop(context, (id: m.id, name: m.name)),
                );
              },
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _assigneeId = result.id;
        _assigneeName = result.name;
      });
    }
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      setState(() => _dueDate = date);
    }
  }

  // ── Submit with Image Support ──

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate images
    final totalImages = _existingImageUrls.length + _newImages.length;
    if (totalImages > 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 6 images allowed')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final controller = ref.read(editTaskControllerProvider);

      // ── Prepare final image URLs ──
      final List<String> finalImageUrls = [];

      // 1. Keep existing images (except those marked for deletion)
      for (final url in _existingImageUrls) {
        if (!_imagesToDelete.contains(url)) {
          finalImageUrls.add(url);
        }
      }

      // 2. Upload new images
      List<MultipartFile> uploadedImages = [];
      for (final file in _newImages) {
        final multipartFile = await MultipartFile.fromFile(
          file.path,
          filename: file.name,
        );
        uploadedImages.add(multipartFile);
      }

      // ── Call update with images ──
      final updated = await controller.updateTask(
        taskId: widget.taskId,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        assigneeId: _assigneeId,
        dueDate: _dueDate,
        priority: _priority.value,
        status: _status.value,
        imageUrls: finalImageUrls.isNotEmpty ? finalImageUrls : null,
        newImages: uploadedImages.isNotEmpty ? uploadedImages : null,
        imagesToDelete: _imagesToDelete.isNotEmpty ? _imagesToDelete : null,
      );
      debugPrint('=== SERVER RETURNED: assigneeId=${updated.assigneeId}, title=${updated.title}, status=${updated.status} ===');

      if (mounted) {
        setState(() => _isLoading = false);
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              
              try {
                final controller = ref.read(editTaskControllerProvider);
                await controller.deleteTask(widget.taskId);
                
                if (mounted) {
                  setState(() => _isLoading = false);
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task deleted')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.of(context).systemRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}