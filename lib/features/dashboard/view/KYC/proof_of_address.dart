import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/models/kyc_address_request.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';

import '../../../../core/utils/logger.dart';

final proofOfAddressImageProvider = StateProvider<File?>((ref) => null);

class ProofOfAddressPage extends ConsumerStatefulWidget {
  final KycAddressRequest addressRequest;

  const ProofOfAddressPage({Key? key, required this.addressRequest})
    : super(key: key);

  @override
  _ProofOfAddressPageState createState() => _ProofOfAddressPageState();
}

class _ProofOfAddressPageState extends ConsumerState<ProofOfAddressPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        ref.read(proofOfAddressImageProvider.notifier).state = imageFile;
        if (mounted) {
          Navigator.pop(context); // Close bottom sheet
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Select Image Source',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSourceOption(
                  icon: Icons.camera_alt_outlined,
                  title: 'Camera',
                  subtitle: 'Take a photo',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                const Divider(height: 1),
                _buildSourceOption(
                  icon: Icons.photo_library_outlined,
                  title: 'Gallery',
                  subtitle: 'Select an image',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                const Divider(height: 1),
                _buildSourceOption(
                  icon: Icons.folder_outlined,
                  title: 'Internal Storage',
                  subtitle: 'Browse image from storage',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF6B7280)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Future<void> _submitProofOfAddress() async {
    final imageFile = ref.read(proofOfAddressImageProvider);
    if (imageFile == null) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Compress and encode image (optional - can be used for local storage)
      // final base64Image = await _compressAndEncodeImage(imageFile);

      // Prepare API request data matching the endpoint format
      final addressData = widget.addressRequest.toJson();

      // Log the document being uploaded
      AppLogger.log('📤 [ProofOfAddress] Uploading document to API: ${imageFile.path}');

      // Upload document for Tier 3 review
      await ref.read(userNotifierProvider.notifier).uploadTier3Document(imageFile.path);

      if (mounted) {
        Navigator.pop(context); // Close loading

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document submitted for review. Pending approval.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to account or home screen
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedImage = ref.watch(proofOfAddressImageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Title
              const Text(
                'Proof Of Address',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              const Text(
                'Upload a utility bill showing your address, and ensure the state, LGA, and area match the details you provided',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontFamily: 'SF Pro',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
              const SizedBox(height: 40),
              // Upload Container
              GestureDetector(
                onTap: _showImageSourceModal,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? const Color(0xFF1F2937)
                            : const Color(0xFFFAFBFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF9CA3AF),
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child:
                      selectedImage == null
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Upload Icon
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Icon(
                                  Icons.file_upload_outlined,
                                  color: Color(0xFF6B7280),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Upload Text
                              const Text(
                                'Upload',
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Subtitle
                              const Text(
                                'A utility bill not older than 3 months',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          )
                          : Column(
                            children: [
                              // Show selected image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  selectedImage,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Change image button
                              TextButton.icon(
                                onPressed: _showImageSourceModal,
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('Change Image'),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFFF6905),
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 40),
              // Continue Button
              Center(
                child: FullWidthButton(
                  text: 'Continue',
                  isEnabled: selectedImage != null,
                  onPressed: _submitProofOfAddress,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
