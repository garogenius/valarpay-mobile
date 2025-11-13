import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/widgets/all_time_reusable_button.dart';
import 'package:valarpay/features/models/signup_request.dart';

class SignupSuccessScreen extends ConsumerStatefulWidget {
  final SignUpRequest request;

  const SignupSuccessScreen({
    required this.request,
    super.key,
  });

  @override
  ConsumerState<SignupSuccessScreen> createState() =>
      _SignupSuccessScreenState();
}

class _SignupSuccessScreenState extends ConsumerState<SignupSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(60.r),
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 60.sp),
                  ),
                  SizedBox(height: 48.h),
                  Text(
                    "Congratulations, ${widget.request.fullname}! You've successfully created your account",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 3),
                  FullWidthButton(
                    text: 'Proceed to Login',
                    onPressed: () => context.pushReplacement('/signin'),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
