class ApiEndpoints {
  //auth apis
  static const String login = '/api/v1/auth/login';
  static const String loginWithPasscode = '/api/v1/auth/passcode-login';
  static const String resend2fa = '/api/v1/auth/resend-2fa';
  static const String verify2fa = '/api/v1/auth/verify-2fa';
  //user api
  static const String existanceCheck = '/api/v1/user/existance-check';
  static const String register = '/api/v1/user/register';
  static const String registerBusiness = '/api/v1/user/register-business';
  static const String verifyEmail = '/api/v1/user/verify-email';
  static const String validateEmail = '/api/v1/user/validate-email';
  static const String verifyPhone = '/api/v1/user/verify-phonenumber';
  static const String validatePhone = '/api/v1/user/validate-phonenumber';
  static const String forgotPassword = '/api/v1/user/forgot-password';
  static const String resetPassword = '/api/v1/user/reset-password';
  static const String verifyForgotPassword =
      '/api/v1/user/verify-forgot-password';

  // KYC - BVN Verification
  static const String verifyBvn = '/api/v1/wallet/bvn-verification';

  // KYC - NIN Verification (Tier 2)
  static const String verifyNin = '/api/v1/user/verify-nin';
  static const String kycTier2 = '/api/v1/user/kyc-tier2';

  // KYC - Address Verification (Tier 3)
  static const String kycTier3 = '/api/v1/user/kyc-tier3';

  // Wallet - Transaction PIN
  static const String setWalletPin = '/api/v1/user/set-wallet-pin';
  static const String verifyWalletPin = '/api/v1/user/verify-wallet-pin';
  static const String forgotWalletPin = '/api/v1/user/forget-pin';
  static const String resetWalletPin = '/api/v1/user/reset-pin';

  // User Profile
  static const String getUserProfile = '/api/v1/user/me';
  static const String createPasscode = '/api/v1/user/create-passcode';
  static const String editProfile = '/api/v1/user/edit-profile';

  static const String getAllTransactions = '/api/v1/wallet/transaction';

  // Support endpoints
  static const String reportScam = '/api/v1/user/report-scam';
  static const String changePasscode = '/api/v1/user/change-passcode';
  static const String changePassword = '/api/v1/user/change-password';

  // Bill payment endpoints
  static const String getAirtimeNetworkProviders =
      '/api/v1/bill/airtime/network-providers';
  static const String getAirtimePlan = '/api/v1/bill/airtime/palmpay/get-plan';
  static const String getAirtimeVariation =
      '/api/v1/bill/airtime/palmpay/get-items';
  static const String payAirtime = '/api/v1/bill/airtime/palmpay/pay';
  static const String getDataNetworkProviders =
      '/api/v1/bill/data/network-providers';
  static const String getDataPlan = '/api/v1/bill/data/palmpay/get-plan';
  static const String getDataVariation = '/api/v1/bill/data/palmpay/get-items';
  static const String purchaseData = '/api/v1/bill/data/palmpay/pay';

  // Cable TV endpoints
  static const String getCablePlan = '/api/v1/bill/cable/get-plan';
  static const String getCableVariation = '/api/v1/bill/cable/get-bill-info';
  static const String getCableBillInfo = '/api/v1/bill/cable/get-bill-info';
  static const String verifyCableNumber =
      '/api/v1/bill/cable/verify-cable-number';
  static const String payCable = '/api/v1/bill/cable/pay';

  // Internet endpoints
  static const String getInternetPlan = '/api/v1/bill/internet/get-plan';
  static const String getInternetBillInfo =
      '/api/v1/bill/internet/get-bill-info';
  static const String payInternet = '/api/v1/bill/internet/pay';

  // International airtime endpoints
  static const String getInternationalFxRate =
      '/api/v1/bill/airtime/international/get-fx-rate';
  static const String getInternationalPlan =
      '/api/v1/bill/airtime/international/get-plan';
  static const String payInternationalAirtime =
      '/api/v1/bill/airtime/international/pay';
  static const String getInternationalCountries =
      '/api/v1/bill/airtime/international/get-countries';
  static const String getInternationalBalance =
      '/api/v1/bill/airtime/international/get-balance';

  // Giftcard endpoints
  static const String getGiftCardCategories =
      '/api/v1/bill/giftcard/get-categories';
  static const String getGiftCardProducts = '/api/v1/bill/giftcard/get-product';
  static const String payGiftCard = '/api/v1/bill/giftcard/pay';
  static const String getGiftCardRedeemCode =
      '/api/v1/bill/giftcard/get-redeem-code';
  static const String getGiftCardFxRate = '/api/v1/bill/giftcard/get-fx-rate';

