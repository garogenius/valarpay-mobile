import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/dashboard/view/KYC/identity_verification.dart';
import 'package:valarpay/features/models/bvn_verification_request.dart';
import 'package:valarpay/features/notifiers/user_notifier.dart';
import '../../widgets/Kyc/kyc_progress_bar.dart';
import 'kyc_step_provider.dart';

final bvnProvider = StateProvider<String>((ref) => '');

class BVNPage extends ConsumerStatefulWidget {
  const BVNPage({Key? key}) : super(key: key);

  @override
  ConsumerState<BVNPage> createState() => _BVNPageState();
}

class _BVNPageState extends ConsumerState<BVNPage> {
  late TextEditingController _bvnController;

  @override
  void initState() {
    super.initState();
    _bvnController = TextEditingController(text: ref.read(bvnProvider));
  }

  @override
  void dispose() {
    _bvnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bvn = ref.watch(bvnProvider);
    final isFormValid = bvn.length == 11;
    final currentStep = ref.watch(kycStepProvider);
    final userState = ref.watch(userNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(kycStepProvider.notifier).state = 2;
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Step Progress Bar
              StepProgressBar(currentStep: currentStep),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Your BVN',
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
                'Enter your BVN to verify your identity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontFamily: 'SF Pro',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
              const SizedBox(height: 32),

              // BVN Input Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your BVN',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                      letterSpacing: 0.06,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _bvnController,
                      onChanged: (value) {
                        ref.read(bvnProvider.notifier).state = value;
                      },
                      keyboardType: TextInputType.number,
                      maxLength: 11,
                      style: const TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter your BVN',
                        hintStyle: TextStyle(
                          color: Color(0xFFD1D5DB),
                          fontFamily: 'SF Pro',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        counterText: '', // Hide counter
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Info Section
              Column(
                children: [
                  const Text(
                    'Why we need your BVN?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We need your BVN to confirm your identity and ensure your account is secure. Sharing your BVN does not give us access to your bank account or funds.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontFamily: 'SF Pro',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'To get your BVN, dial ',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                        TextSpan(
                          text: '*565#',
                          style: TextStyle(color: Color(0xFFF76301)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Continue Button
              FullWidthButton(
                text: 'Continue',
                isEnabled: isFormValid,
                isLoading: userState.isInitialLoading,
                onPressed: () async {
                  // Navigate directly to identity verification (camera capture)
                  ref.read(kycStepProvider.notifier).state = 4;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => IdentityVerificationPage(
                            request: BvnVerificationRequest(bvn: bvn),
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
