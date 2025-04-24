import 'dart:io';

void main() {
  final basePath = 'lib/';
  final directories = [
    'src/',
    'src/models/',
    'src/services/',
    'src/controllers/',
    'src/views/',
    'src/utils/',
    'src/widgets/',
    'src/constants/',
    'src/extensions/',

  ];
 
  final files = {
    'main.dart': basePath,
    'app.dart': '$basePath/src/',
    'constants.dart': '$basePath/src/constants/',
    'theme.dart': '$basePath/src/constants/',
    'routes.dart': '$basePath/src/constants/',
    'user_model.dart': '$basePath/src/models/',
    'gam3ya_model.dart': '$basePath/src/models/',
    'payment_model.dart': '$basePath/src/models/',
    'firebase_service.dart': '$basePath/src/services/',
    'auth_service.dart': '$basePath/src/services/',
    'local_storage_service.dart': '$basePath/src/services/',
    'notification_service.dart': '$basePath/src/services/',
    'nearby_service.dart': '$basePath/src/services/',
    'auth_provider.dart': '$basePath/src/controllers/',
    'gam3ya_provider.dart': '$basePath/src/controllers/',
    'user_provider.dart': '$basePath/src/controllers/',
    'payment_provider.dart': '$basePath/src/controllers/',
    'login_screen.dart': '$basePath/src/views/auth/',
    'signup_screen.dart': '$basePath/src/views/auth/',
    'forgot_password_screen.dart': '$basePath/src/views/auth/',
    'home_screen.dart': '$basePath/src/views/home/',
    'dashboard_screen.dart': '$basePath/src/views/home/',
    'notifications_screen.dart': '$basePath/src/views/home/',
    'gam3ya_list_screen.dart': '$basePath/src/views/gam3ya/',
    'gam3ya_detail_screen.dart': '$basePath/src/views/gam3ya/',
    'create_gam3ya_screen.dart': '$basePath/src/views/gam3ya/',
    'gam3ya_members_screen.dart': '$basePath/src/views/gam3ya/',
    'profile_screen.dart': '$basePath/src/views/profile/',
    'edit_profile_screen.dart': '$basePath/src/views/profile/',
    'reputation_screen.dart': '$basePath/src/views/profile/',
    'admin_dashboard.dart': '$basePath/src/views/admin/',
    'manage_users_screen.dart': '$basePath/src/views/admin/',
    'manage_gam3yas_screen.dart': '$basePath/src/views/admin/',
    'analytics_screen.dart': '$basePath/src/views/admin/',
    'payment_screen.dart': '$basePath/src/views/payments/',
    'payment_history_screen.dart': '$basePath/src/views/payments/',
    'qr_scanner_screen.dart': '$basePath/src/views/payments/',
    'custom_button.dart': '$basePath/src/widgets/common/',
    'custom_text_field.dart': '$basePath/src/widgets/common/',
    'loading_indicator.dart': '$basePath/src/widgets/common/',
    'error_widget.dart': '$basePath/src/widgets/common/',
    'gam3ya_card.dart': '$basePath/src/widgets/gam3ya/',
    'payment_card.dart': '$basePath/src/widgets/gam3ya/',
    'turn_calendar.dart': '$basePath/src/widgets/gam3ya/',
    'fade_animation.dart': '$basePath/src/widgets/animations/',
    'slide_animation.dart': '$basePath/src/widgets/animations/',
    'pulse_animation.dart': '$basePath/src/widgets/animations/',
    

  };

  for (final dir in directories) {
    final dirPath = '$basePath$dir';
    Directory(dirPath).createSync(recursive: true);
      
    print('✅ Created directory: $dirPath');
  }

  for (final entry in files.entries) {
    final filePath = '${entry.value}${entry.key}';
    File(filePath).createSync(recursive: true);
    print('📄 Created file: $filePath');
  }

  print('\n🎉 Project structure created successfully!');
}
/*
lib/
├── main.dart
├── app.dart
├── config/
│   ├── constants.dart
│   ├── theme.dart
│   └── routes.dart
├── models/
│   ├── user_model.dart
│   ├── gam3ya_model.dart
│   └── payment_model.dart
├── services/
│   ├── firebase_service.dart
│   ├── auth_service.dart
│   ├── local_storage_service.dart
│   ├── notification_service.dart
│   └── nearby_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── gam3ya_provider.dart
│   ├── user_provider.dart
│   └── payment_provider.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── dashboard_screen.dart 
│   │   └── notifications_screen.dart
│   ├── gam3ya/
│   │   ├── gam3ya_list_screen.dart
│   │   ├── gam3ya_detail_screen.dart
│   │   ├── create_gam3ya_screen.dart
│   │   └── gam3ya_members_screen.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   ├── edit_profile_screen.dart
│   │   └── reputation_screen.dart
│   ├── admin/
│   │   ├── admin_dashboard.dart
│   │   ├── manage_users_screen.dart
│   │   ├── manage_gam3yas_screen.dart
│   │   └── analytics_screen.dart
│   └── payments/
│       ├── payment_screen.dart
│       ├── payment_history_screen.dart
│       └── qr_scanner_screen.dart
└── widgets/
    ├── common/
    │   ├── custom_button.dart
    │   ├── custom_text_field.dart
    │   ├── loading_indicator.dart
    │   └── error_widget.dart
    ├── gam3ya/
    │   ├── gam3ya_card.dart
    │   ├── payment_card.dart
    │   └── turn_calendar.dart
    └── animations/
        ├── fade_animation.dart
        ├── slide_animation.dart
        └── pulse_animation.dart
*/