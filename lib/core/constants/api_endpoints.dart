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

  // KYC - SmileID Verification
  static const String verifyBvn = '/api/v1/user/smileid/basic-kyc'; // alias for old verifyBvn
  static const String basicKyc = '/api/v1/user/smileid/basic-kyc';
  static const String biometricKyc = '/api/v1/user/smileid/smart-selfie-register';
  static const String smartSelfieAuth = '/api/v1/user/smileid/smart-selfie-auth';
  static String smileIdJobStatus(String jobId) => '/api/v1/user/smileid/job-status/$jobId';
  static const String verifyNin = '/api/v1/user/verify-nin';
  static const String kycTier2 = '/api/v1/user/kyc-tier2';

  // KYC - Address Verification (Tier 3) NO LONGER USED (Replaced by uploadTier3Document)

  // Wallet - Transaction PIN
  static const String setWalletPin = '/api/v1/user/set-wallet-pin';
  static const String verifyWalletPin = '/api/v1/user/verify-wallet-pin';
  static const String forgotWalletPin = '/api/v1/user/forget-pin';
  static const String resetWalletPin = '/api/v1/user/reset-pin';

  // User Profile
  static const String getUserProfile = '/api/v1/user/me';
  static const String createPasscode = '/api/v1/user/create-passcode';
  static const String editProfile = '/api/v1/user/edit-profile';
  static const String uploadDocument = '/api/v1/user/upload-document';
  static const String uploadTier3Document = '/api/v1/user/upload-tier3-document';
  static const String uploadCacDocument = '/api/v1/user/upload-cac-document';
  static const String getUserTier = '/api/v1/user/tier';

  static const String getAllTransactions = '/api/v1/wallet/transaction';

  // Support endpoints
  static const String reportScam = '/api/v1/user/report-scam';
  static const String changePasscode = '/api/v1/user/change-passcode';
  static const String changePassword = '/api/v1/user/change-password';

  // Bill payment endpoints
  static const String getAirtimeNetworkProviders =
      '/api/v1/bill/airtime/network-providers';
  static const String getAirtimePlan = '/api/v1/bill/airtime/get-plan';
  static const String getAirtimeVariation =
      '/api/v1/bill/airtime/palmpay/get-items';
  static const String payAirtime = '/api/v1/bill/airtime/pay';
  static const String getDataNetworkProviders =
      '/api/v1/bill/airtime/network-providers';
  static const String getDataPlan = '/api/v1/bill/data/get-plan';
  static String getDataPlanByNetwork(String network) => '/api/v1/bill/data/get-plan/$network';
  static const String getDataVariation = '/api/v1/bill/data/palmpay/get-items';
  static const String purchaseData = '/api/v1/bill/data/pay';

  // Cable TV endpoints
  static const String getCablePlan = '/api/v1/bill/remita/paytv/get-plan';
  static const String getCableVariation = '/api/v1/bill/remita/paytv/get-bill-info';
  static const String getCableBillInfo = '/api/v1/bill/remita/paytv/get-bill-info';
  static const String verifyCableNumber = validateRemitaCustomer;
  static const String payCable = '/api/v1/bill/remita/paytv/pay';

  // Internet endpoints
  static const String getInternetPlan = '/api/v1/bill/remita/internet/get-plan';
  static const String getInternetBillInfo =
      '/api/v1/bill/remita/internet/get-bill-info';
  static const String payInternet = '/api/v1/bill/remita/internet/pay';

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
  static const String getElectricityPlan = '/api/v1/bill/remita/electricity/get-plan';
  static const String getElectricityVariation = '/api/v1/bill/remita/electricity/get-variation';
  static const String getElectricityBillInfo =
      '/api/v1/bill/remita/electricity/get-bill-info';
  static const String verifyMeterNumber = validateRemitaCustomer;
  static const String payElectricity = '/api/v1/bill/remita/electricity/pay';

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
  static const String convertCurrency = '/api/v1/currency/eversend/exchange';
  static const String getCurrencyRates = '/api/v1/currency/rates';
  static const String getSupportedCurrencies = '/api/v1/currency/supported';
  static const String createCurrencyAccount = '/api/v1/currency/accounts';
  static const String payazaMainAccount = '/api/v1/currency/payaza/main-account';
  static const String verifyPayazaAccount = '/api/v1/currency/payaza/accounts/verify';
  static const String payazaCardCharge = '/api/v1/currency/payaza/collections/card/charge';
  static const String payazaCardCheck3DS = '/api/v1/currency/payaza/collections/card/check-3ds';
  static const String payazaCardTransactionStatus = '/api/v1/currency/payaza/collections/card/transaction-status';
  static const String payazaCardRefundStatus = '/api/v1/currency/payaza/collections/card/refund-status';
  static const String payazaCardTokenize = '/api/v1/currency/payaza/collections/card/tokenize';
  static const String payazaCardChargeWithToken = '/api/v1/currency/payaza/collections/card/charge-with-token';
  static const String payazaCardTokens = '/api/v1/currency/payaza/collections/card/tokens';
  static String payazaDeleteCardToken(String tokenId) => '/api/v1/currency/payaza/collections/card/tokens/$tokenId';
  static const String payazaMobileInitiate = '/api/v1/currency/payaza/collections/mobile/initiate';
  static const String payazaVirtualAccounts = '/api/v1/currency/payaza/virtual-accounts';
  static String payazaVirtualAccountDetails(String number) => '/api/v1/currency/payaza/virtual-accounts/$number';
  static const String payazaExchangeQuotation = '/api/v1/currency/payaza/exchange/quotation';
  static const String payazaExchangeExecute = '/api/v1/currency/payaza/exchange/execute';
  static const String payazaWallets = '/api/v1/currency/payaza/wallets';
  static String payazaWalletDetails(String id) => '/api/v1/currency/payaza/wallets/$id';
  static const String createPayazaPayout = '/api/v1/currency/payaza/payouts';
  static String payazaPayoutStatus(String ref) => '/api/v1/currency/payaza/payouts/$ref/status';
  static const String getUserAccounts = '/api/v1/currency/accounts';
  static String getAccountByCurrency(String currency) => '/api/v1/currency/accounts/$currency';
  static String updateAccount(String currency) => '/api/v1/currency/accounts/$currency';
  static String closeAccount(String currency) => '/api/v1/currency/accounts/$currency';
  static String getAccountTransactions(String currency) => '/api/v1/currency/accounts/$currency/transactions';
  static String getAccountDeposits(String currency) => '/api/v1/currency/accounts/$currency/deposits';
  static String createMockDeposit(String currency) => '/api/v1/currency/accounts/$currency/deposits/mock';
  static String createPayoutDestination(String currency) => '/api/v1/currency/accounts/$currency/payout-destinations';
  static String getPayoutDestinations(String currency) => '/api/v1/currency/accounts/$currency/payout-destinations';
  static String createPayout(String currency) => '/api/v1/currency/accounts/$currency/payouts';
  static String getPayouts(String currency) => '/api/v1/currency/accounts/$currency/payouts';

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
  static const String paySchoolFees = '/api/v1/bill/remita/vending/pay';

  // JAMB & WAEC endpoints
  static const String getVendingProviders = '/api/v1/bill/remita/vending/providers';
  static const String getVendingProducts = '/api/v1/bill/remita/vending/products';
  static const String verifyWaecBillerNumber = '/api/v1/bill/remita/waec/verify-biller-number';
  static const String payWaec = '/api/v1/bill/waec/pay';
  static const String verifyJambBillerNumber = '/api/v1/bill/remita/jamb/verify-biller-number';
  static const String payJamb = '/api/v1/bill/jamb/pay';

  // Remita Bill Payment endpoints
  static const String getRemitaCategories = '/api/v1/bill/remita/categories';
  static String getRemitaPlan(String categoryId) => '/api/v1/bill/remita/$categoryId/get-plan';
  static String getRemitaBillerProducts(String billerId) => '/api/v1/bill/remita/biller/$billerId/products';
  static const String validateRemitaCustomer = '/api/v1/bill/remita/biller/validate-customer';
  static const String initiateRemitaPayment = '/api/v1/bill/remita/biller/initiate';
  static const String payRemitaBill = '/api/v1/bill/remita/biller/pay';
  static const String getRemitaVendingProducts = '/api/v1/bill/remita/vending/products';

  // Card Linking endpoints
  static const String getCardLinkProviders = '/api/v1/cards/link/providers';
  static const String initiateCardLink = '/api/v1/cards/link/initiate';
  static const String getLinkedCards = '/api/v1/cards';
  static String chargeLinkedCard(String id) => '/api/v1/cards/$id/charge';
  static String disableLinkedCard(String id) => '/api/v1/cards/$id/disable';

  // Flutterwave Bill payment endpoints
  static const String getFlutterwaveCategories = '/api/v1/bill/flutterwave/categories';
  static String getFlutterwaveBillers(String categoryCode) =>
      '/api/v1/bill/flutterwave/categories/$categoryCode/billers';
  static const String getFlutterwaveBillInfo = '/api/v1/bill/get-bill-info';
  static String payFlutterwaveBill(String category) =>
      '/api/v1/bill/$category/pay';
  static const String verifyFlutterwaveCable =
      '/api/v1/bill/flutterwave/cable/verify-cable-number';
  static const String verifyFlutterwaveElectricity =
      '/api/v1/bill/flutterwave/electricity/verify-meter-number';
  static const String validateFlutterwaveCustomer =
      '/api/v1/bill/flutterwave/validate-customer';

  // CoralPay Bill Payment endpoints
  static const String getCoralPayGroups = '/api/v1/bill/coralpay/groups';
  static String getCoralPayBillers(String groupSlug) =>
      '/api/v1/bill/coralpay/billers/$groupSlug';
  static String getCoralPayPackages(String billerSlug) =>
      '/api/v1/bill/coralpay/packages?billerSlug=$billerSlug';
  static const String verifyCoralPayCustomer =
      '/api/v1/bill/coralpay/verify-customer';
  static const String payCoralPayBill = '/api/v1/bill/coralpay/pay';
  static const String getPopularCoralPayBillers =
      '/api/v1/bill/coralpay/popular-billers';
  static const String getCoralPayTransaction =
      '/api/v1/bill/coralpay/transaction';

  // future endpoints can go here
}
