import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                AppConstants.assetPathLogo,
                width: 120,
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'جمعيتي',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              )
              .animate()
              .fadeIn(duration: AppConstants.mediumAnimationDuration)
              .scale(delay: 300.ms),
              
              const SizedBox(height: 32),
              
              // App Name
              Text(
                'جمعيتي',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
              .animate()
              .fadeIn(delay: 300.ms, duration: AppConstants.mediumAnimationDuration),
              
              Text(
                'MyGam3ya',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white70,
                ),
              )
              .animate()
              .fadeIn(delay: 500.ms, duration: AppConstants.mediumAnimationDuration),
              
              const SizedBox(height: 48),
              
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
              .animate()
              .fadeIn(delay: 800.ms, duration: AppConstants.shortAnimationDuration),
              
              const SizedBox(height: 24),
              
              Text(
                'تنظيم مالي آمن للجميع',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              )
              .animate()
              .fadeIn(delay: 1000.ms, duration: AppConstants.shortAnimationDuration),
            ],
          ),
        ),
      ),
    );
  }
}