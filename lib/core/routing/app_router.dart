import 'package:valarpay/features/dashboard/view/home/support/terms_and_conditions.dart';
import 'package:valarpay/features/dashboard/view/home/support/privacy_policy.dart';
import 'package:valarpay/features/dashboard/view/KYC/upgrade_kyc.dart';
import 'package:valarpay/features/dashboard/view/KYC/proof_of_address.dart';
import 'package:valarpay/features/dashboard/view/KYC/kyc_review_progress.dart';
import 'package:valarpay/features/models/kyc_address_request.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/features/auth/views/onboarding/signup/security_details.dart';
import 'package:valarpay/features/auth/views/onboarding/signup/verify_2fa.dart';
import 'package:valarpay/features/dashboard/view/cards/get_physical_card.dart';
import 'package:valarpay/features/dashboard/view/me/rewards.dart';
import 'package:valarpay/features/dashboard/view/me/rate_app_screen.dart';
import 'package:valarpay/features/dashboard/view/services/betting/betting.dart';
import 'package:valarpay/features/dashboard/view/services/cabletv/cabletv_screen.dart';
import 'package:valarpay/features/dashboard/view/services/giftcard/gift_card.dart';
import 'package:valarpay/features/dashboard/view/services/data/data_ussd_enquiry.dart';
import 'package:valarpay/features/dashboard/view/services/education/education.dart';
import 'package:valarpay/features/dashboard/view/services/electricity/electricity_screen.dart';
import 'package:valarpay/features/dashboard/view/services/flight/flight_selection_screen.dart';
import 'package:valarpay/features/dashboard/view/services/giftcard/gift_card.dart';
import 'package:valarpay/features/dashboard/view/settings/change_passcode_screen.dart';
import 'package:valarpay/features/dashboard/view/settings/change_password_screen.dart';
import 'package:valarpay/features/dashboard/view/settings/create_passcode.dart';
import 'package:valarpay/features/dashboard/view/services/insurance/insurance.dart';
import 'package:valarpay/features/dashboard/view/services/international_airtime/international_airtime_screen.dart';
import 'package:valarpay/features/dashboard/view/services/internet/internet_screen.dart';
import 'package:valarpay/features/dashboard/view/services/shopping/shopping.dart';
import 'package:valarpay/features/dashboard/view/services/swap_currency/swap_currency.dart';
import 'package:valarpay/features/dashboard/view/settings/close_account_screen.dart';
import 'package:valarpay/features/dashboard/view/settings/forgot_pin_screen.dart';
import 'package:valarpay/features/models/signup_request.dart';
import 'package:valarpay/features/models/user.dart';
import 'package:valarpay/features/models/username_request.dart';
import 'package:valarpay/features/models/transaction_model.dart';
import '../../features/dashboard/view/services/airtime/airtime_screen.dart';
import '../../features/dashboard/view/services/data/data.dart';
import '../../features/dashboard/view/services/airtime/schedule_topup.dart';
import '../../features/dashboard/view/services/airtime/ussd_enquiry.dart';
import '../../features/dashboard/view/me/transaction_history.dart';
import '../../features/dashboard/view/me/account_settings.dart';
import '../../features/dashboard/view/me/account_statement.dart';
import '../../features/dashboard/view/me/theme.dart';
import '../../features/dashboard/view/home/notifications/notification_view.dart';
import 'package:valarpay/features/dashboard/view/account/account_screen.dart';
import 'package:valarpay/features/dashboard/view/account/account_setup_screen.dart';
import '../../features/dashboard/view/me/portfolio.dart';
import 'package:valarpay/features/dashboard/view/addmoney/add_money_screen.dart';
import 'package:valarpay/features/dashboard/view/addmoney/add_money_via_qrcode_screen.dart';
import 'package:valarpay/features/dashboard/view/addmoney/add_money_via_transfer_screen.dart';
import 'package:valarpay/features/dashboard/view/cards/create_vcard_screen.dart';
import 'package:valarpay/features/dashboard/view/cards/vcard_details_screen.dart';
import 'package:valarpay/features/dashboard/view/cards/vcard_management_screen.dart';
import 'package:valarpay/features/dashboard/view/cards/vcard_transactions_screen.dart';
import 'package:valarpay/features/dashboard/view/cards/fund_vcard_screen.dart';
import 'package:valarpay/features/dashboard/view/cards/withdraw_vcard_screen.dart';
import 'package:valarpay/features/dashboard/view/comming_soon.dart';
import 'package:valarpay/features/dashboard/view/home/notifications/notifications_screen.dart';
import 'package:valarpay/features/dashboard/view/home/support/customer_service_screen.dart';
import 'package:valarpay/features/dashboard/view/home/support/faq_screen.dart';
import 'package:valarpay/features/dashboard/view/home/support/visit_office_screen.dart';
import 'package:valarpay/features/dashboard/view/home/support/report_scam_screen.dart';
import 'package:valarpay/features/dashboard/view/home/QRCode/decode_qr_code.dart';
import 'package:valarpay/features/dashboard/view/home/support/security_tips_screen.dart';
import 'package:valarpay/features/dashboard/view/transfer/transfer_to_bank/transfer_to_bank.dart';
import 'package:valarpay/features/dashboard/view/transfer/transfer_to_valarpay/transfer_to_valarpay_screen.dart';
import 'package:valarpay/features/dashboard/view/withdraw/withdraw_bank_branch_screen.dart';
import 'package:valarpay/features/dashboard/view/withdraw/withdraw_merchant_screen.dart';
import 'package:valarpay/features/dashboard/view/withdraw/withdraw_screen.dart';
import '../../features/dashboard/view/me/about_us.dart';
import '../../features/auth/views/introductory/intro_wrapper.dart';
import '../../features/auth/views/onboarding/reset_password.dart';
import '../../features/auth/views/onboarding/forgot_password.dart';
import '../../features/auth/views/onboarding/forgot_password_verification.dart';
import '../../features/auth/views/onboarding/signin/biometric_login.dart';
import '../../features/auth/views/onboarding/signin/passcode_login.dart';
import '../../features/auth/views/onboarding/signin/signin.dart';
import '../../features/auth/views/onboarding/signup/business_details.dart';
import '../../features/auth/views/onboarding/signup/personal_details.dart';
import '../../features/auth/views/onboarding/signup/validate_phone.dart';
import '../../features/auth/views/onboarding/signup/signup.dart';
import '../../features/auth/views/onboarding/signup/signup_success.dart';
import '../../features/auth/views/onboarding/signup/verify_email.dart';
import '../../features/auth/views/onboarding/signup/verify_phone.dart';
import '../../features/auth/views/splashscreen/splashscreen.dart';
import '../../features/dashboard/dashboard_wrapper.dart';
import '../../features/dashboard/view/cards/card.dart';
import '../../features/dashboard/view/home/homescreen.dart';
import '../../features/dashboard/view/home/support/faq_detail_screen.dart';
import '../../features/dashboard/view/invest.dart';
import '../../features/dashboard/view/me.dart';
import '../../features/dashboard/view/savings.dart';
import '../../features/dashboard/view/settings/settings.dart';
import '../../features/dashboard/view/settings/security_settings_screen.dart';
import '../../features/dashboard/view/settings/login_settings_screen.dart';
import '../../features/dashboard/view/settings/transaction_pin_settings_screen.dart';
import '../../features/dashboard/view/settings/notification_settings_screen.dart';
import '../../features/dashboard/view/settings/finance_settings_screen.dart';
import '../../features/dashboard/view/settings/change_pin_screen.dart';
import '../../features/dashboard/view/settings/auto_logout_settings_screen.dart';
import '../../features/dashboard/view/profile/profile.dart';
import '../../features/dashboard/view/profile/personal_details_screen.dart'
    as profile;
