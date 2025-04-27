// app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constants/SharedPreferences.dart';
import 'constants/routes.dart';
import 'constants/theme.dart';
import 'controllers/auth_provider.dart';
import 'views/admin/admin_dashboard.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';

class Gam3yaApp extends ConsumerWidget {
  const Gam3yaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final role = PrefsHandler.getString('role');
    return MaterialApp(
      title: 'جمعيتي - MyGam3ya',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.splash,
      home:
          role == 'user'
              ? const HomeScreen()
              : role == 'admin'
              ? const AdminDashboard()
              : const LoginScreen(),

      //)
      // authState.when(
      //   data: (user) => user == null ? const LoginScreen() : const HomeScreen(),
      //   loading: () => const Scaffold(
      //     body: Center(
      //       child: CircularProgressIndicator(),
      //     ),
      //   ),
      //   error: (error, stack) => Scaffold(
      //     body: Center(
      //       child: Text('Error: $error'),
      //     ),
      //),
      //),
    );
  }
}
