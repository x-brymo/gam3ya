// config/routes.dart
import 'package:flutter/material.dart';
import 'package:gam3ya/src/views/admin/admin_dashboard.dart';
import 'package:gam3ya/src/views/admin/analytics_screen.dart';
import 'package:gam3ya/src/views/admin/manage_gam3yas_screen.dart';
import 'package:gam3ya/src/views/admin/manage_users_screen.dart';
import 'package:gam3ya/src/views/auth/forgot_password_screen.dart';
import 'package:gam3ya/src/views/auth/login_screen.dart';
import 'package:gam3ya/src/views/auth/signup_screen.dart';
import 'package:gam3ya/src/views/gam3ya/create_gam3ya_screen.dart';
import 'package:gam3ya/src/views/gam3ya/gam3ya_detail_screen.dart';
import 'package:gam3ya/src/views/gam3ya/gam3ya_list_screen.dart';
import 'package:gam3ya/src/views/gam3ya/gam3ya_members_screen.dart';
import 'package:gam3ya/src/views/home/dashboard_screen.dart';
import 'package:gam3ya/src/views/home/home_screen.dart';
import 'package:gam3ya/src/views/home/notifications_screen.dart';
import 'package:gam3ya/src/views/payments/payment_history_screen.dart';
import 'package:gam3ya/src/views/payments/payment_screen.dart';
import 'package:gam3ya/src/views/payments/qr_scanner_screen.dart';
import 'package:gam3ya/src/views/profile/edit_profile_screen.dart';
import 'package:gam3ya/src/views/profile/profile_screen.dart';
import 'package:gam3ya/src/views/profile/reputation_screen.dart';

import '../shared/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String notifications = '/notifications';
  
  static const String gam3yaList = '/gam3ya/list';
  static const String gam3yaDetail = '/gam3ya/detail';
  static const String createGam3ya = '/gam3ya/create';
  static const String gam3yaMembers = '/gam3ya/members';
  
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String reputation = '/profile/reputation';
  
  static const String payment = '/payment';
  static const String paymentHistory = '/payment/history';
  static const String qrScanner = '/payment/scanner';
  
  
  static const String adminDashboard = '/admin';
  static const String manageUsers = '/admin/users';
  static const String manageGam3yas = '/admin/gam3yas';
  static const String analytics = '/admin/analytics';
  
  static Map<String, WidgetBuilder> get routes => {
    // Authentication
    login: (context) =>  LoginScreen(),
    splash: (context) =>  SplashScreen(),
    signup: (context) => const SignupScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    
    home: (context) {
      
       return HomeScreen();
    },
    dashboard: (context) => const DashboardScreen(),
    notifications: (context) => const NotificationsScreen(),
    
    gam3yaList: (context) => const Gam3yaListScreen(),
    gam3yaDetail: (context) => const Gam3yaDetailScreen(gam3yaId: '',),
    createGam3ya: (context) => const CreateGam3yaScreen(),
    gam3yaMembers: (context) => const Gam3yaMembersScreen(),
    
    profile: (context) => const ProfileScreen(),
    editProfile: (context) => const EditProfileScreen(),
    reputation: (context) => const ReputationScreen(),
    
    payment: (context) => const PaymentScreen(),
    paymentHistory: (context) => const PaymentHistoryScreen(),
    qrScanner: (context) => const QRScannerScreen(gam3yaId: '',),
    
    adminDashboard: (context) => const AdminDashboard(),
    manageUsers: (context) => const ManageUsersScreen(),
    manageGam3yas: (context) => const ManageGam3yasScreen(),
    analytics: (context) => const AnalyticsScreen(),
  };
}

// // config/constants.dart
// class AppConstants {
//   // Firebase collections
//   static const String usersCollection = 'users';
//   static const String gam3yasCollection = 'gam3yas';
//   static const String paymentsCollection = 'payments';
//   static const String notificationsCollection = 'notifications';
  
//   // Hive box names
//   static const String usersBox = 'users';
//   static const String gam3yasBox = 'gam3yas';
//   static const String settingsBox = 'appSettings';
  
//   // App settings
//   static const String languageKey = 'language';
//   static const String themeKey = 'theme';
//   static const String notificationsKey = 'notifications';
  
//   // Reputation system
//   static const int defaultReputationScore = 100;
//   static const int reputationDecreaseLatePayment = 5;
//   static const int reputationDecreaseNoPayment = 15;
//   static const int reputationIncreaseOnTimePayment = 2;
//   static const int reputationIncreaseEarlyPayment = 5;
  
//   // Payment related
//   static const double defaultSafetyFundPercentage = 5.0;
//   static const int paymentReminderDaysBeforeDue = 3;
  
//   // Validation rules
//   static const int minPasswordLength = 8;
//   static const int minGam3yaMembers = 3;
//   static const int maxGam3yaMembers = 30;
//   static const double minGam3yaAmount = 100;
  
//   // Animation durations
//   static const Duration shortAnimationDuration = Duration(milliseconds: 300);
//   static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
//   static const Duration longAnimationDuration = Duration(milliseconds: 800);
// }