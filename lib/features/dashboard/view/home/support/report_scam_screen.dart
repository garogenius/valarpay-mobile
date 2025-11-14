import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:valarpay/core/themes/color_utils.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
// unused imports removed
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/utils/responsive_utils.dart';
import 'package:valarpay/features/notifiers/report_scam_notifier.dart';

class ReportScamScreen extends ConsumerStatefulWidget {
  const ReportScamScreen({super.key});

  @override
  ConsumerState<ReportScamScreen> createState() => _ReportScamScreenState();
}

class _ReportScamScreenState extends ConsumerState<ReportScamScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _screenshot;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      _screenshot = File(picked.path);
    });
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      AppMessenger.show(
        context,
        message: 'Please provide title and description',
        type: MessageType.error,
      );
      return;
    }

    // call notifier to upload
    ref
        .read(reportScamNotifierProvider.notifier)
        .report(
          title: _titleController.text,
          description: _descriptionController.text,
          screenshot: _screenshot,
        );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportScamNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(reportScamNotifierProvider, (previous, next) {
      if (!next.isInitialLoading) {
        if (next.isDataAvailable) {
          AppMessenger.show(
            context,
            message: 'Report submitted successfully',
            type: MessageType.success,
          );
          setState(() {
            _titleController.clear();
            _descriptionController.clear();
            _screenshot = null;
          });
        } else if (next.message != null) {
          AppMessenger.show(
            context,
            message: next.message!,
            type: MessageType.error,
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Scam'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveUtils.paddingAll16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Title',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveUtils.fontSize16,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Short title for the issue',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: ResponsiveUtils.borderRadius12,
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: ResponsiveUtils.borderRadius12,
                    borderSide: BorderSide(color: Theme.of(context).cardColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: ResponsiveUtils.borderRadius12,
                    borderSide: BorderSide(
                      color: appTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: ResponsiveUtils.borderRadius12,
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: ResponsiveUtils.borderRadius12,
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: ResponsiveUtils.paddingAll16,
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 24),

              Text(
                'Describe Your Issue',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveUtils.fontSize16,
                ),
              ),
              SizedBox(height: ResponsiveUtils.spacing8),

              // Issue description field
              TextFormField(
                controller: _descriptionController,
                maxLines: 8,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Tell us what happened and how we can help you...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: ResponsiveUtils.fontSize14,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: ResponsiveUtils.borderRadius12,
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: ResponsiveUtils.borderRadius12,
                    borderSide: BorderSide(color: Theme.of(context).cardColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: ResponsiveUtils.borderRadius12,
                    borderSide: BorderSide(
                      color: appTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: ResponsiveUtils.borderRadius12,
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: ResponsiveUtils.borderRadius12,
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: ResponsiveUtils.paddingAll16,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe your issue';
                  }
                  if (value.trim().length < 10) {
                    return 'Please provide more details (at least 10 characters)';
                  }
                  return null;
                },
              ),

              SizedBox(height: 24),

              Text(
                'Screenshot',
                style: TextStyle(
                  color: isDark ? Colors.grey : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Theme.of(context).cardColor,
                  ),
                  child:
                      _screenshot == null
                          ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.camera_alt, size: 36),
                                SizedBox(height: 8),
                                Text('Tap to attach screenshot'),
                              ],
                            ),
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_screenshot!, fit: BoxFit.cover),
                          ),
                ),
              ),
              const SizedBox(height: 24),
              // Info card
              Container(
                padding: ResponsiveUtils.paddingAll12,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: ResponsiveUtils.borderRadius8,
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20.sp),
                    SizedBox(width: ResponsiveUtils.spacing8),
                    Expanded(
                      child: Text(
                        'Our support team will review your complaint and get back to you within 24-48 hours.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue[700],
                          fontSize: ResponsiveUtils.fontSize12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FullWidthButton(
                text: 'Submit Report',
                isEnabled:
                    _titleController.text.isNotEmpty &&
                    _descriptionController.text.isNotEmpty,
                onPressed: _submit,
                isLoading: state.isInitialLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