import '../../features/dashboard/view/profile/contact_details_screen.dart';
import '../../features/dashboard/view/profile/address_screen.dart';
import '../../features/dashboard/view/profile/edit_profile_screen.dart';
import '../../features/dashboard/view/finance/savings/create_savings_plan_screen.dart';
import '../../features/dashboard/view/finance/easylife/create_easylife_plan_screen.dart';
import '../../features/dashboard/view/finance/fixed_deposit/create_fixed_deposit_screen.dart';
import '../../features/dashboard/view/finance/savings/savings_details_screen.dart';
import '../../features/dashboard/view/finance/easylife/easylife_details_screen.dart';
import '../../features/dashboard/view/finance/fixed_deposit/fixed_deposit_details_screen.dart';
import '../../features/dashboard/view/finance/savings/target_savings_screen.dart';
import '../../features/dashboard/view/finance/easylife/easylife_list_screen.dart';
import '../../features/dashboard/view/finance/fixed_deposit/fixed_deposit_list_screen.dart';
import '../../features/dashboard/view/finance/finance_transaction_history_screen.dart';
import '../../features/dashboard/view/finance/finance_transaction_details_screen.dart';
import '../../features/dashboard/view/profile/change_phone_number.dart';
import '../../features/dashboard/view/finance/finance_main_screen.dart';
import '../../features/dashboard/view/finance/investment/investment_intro_screen.dart';
import '../../features/dashboard/view/finance/investment/create_investment_screen.dart';
import '../../features/dashboard/view/finance/investment/my_investments_screen.dart';
import '../../features/dashboard/view/finance/investment/investment_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:valarpay/features/dashboard/view/services/all_services_screen.dart';
import '../../features/dashboard/view/finance/finance_intro_screen.dart';
import 'package:valarpay/features/dashboard/view/finance/widgets/finance_product_intro_screen.dart';

