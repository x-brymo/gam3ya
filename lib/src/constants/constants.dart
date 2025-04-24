class AppConstants {
  // App Info
  static const String appName = 'جمعيتي - MyGam3ya';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // API and Firebase Settings
  static const int apiTimeoutSeconds = 30;
  static const String firebaseCollection_Users = 'users';
  static const String firebaseCollection_Gam3yas = 'gam3yas';
  static const String firebaseCollection_Payments = 'payments';
  static const String firebaseCollection_Notifications = 'notifications';
  
  // Validation Rules
  static const int minPasswordLength = 6;
  static const int minGam3yaNameLength = 3;
  static const int maxGam3yaNameLength = 50;
  static const int minGam3yaDescriptionLength = 10;
  static const int maxGam3yaDescriptionLength = 500;
  static const double minGam3yaAmount = 100;
  static const double maxGam3yaAmount = 1000000;
  static const int minGam3yaMembers = 2;
  static const int maxGam3yaMembers = 50;
  
  // Reputation System
  static const int initialReputationScore = 100;
  static const int reputationIncreaseOnTimePayment = 5;
  static const int reputationDecreaseLatePenalty = 10;
  static const int reputationDecreaseMissedPenalty = 20;
  
  // Date Format Patterns
  static const String dateFormatPattern = 'yyyy-MM-dd';
  static const String dateTimeFormatPattern = 'yyyy-MM-dd HH:mm';
  static const String timeFormatPattern = 'HH:mm';
  
  // Safety Fund Settings
  static const double defaultSafetyFundPercentage = 5.0;
  
  // QR Code Settings
  static const int qrCodeSize = 200;
  static const String qrCodePrefix = 'GAM3YA_PAY:';
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 250);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // Cache Settings
  static const Duration cacheDuration = Duration(hours: 24);
  static const String cacheKey_UserProfile = 'user_profile';
  static const String cacheKey_ActiveGam3yas = 'active_gam3yas';
  
  // Pagination Settings
  static const int paginationLimit = 10;
  
  // Notification Channels
  static const String notificationChannel_General = 'general_notifications';
  static const String notificationChannel_Payments = 'payment_notifications';
  static const String notificationChannel_Turns = 'turn_notifications';
  
  // Keys for Shared Preferences
  static const String prefKey_Theme = 'app_theme';
  static const String prefKey_Language = 'app_language';
  static const String prefKey_PushNotifications = 'push_notifications';
  static const String prefKey_BioAuth = 'biometric_authentication';
  static const String prefKey_LastSync = 'last_sync_time';
  
  // Error Messages
  static const String errorMessage_NetworkError = 'Network connection error. Please check your internet connection and try again.';
  static const String errorMessage_ServerError = 'Server error occurred. Please try again later.';
  static const String errorMessage_AuthFailed = 'Authentication failed. Please check your credentials and try again.';
  static const String errorMessage_PermissionDenied = 'You do not have permission to perform this action.';
  static const String errorMessage_InvalidInput = 'Invalid input. Please check the information and try again.';
  static const String errorMessage_PaymentFailed = 'Payment processing failed. Please try again later.';
  
  // Success Messages
  static const String successMessage_PaymentReceived = 'Payment received successfully.';
  static const String successMessage_Gam3yaCreated = 'Gam3ya created successfully and is pending approval.';
  static const String successMessage_ProfileUpdated = 'Profile updated successfully.';
  static const String successMessage_JoinedGam3ya = 'You have successfully joined the Gam3ya.';
  
  // Security
  static const String encryptionKey = 'gam3ya_secure_encryption_key';
  static const int tokenExpiryDays = 30;
  
  // Local Data Paths
  static const String localUserDataPath = 'users';
  static const String localGam3yaDataPath = 'gam3yas';
  static const String localMediaPath = 'media';
  
  // Documentation Links
  static const String helpCenterUrl = 'https://mygam3ya.com/help';
  static const String termsAndConditionsUrl = 'https://mygam3ya.com/terms';
  static const String privacyPolicyUrl = 'https://mygam3ya.com/privacy';
  
  // Feature Flags
  static const bool enableBiometricAuth = true;
  static const bool enableP2PSync = true;
  static const bool enablePushNotifications = true;
  static const bool enableInAppChat = true;
  static const bool enableReputationSystem = true;
  static const bool enableGuarantorSystem = true;
  static const bool enableQRCodePayments = true;
  
  // Nearby Connection Strategy
  static const String nearbyConnectionStrategy = 'P2P_STAR';
  static const String nearbyConnectionServiceId = 'com.mygam3ya.nearby';
  
  // App Colors (HEX)
  static const String colorPrimary = '#2E7D32';
  static const String colorSecondary = '#00796B';
  static const String colorAccent = '#FFB74D';
  static const String colorBackground = '#F5F5F5';
  static const String colorError = '#D32F2F';
  
  // Asset Paths
  static const String assetPathLogo = 'assets/images/logo.png';
  static const String assetPathPlaceholder = 'assets/images/placeholder.png';
  static const String assetPathOnboarding1 = 'assets/images/onboarding_1.png';
  static const String assetPathOnboarding2 = 'assets/images/onboarding_2.png';
  static const String assetPathOnboarding3 = 'assets/images/onboarding_3.png';
  // App Theme
  static const String themeLight = 'light';
  static const String themeDark = 'dark';
  static const String themeSystem = 'system';
  
  // Language Codes
  static const String languageEnglish = 'en';
  static const String languageArabic = 'ar';
  
  // Supported Languages
  static const List<String> supportedLanguages = [languageEnglish, languageArabic];
  
  // Default Language
  static const String defaultLanguage = languageEnglish;
  
  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleMember = 'member';
  // usersCollection
  static const String usersCollection = 'users';
  static const String gam3yasCollection = 'gam3yas';
  static const String paymentsCollection = 'payments';
  static const String notificationsCollection = 'notifications';
  static const String settingsCollection = 'settings';
  static const String transactionsCollection = 'transactions';
  static const String userSettingsCollection = 'user_settings';
  static const String userNotificationsCollection = 'user_notifications';
  // usersBox hive
  static const String usersBox = 'users';
  static const String gam3yasBox = 'gam3yas';
  static const String paymentsBox = 'payments';
  static const String notificationsBox = 'notifications';
  static const String settingsBox = 'appSettings';
  // defaultReputationScore
  static const int defaultReputationScore = 100;
  // defaultGam3yaDuration
  static const int defaultGam3yaDuration = 30; // in days
}