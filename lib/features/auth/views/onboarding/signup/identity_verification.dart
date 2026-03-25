import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/core/widgets/smart_selfie_widget.dart';
import 'package:valarpay/features/models/signup_request.dart';

class SignupIdentityVerificationScreen extends ConsumerStatefulWidget {
  final SignUpRequest request;
  const SignupIdentityVerificationScreen({required this.request, super.key});

  @override
  ConsumerState<SignupIdentityVerificationScreen> createState() =>
      _SignupIdentityVerificationScreenState();
}

class _SignupIdentityVerificationScreenState
    extends ConsumerState<SignupIdentityVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  bool _isNin = true; // Default to NIN
  bool _showCamera = false;

  void _onProceed() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _showCamera = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showCamera) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SmartSelfieWidget(
          onComplete: (selfie, liveness) async {
            final updatedRequest = widget.request.copyWith(
              nin: _isNin ? _idController.text.trim() : null,
              bvn: !_isNin ? _idController.text.trim() : null,
              selfieImage: 'data:image/jpeg;base64,$selfie',
              livenessImages: liveness.map((img) => 'data:image/jpeg;base64,$img').toList(),
            );
            
            if (mounted) {
              Navigator.pop(context); // Close the camera widget first
              context.push('/personal-details', extra: updatedRequest);
            }
            return true;
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Identity'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Identify Verification',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose your preferred verification method to continue.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(
                    child: _buildChoiceChip(
                      label: 'NIN',
                      isSelected: _isNin,
                      onTap: () => setState(() => _isNin = true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildChoiceChip(
                      label: 'BVN',
                      isSelected: !_isNin,
                      onTap: () => setState(() => _isNin = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              Text(
                _isNin ? 'Enter NIN' : 'Enter BVN',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _idController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: _isNin ? 'Enter 11-digit NIN' : 'Enter 11-digit BVN',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  if (value.length != 11) {
                    return 'Must be 11 digits';
                  }
                  return null;
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Proceed to Liveness Check',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    context.push('/personal-details', extra: widget.request);
                  },
                  child: const Text('Skip for now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? appTheme.primaryColor : Colors.transparent,
          border: Border.all(color: appTheme.primaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : appTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
