// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/models/user_model.dart';
import 'package:gam3ya/src/widgets/animations/fade_animation.dart';
import 'package:gam3ya/src/widgets/common/loading_indicator.dart';

import '../../controllers/auth_provider.dart' ;
import '../../controllers/user_provider.dart'as currentUserProvider;
import '../../controllers/user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider.currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(context, '/profile/edit'),
          ),
        ],
      ),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('تسجيل الدخول مطلوب'),
            );
          }
          
          return FadeAnimation(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                          backgroundImage: user.photoUrl.isNotEmpty 
                              ? NetworkImage(user.photoUrl) as ImageProvider
                              : const AssetImage('assets/images/default_profile.png'),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getRoleIcon(user.role),
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // User Name
                  Center(
                    child: Text(
                      user.name,
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Role Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.role, theme),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getRoleText(user.role),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Reputation Section
                  _buildProfileCard(
                    context,
                    title: 'تقييم حسابك',
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'النقاط: ${user.reputationScore}',
                              style: theme.textTheme.titleLarge,
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(context, '/profile/reputation'),
                              child: Text(
                                'تفاصيل التقييم',
                                style: TextStyle(color: theme.colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: user.reputationScore / 100,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(_getReputationColor(user.reputationScore, theme)),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getReputationText(user.reputationScore),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _getReputationColor(user.reputationScore, theme),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Personal Information Section
                  _buildProfileCard(
                    context,
                    title: 'المعلومات الشخصية',
                    child: Column(
                      children: [
                        _infoRow(context, 'البريد الإلكتروني', user.email, Icons.email),
                        const Divider(),
                        _infoRow(context, 'رقم الهاتف', user.phone, Icons.phone),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Gam3ya Stats Section
                  _buildProfileCard(
                    context,
                    title: 'إحصائيات الجمعيات',
                    child: Column(
                      children: [
                        _statRow(
                          context, 
                          'الجمعيات المشارك بها', 
                          user.joinedGam3yasIds.length.toString(),
                          Icons.group,
                          theme.colorScheme.primary,
                        ),
                        const Divider(),
                        _statRow(
                          context, 
                          'الجمعيات التي أنشأتها', 
                          user.createdGam3yasIds.length.toString(),
                          Icons.add_circle,
                          theme.colorScheme.secondary,
                        ),
                        const Divider(),
                        _statRow(
                          context, 
                          'الأشخاص الذين تضمنهم', 
                          user.guarantorForUserIds.length.toString(),
                          Icons.verified_user,
                          theme.colorScheme.tertiary,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Guarantor Section
                  if (user.guarantorUserId != null)
                    FutureBuilder<User?>(
                      future: ref.read(userProvider(user.guarantorUserId!).future),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        final guarantor = snapshot.data;
                        if (guarantor == null) {
                          return const SizedBox.shrink();
                        }
                        
                        return _buildProfileCard(
                          context,
                          title: 'الضامن الخاص بك',
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: guarantor.photoUrl.isNotEmpty 
                                  ? NetworkImage(guarantor.photoUrl) as ImageProvider
                                  : const AssetImage('assets/images/default_profile.png'),
                            ),
                            title: Text(guarantor.name),
                            subtitle: Text(guarantor.phone),
                            trailing: const Icon(Icons.shield, color: Colors.green),
                          ),
                        );
                      },
                    ),
                    
                  const SizedBox(height: 24),
                  
                  // Logout Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('تسجيل الخروج'),
                          content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('إلغاء'),
                            ),
                            TextButton(
                              onPressed: () {
                                ref.read(authServiceProvider).signOut();
                                Navigator.of(ctx).pop();
                                Navigator.of(context).pushReplacementNamed('/login');
                              },
                              child: const Text('تسجيل الخروج'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('تسجيل الخروج'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, stack) => Center(
          child: Text('حدث خطأ: $error'),
        ),
      ),
    );
  }
  
  Widget _buildProfileCard(BuildContext context, {required String title, required Widget child}) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
  
  Widget _infoRow(BuildContext context, String title, String value, IconData icon) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _statRow(BuildContext context, String title, String count, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          Text(
            count,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.moderator:
        return Icons.security;
      case UserRole.organizer:
        return Icons.emoji_events;
      case UserRole.user:
      default:
        return Icons.person;
    }
  }
  
  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'مدير النظام';
      case UserRole.moderator:
        return 'مشرف';
      case UserRole.organizer:
        return 'منظم جمعيات';
      case UserRole.user:
      default:
        return 'مستخدم';
    }
  }
  
  Color _getRoleColor(UserRole role, ThemeData theme) {
    switch (role) {
      case UserRole.admin:
        return Colors.purple;
      case UserRole.moderator:
        return Colors.blue;
      case UserRole.organizer:
        return theme.colorScheme.secondary;
      case UserRole.user:
      default:
        return theme.colorScheme.primary;
    }
  }
  
  Color _getReputationColor(int score, ThemeData theme) {
    if (score >= 90) {
      return Colors.green;
    } else if (score >= 70) {
      return theme.colorScheme.primary;
    } else if (score >= 50) {
      return theme.colorScheme.tertiary;
    } else {
      return Colors.red;
    }
  }
  
  String _getReputationText(int score) {
    if (score >= 90) {
      return 'ممتاز - مؤهل لكل الجمعيات';
    } else if (score >= 70) {
      return 'جيد جدًا - مؤهل لمعظم الجمعيات';
    } else if (score >= 50) {
      return 'متوسط - مؤهل للجمعيات الصغيرة';
    } else {
      return 'منخفض - قد تحتاج لضامن';
    }
  }
}