  // Electricity endpoints
  static const String getElectricityPlan = '/api/v1/bill/electricity/get-plan';
  static const String getElectricityVariation = '/api/v1/bill/electricity/get-variation';
  static const String getElectricityBillInfo =
      '/api/v1/bill/electricity/get-bill-info';
  static const String verifyMeterNumber =
      '/api/v1/bill/electricity/verify-meter-number';
  static const String payElectricity = '/api/v1/bill/electricity/pay';

  // Beneficiary endpoints
  static const String getUserBeneficiaries = '/api/v1/user/get-beneficiaries';

  // Transfer endpoints
  static const String getBanks = '/api/v1/wallet/get-banks';
  static const String getMatchedBanks = '/api/v1/wallet/get-matched-banks';
  static const String getTransferFee = '/api/v1/wallet/get-transfer-fee';
  static const String getBeneficiaries = '/api/v1/user/get-beneficiaries';
  static const String initiateTransfer = '/api/v1/wallet/initiate-transfer';
  static const String verifyAccount = '/api/v1/wallet/verify-account';
  static const String getTransactions = '/api/v1/wallet/transaction';
  static const String generateQRCode = '/api/v1/wallet/generate-qrcode';
  static const String decodeQRCode = '/api/v1/wallet/decode-qrcode';
  static const String convertCurrency = '/api/v1/currency/convert';
  static const String getCurrencyRates = '/api/v1/currency/rates';
  static const String getSupportedCurrencies = '/api/v1/currency/supported';

  // Notification endpoints
  static const String getNotifications = '/api/v1/notification';
  static const String getNotificationCount = '/api/v1/notification/unread-count';
  static const String markNotificationAsRead = '/api/v1/notification';
  //static const String deleteNotification = '/api/v1/notification';
  static const String registerDevice = '/api/v1/notification/devices';
  static const String notificationPreferences =
      '/api/v1/notification/preferences';

  // Savings endpoints
  static const String getSavingsProducts = '/api/v1/savings/products';
  static const String savingsPlans = '/api/v1/savings/plans';
  static const String fundSavingsPlan = '/api/v1/savings/plans/fund';
  static String withdrawSavingsPlan(String planId) =>
      '/api/v1/savings/plans/$planId/withdraw';
  static String getSavingsPlanDetails(String planId) =>
      '/api/v1/savings/plans/$planId';

  // EasyLife Savings endpoints
  static const String getEasyLifeProduct = '/api/v1/easylife-savings/product';
  static const String easyLifePlans = '/api/v1/easylife-savings/plans';
  static const String fundEasyLifePlan = '/api/v1/easylife-savings/plans/fund';
  static String withdrawEasyLifePlan(String planId) =>
      '/api/v1/easylife-savings/plans/$planId/withdraw';
  static String getEasyLifePlanDetails(String planId) =>
      '/api/v1/easylife-savings/plans/$planId';

  // Fixed Deposit endpoints
  static const String getFixedDepositPlans = '/api/v1/fixed-deposits/plans';
  static const String fixedDeposits = '/api/v1/fixed-deposits';
  static const String earlyWithdrawFixedDeposit =
      '/api/v1/fixed-deposits/early-withdrawal';
  static String payoutFixedDeposit(String id) =>
      '/api/v1/fixed-deposits/$id/payout';
  static const String rolloverFixedDeposit = '/api/v1/fixed-deposits/rollover';

  // Investment endpoints
  static const String getInvestmentProduct = '/api/v1/investment/product';
  static const String investments = '/api/v1/investment';
  static String getInvestmentDetails(String id) => '/api/v1/investment/$id';

  // Betting endpoints
  static const String getBettingPlatforms = '/api/v1/betting/palmpay/platforms';
  static const String payBetting = '/api/v1/betting/palmpay/pay';

  // Education endpoints
  static const String getSchoolBillers = '/api/v1/bill/education/billers';
  static const String getRemitaSchoolBillers = '/api/v1/bill/remita/school/billers';
  static const String getSchoolBillInfo = '/api/v1/bill/school/get-bill-info';
  static const String getEducationBillerItems = '/api/v1/bill/remita/education/biller-items';
  static const String verifySchoolCustomer = '/api/v1/bill/remita/education/verify-customer';
  static const String verifyRemitaSchoolBillerNumber = '/api/v1/bill/remita/school/verify-biller-number';
  static const String paySchoolFees = '/api/v1/bill/school/pay';
  static const String payEducationSchoolFee = '/api/v1/bill/education/school-fee/pay';

  // JAMB & WAEC endpoints
  static const String getVendingProviders = '/api/v1/bill/remita/vending/providers';
  static const String getVendingProducts = '/api/v1/bill/remita/vending/products';
  static const String verifyWaecBillerNumber = '/api/v1/bill/remita/waec/verify-biller-number';
  static const String payWaec = '/api/v1/bill/waec/pay';
  static const String verifyJambBillerNumber = '/api/v1/bill/remita/jamb/verify-biller-number';
  static const String payJamb = '/api/v1/bill/jamb/pay';

  // future endpoints can go here
}