import 'package:valarpay/core/services/connectivity_service.dart';

final router = GoRouter(
  navigatorKey: ConnectivityService.navigatorKey,
  initialLocation: '/splash', // Always show splash screen

  routes: [
    GoRoute(path: '/splash', builder: (context, state) => SplashScreen()),
    GoRoute(path: '/intro', builder: (context, state) => const WelcomeScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/personal-details',
      builder: (context, state) {
        final request = state.extra as SignUpRequest;
        return PersonalDetailsScreen(request: request);
      },
    ),
    GoRoute(
      path: '/business-details',
      builder: (context, state) {
        final request = state.extra as SignUpRequest;
        return BusinessDetailsScreen(request: request);
      },
    ),
    GoRoute(
      path: '/security-details',
      builder: (context, state) {
        final request = state.extra as SignUpRequest;
        return SecurityDetailsScreen(request: request);
      },
    ),
    GoRoute(
      path: '/verify-email',
      builder: (context, state) {
        final request = state.extra as SignUpRequest;
        return VerifyEmailScreen(request: request);
      },
    ),
    GoRoute(
      path: '/validate-phone',
      builder: (context, state) {
        final request = state.extra as SignUpRequest;
        return ValidatePhoneScreen(request: request);
      },
    ),
    GoRoute(
      path: '/verify-phone',
      builder: (context, state) {
        final request = state.extra as SignUpRequest;
        return VerifyPhoneScreen(request: request);
      },
    ),
    GoRoute(
      path: '/verify-2fa',
      builder: (context, state) {
        final request = state.extra as UserModel;
        return Verify2faScreen(request: request);
      },
    ),
    GoRoute(
      path: '/signup-success',
      builder: (context, state) {
        final request = state.extra as SignUpRequest;
        return SignupSuccessScreen(request: request);
      },
    ),
    GoRoute(
      path: '/signin',
      pageBuilder:
          (context, state) => const NoTransitionPage(child: SignInScreen()),
    ),
    GoRoute(
      path: '/biometric-login',
      builder: (context, state) => const BiometricLoginScreen(),
    ),
    GoRoute(
      path: '/passcode-login',
      builder: (context, state) => const PasscodeLoginScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/forgot-password-verification',
      builder: (context, state) {
        final request = state.extra as UsernameRequest;
        return ForgotPasswordVerificationScreen(request: request);
      },
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final request = state.extra as UsernameRequest;
        return ResetPasswordScreen(request: request);
      },
    ),

    // Dashboard shell route with bottom navigation
    ShellRoute(
      builder: (context, state, child) => DashboardWrapper(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Homescreen()),
        GoRoute(
          path: '/finance',
          builder: (context, state) => const FinanceMainScreen(),
        ),

        GoRoute(
          path: '/cards',
          builder: (context, state) => const CardsScreen(),
        ),
        GoRoute(
          path: '/get-phisical-card',
          builder: (context, state) => const GetPhysicalCardScreen(),
        ),
        GoRoute(
          path: '/vcard/create',
          builder: (context, state) => const CreateVCardScreen(),
        ),
        GoRoute(
          path: '/vcard/details/:cardId',
          builder: (context, state) {
            final cardId = state.pathParameters['cardId']!;
            return VCardDetailsScreen(cardId: cardId);
          },
        ),
        GoRoute(
          path: '/vcard/manage/:cardId',
          builder: (context, state) {
            final cardId = state.pathParameters['cardId']!;
            return VCardManagementScreen(cardId: cardId);
          },
        ),
        GoRoute(
          path: '/vcard/transactions/:cardId',
          builder: (context, state) {
            final cardId = state.pathParameters['cardId']!;
            return VCardTransactionsScreen(cardId: cardId);
          },
        ),
        GoRoute(
          path: '/vcard/fund/:cardId',
          builder: (context, state) {
            final cardId = state.pathParameters['cardId']!;
            return FundVCardScreen(cardId: cardId);
          },
        ),
        GoRoute(
          path: '/vcard/withdraw/:cardId',
          builder: (context, state) {
            final cardId = state.pathParameters['cardId']!;
            return WithdrawVCardScreen(cardId: cardId);
          },
        ),
        GoRoute(path: '/me', builder: (context, state) => const MeScreen()),
      ],
    ),

    // Standalone routes (without dashboard wrapper)
    GoRoute(
      path: '/coming-soon',
      builder: (context, state) => const ComingSoonScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/notification-settings',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: '/customer-service',
      builder: (context, state) => const CustomerServiceScreen(),
    ),
    GoRoute(
      path: '/report-scam',
      builder: (context, state) => const ReportScamScreen(),
    ),
    GoRoute(
      path: '/decode-qrcode',
      builder: (context, state) => const DecodeQrCodeScreen(),
    ),
    GoRoute(path: '/faq', builder: (context, state) => const FAQScreen()),
    GoRoute(
      path: '/visit-office',
      builder: (context, state) => const VisitOfficeScreen(),
    ),
    GoRoute(
      path: '/security-tips',
      builder: (context, state) => const SecurityTipsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/security-centre',
      builder: (context, state) => const SecuritySettingsScreen(),
    ),
    GoRoute(
      path: '/about-us',
      builder: (context, state) => const AboutUsPage(),
    ),
    GoRoute(
      path: '/security-settings',
      builder: (context, state) => const SecuritySettingsScreen(),
    ),
    GoRoute(
      path: '/login-settings',
      builder: (context, state) => const LoginSettingsScreen(),
    ),
    GoRoute(
      path: '/transaction-pin-settings',
      builder: (context, state) => const TransactionPinSettingsScreen(),
    ),
    GoRoute(
      path: '/finance-settings',
      builder: (context, state) => const FinanceSettingsScreen(),
    ),
    GoRoute(
      path: '/change-pin',
      builder: (context, state) => const ChangePinScreen(),
    ),
    GoRoute(
      path: '/forgot-pin',
      builder: (context, state) => const ForgotPinScreen(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/auto-logout-settings',
      builder: (context, state) => const AutoLogoutSettingsScreen(),
    ),
    GoRoute(
      path: '/create-passcode',
      builder: (context, state) => const CreatePasscodeScreen(),
    ),
    GoRoute(
      path: '/change-passcode',
      builder: (context, state) => const ChangePassCodeScreen(),
    ),
    GoRoute(
      path: '/my-rewards',
      builder: (context, state) => const MyRewardsPage(),
    ),
    GoRoute(
      path: '/rate-app',
      builder: (context, state) => const RateAppScreen(),
    ),
    GoRoute(
      path: '/my-portfolio',
      builder: (context, state) => const MyPortfolioPage(),
    ),
    // Profile routes
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/personal-details-view',
      builder: (context, state) => const profile.PersonalDetailsScreen(),
    ),
    GoRoute(
      path: '/contact-details-view',
      builder: (context, state) => const ContactDetailsScreen(),
    ),
    GoRoute(
      path: '/address-view',
      builder: (context, state) => const AddressScreen(),
    ),
    GoRoute(
      path: '/change-phone-number',
      builder: (context, state) => const ChangeMobileNumberScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    // Services routes
    GoRoute(
      path: '/airtime',
      builder: (context, state) => const AirtimeScreen(),
    ),
    GoRoute(path: '/data', builder: (context, state) => const DataScreen()),
    GoRoute(
      path: '/schedule-topup',
      builder: (context, state) => const ScheduleTopupScreen(),
    ),
    GoRoute(
      path: '/data-ussd-section',
      builder: (context, state) => const DataUSSDEnquiryScreen(),
    ),
    GoRoute(
      path: '/ussd-enquiry',
      builder: (context, state) => const USSDEnquiryScreen(),
    ),
    GoRoute(
      path: '/all-services',
      builder: (context, state) => const AllServicesScreen(),
    ),
    GoRoute(
      path: '/finance/savings/fixed/plans',
      builder: (context, state) => const FixedDepositListScreen(),
    ),
    GoRoute(
      path: '/finance/savings/target/plans',
      builder: (context, state) => const TargetSavingsScreen(),
    ),
    GoRoute(
      path: '/finance/easylife/intro',
      builder: (context, state) => const EasyLifeListScreen(),
    ),
    GoRoute(
      path: '/finance/easylife/create',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CreateEasyLifePlanScreen(
          initialName: extra?['name'],
          initialAmount: extra?['amount'],
        );
      },
    ),
    GoRoute(
      path: '/finance/fixed-deposit/plans',
      builder: (context, state) => const FixedDepositListScreen(),
    ),
    GoRoute(
      path: '/finance/fixed-deposit/create',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CreateFixedDepositScreen(
          initialAmount: extra?['amount'],
        );
      },
    ),
    GoRoute(
      path: '/finance/savings/create/:type',
      builder: (context, state) {
        final type = state.pathParameters['type']!;
        final extra = state.extra as Map<String, dynamic>?;
        return CreateSavingsPlanScreen(
          type: type,
          initialTargetType: extra?['targetType'],
          initialAmount: extra?['amount'],
        );
      },
    ),
    GoRoute(
      path: '/finance/savings/details/:planId',
      builder: (context, state) {
        final planId = state.pathParameters['planId']!;
        return SavingsDetailsScreen(planId: planId);
      },
    ),
    GoRoute(
      path: '/finance/easylife/details/:planId',
      builder: (context, state) {
        final planId = state.pathParameters['planId']!;
        return EasyLifeDetailsScreen(planId: planId);
      },
    ),
    GoRoute(
      path: '/finance/fixed-deposit/details/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return FixedDepositDetailsScreen(depositId: id);
      },
    ),
    GoRoute(
      path: '/finance/investment/list',
      builder: (context, state) => const MyInvestmentsScreen(),
    ),
    GoRoute(
      path: '/decode-qrcode',
      builder: (context, state) => const DecodeQrCodeScreen(),
    ),

    // Me section routes
    GoRoute(
      path: '/transaction-history',
      builder: (context, state) => const TransactionHistoryPage(),
    ),
    GoRoute(
      path: '/transaction-details',
      builder: (context, state) {
        final transaction = state.extra as TransactionModel;
        return FinanceTransactionDetailsScreen(transaction: transaction);
      },
    ),
    GoRoute(
      path: '/account-settings',
      builder: (context, state) => const AccountSettingsPage(),
    ),
    GoRoute(
      path: '/account-statement',
      builder: (context, state) => const AccountStatementPage(),
    ),
    GoRoute(path: '/themes', builder: (context, state) => const ThemesPage()),

    // Notification routes
    GoRoute(
      path: '/notification-view',
      builder: (context, state) {
        final Map<String, String> data =
            state.extra as Map<String, String>? ??
            {'title': 'Notification', 'content': 'No content'};
        return NotificationViewScreen(
          title: data['title']!,
          content: data['content']!,
        );
      },
    ),

    // FAQ Detail route
    GoRoute(
      path: '/faq-detail',
      builder: (context, state) {
        final Map<String, String> data =
            state.extra as Map<String, String>? ??
            {'question': 'FAQ', 'answer': 'No answer available'};
        return FAQDetailScreen(
          question: data['question']!,
          answer: data['answer']!,
        );
      },
    ),
    GoRoute(
      path: '/electricity',
      builder: (context, state) => const ElectricityScreen(),
    ),
    GoRoute(
      path: '/flight',
      builder: (context, state) => const FlightSelectionScreen(),
    ),
    GoRoute(
      path: '/swap-currency',
      builder: (context, state) => const SwapCurrencyScreen(),
    ),
    // GoRoute(
    //   path: '/insurance',
    //   builder: (context, state) => const InsuranceScreen(),
    // ),
    GoRoute(
      path: '/international-airtime',
      builder: (context, state) => const InternationalAirtimeScreen(),
    ),
    GoRoute(
      path: '/education',
      builder: (context, state) => const EducationScreen(),
    ),
    GoRoute(
      path: '/internet',
      builder: (context, state) => const InternetScreen(),
    ),
    GoRoute(
      path: '/transfer-to-valarpay',
      builder: (context, state) => const TransferToValarPayScreen(),
    ),
    GoRoute(
      path: '/transfer-to-bank',
      builder: (context, state) => const TransferToBankScreen(),
    ),
    GoRoute(
      path: '/withdraw',
      builder: (context, state) => const WithdrawScreen(),
    ),
    GoRoute(
      path: '/withdraw-via-bank',
      builder: (context, state) => const WithdrawBankBranchScreen(),
    ),
    GoRoute(
      path: '/withdraw-via-marchant',
      builder: (context, state) => const WithdrawMerchantScreen(),
    ),
    GoRoute(
      path: '/account',
      builder: (context, state) => const AccountScreen(),
    ),
    GoRoute(
      path: '/account-setup',
      builder: (context, state) => const AccountSetupScreen(),
    ),
    GoRoute(
      path: '/upgrade-kyc',
      builder: (context, state) => const UpgradeKycScreen(),
    ),
    GoRoute(
      path: '/proof-of-address',
      builder: (context, state) {
        final addressRequest = state.extra as KycAddressRequest;
        return ProofOfAddressPage(addressRequest: addressRequest);
      },
    ),
    GoRoute(
      path: '/kyc-review-progress',
      builder: (context, state) => const KycReviewProgressScreen(),
    ),
    GoRoute(
      path: '/add-money',
      builder: (context, state) => const AddMoneyScreen(),
    ),
    GoRoute(
      path: '/add-money-via-transfer',
      builder: (context, state) => const AddMoneyTransferScreen(),
    ),
    GoRoute(
      path: '/add-money-via-qrcode',
      builder: (context, state) => const AddMoneyQRCode(),
    ),
    GoRoute(
      path: '/close-account',
      builder: (context, state) => const CloseAccountScreen(),
    ),
    GoRoute(
      path: '/cable-tv',
      builder: (context, state) => const CableTvScreen(),
    ),

    GoRoute(
      path: '/betting',
      builder: (context, state) => const BettingScreen(),
    ),
    // GoRoute(
    //   path: '/shopping',
    //   builder: (context, state) => const ShoppingScreen(),
    // ),
    GoRoute(
      path: '/gift-card',
      builder: (context, state) => const GiftCardScreen(),
    ),
    GoRoute(
      path: '/terms-and-conditions',
      builder: (context, state) => const TermsAndConditionsScreen(),
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/finance-intro',
      builder: (context, state) => const FinanceIntroScreen(),
    ),
    GoRoute(
      path: '/invest',
      builder: (context, state) => const InvestmentIntroScreen(),
    ),
    GoRoute(
      path: '/finance/investment/intro',
      builder: (context, state) => const InvestmentIntroScreen(),
    ),
    GoRoute(
      path: '/finance/investment/create',
      builder: (context, state) => const CreateInvestmentScreen(),
    ),
    GoRoute(
      path: '/finance/investment/details/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return InvestmentDetailsScreen(investmentId: id);
      },
    ),
  ],
);

