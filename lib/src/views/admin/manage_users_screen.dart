// admin/manage_users_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/models/user_model.dart';
import 'package:gam3ya/src/widgets/animations/fade_animation.dart';
import 'package:gam3ya/src/widgets/common/error_widget.dart';
import 'package:gam3ya/src/widgets/common/loading_indicator.dart';
import 'package:intl/intl.dart';

import '../../controllers/user_provider.dart';

class ManageUsersScreen extends ConsumerStatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  ConsumerState<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends ConsumerState<ManageUsersScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  UserRole? _selectedRoleFilter;
  bool _showOnlyLowReputation = false;
  bool _showOnlyWithGuarantors = false;
  
  TabController? _tabController;
  
  final List<Tab> _tabs = [
    const Tab(text: 'كل المستخدمين'),
    const Tab(text: 'قيد الموافقة'),
    const Tab(text: 'المعلقين'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    
    // Initial data load
    Future.microtask(() {
      ref.read(usersNotifierProvider.notifier).fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  List<User> _filterUsers(List<User> users) {
    return users.where((user) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!user.name.toLowerCase().contains(query) &&
            !user.email.toLowerCase().contains(query) &&
            !user.phone.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // Role filter
      if (_selectedRoleFilter != null && user.role != _selectedRoleFilter) {
        return false;
      }
      
      // Reputation filter
      if (_showOnlyLowReputation && user.reputationScore > 60) {
        return false;
      }
      
      // Guarantor filter
      if (_showOnlyWithGuarantors && user.guarantorUserId == null) {
        return false;
      }
      
      // Tab filter
      switch (_tabController?.index ?? 0) {
        case 1: // Pending approval tab
          // Simulating a "pending approval" status
          // In a real app, you'd have a proper status field
          return user.reputationScore == 0;
        case 2: // Suspended tab
          // Simulating a "suspended" status
          // In a real app, you'd have a proper status field
          return user.reputationScore < 50;
        default: // All users tab
          return true;
      }
    }).toList();
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'مدير النظام';
      case UserRole.moderator:
        return 'مشرف';
      case UserRole.organizer:
        return 'منظم';
      case UserRole.user:
        return 'مستخدم عادي';
    }
  }

  Color _getReputationColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.lime;
    if (score >= 50) return Colors.amber;
    if (score >= 30) return Colors.orange;
    return Colors.red;
  }

  Future<void> _showUserDetailsDialog(User user) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل المستخدم: ${user.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUserInfoRow('الاسم', user.name),
              _buildUserInfoRow('البريد الإلكتروني', user.email),
              _buildUserInfoRow('رقم الهاتف', user.phone),
              _buildUserInfoRow('الدور', _getRoleDisplayName(user.role)),
              _buildUserInfoRow('نقاط السمعة', '${user.reputationScore}'),
              const Divider(),
              _buildUserInfoRow('عدد الجمعيات المشترك بها', '${user.joinedGam3yasIds.length}'),
              _buildUserInfoRow('عدد الجمعيات التي أنشأها', '${user.createdGam3yasIds.length}'),
              _buildUserInfoRow('عدد الأشخاص الذين يضمنهم', '${user.guarantorForUserIds.length}'),
              _buildUserInfoRow('هل لديه ضامن', user.guarantorUserId != null ? 'نعم' : 'لا'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              // Close details dialog
              Navigator.pop(context);
              // Open edit dialog
              _showEditUserDialog(user);
            },
            child: const Text('تعديل'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditUserDialog(User user) async {
    UserRole selectedRole = user.role;
    int selectedReputationScore = user.reputationScore;
    bool isSuspended = user.reputationScore < 50; // Example suspension logic

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('تعديل المستخدم: ${user.name}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('دور المستخدم:'),
                  const SizedBox(height: 8),
                  DropdownButton<UserRole>(
                    isExpanded: true,
                    value: selectedRole,
                    onChanged: (newRole) {
                      if (newRole != null) {
                        setState(() => selectedRole = newRole);
                      }
                    },
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(_getRoleDisplayName(role)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('نقاط السمعة:'),
                  Slider(
                    value: selectedReputationScore.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 10,
                    label: selectedReputationScore.toString(),
                    activeColor: _getReputationColor(selectedReputationScore),
                    onChanged: (newValue) {
                      setState(() => selectedReputationScore = newValue.round());
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('تعليق الحساب'),
                    subtitle: const Text('منع المستخدم من المشاركة في الجمعيات'),
                    value: isSuspended,
                    onChanged: (newValue) {
                      setState(() {
                        isSuspended = newValue;
                        if (isSuspended) {
                          selectedReputationScore = 10; // Set low reputation for suspension
                        } else if (selectedReputationScore < 50) {
                          selectedReputationScore = 50; // Restore minimum reputation
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Update user in the provider
                  final updatedUser = user.copyWith(
                    role: selectedRole,
                    reputationScore: selectedReputationScore,
                  );
                  
                  ref.read(usersNotifierProvider.notifier).updateUser(updatedUser , user.id);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تحديث معلومات المستخدم ${user.name}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  Navigator.pop(context);
                },
                child: const Text('حفظ التغييرات'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          onTap: (_) => setState(() {}), // Refresh for filter changes
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Trigger a refresh of the user list
          ref.read(usersNotifierProvider.notifier).fetchUsers();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث قائمة المستخدمين'),
            ),
          );
        },
        tooltip: 'تحديث',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'بحث بالاسم، البريد الإلكتروني، أو رقم الهاتف',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
            const SizedBox(height: 12),
            
            // Advanced filters section
            ExpansionTile(
              title: const Text('خيارات البحث المتقدم'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.symmetric(vertical: 8.0),
              children: [
                // Role filter
                Row(
                  children: [
                    const Text('تصفية حسب الدور:'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<UserRole?>(
                        isExpanded: true,
                        value: _selectedRoleFilter,
                        hint: const Text('جميع الأدوار'),
                        onChanged: (role) {
                          setState(() => _selectedRoleFilter = role);
                        },
                        items: [
                          const DropdownMenuItem<UserRole?>(
                            value: null,
                            child: Text('جميع الأدوار'),
                          ),
                          ...UserRole.values.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(_getRoleDisplayName(role)),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Reputation and guarantor filters
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('سمعة منخفضة فقط'),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        value: _showOnlyLowReputation,
                        onChanged: (value) {
                          setState(() => _showOnlyLowReputation = value ?? false);
                        },
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('لديهم ضامن فقط'),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        value: _showOnlyWithGuarantors,
                        onChanged: (value) {
                          setState(() => _showOnlyWithGuarantors = value ?? false);
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                // Clear filters button
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _selectedRoleFilter = null;
                      _showOnlyLowReputation = false;
                      _showOnlyWithGuarantors = false;
                    });
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('مسح كل الفلاتر'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return ref.watch(userListProvider).when(
      data: (users) {
        final filteredUsers = _filterUsers(users);
        
        if (filteredUsers.isEmpty) {
          return const Center(
            child: Text(
              'لا يوجد مستخدمين مطابقين للبحث',
              style: TextStyle(fontSize: 16),
            ),
          );
        }
        
        return FadeAnimation(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return _buildUserListItem(user);
            },
          ),
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => ErrorDisplayWidget(
        message: error.toString(),
        onRetry: () => ref.read(usersNotifierProvider.notifier).fetchUsers(),
      ),
    );
  }

  Widget _buildUserListItem(User user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: user.photoUrl.isNotEmpty
              ? null // In a real app, display user photo
              : Text(user.name[0].toUpperCase()),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Text(_getRoleDisplayName(user.role)),
                const SizedBox(width: 12),
                Icon(
                  Icons.star,
                  size: 14,
                  color: _getReputationColor(user.reputationScore),
                ),
                const SizedBox(width: 4),
                Text(
                  'السمعة: ${user.reputationScore}',
                  style: TextStyle(
                    color: _getReputationColor(user.reputationScore),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user.reputationScore == 0) // Pending approval
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                tooltip: 'الموافقة',
                onPressed: () {
                  final updatedUser = user.copyWith(reputationScore: 80);
                  ref.read(usersNotifierProvider.notifier).updateUser(updatedUser, user.id);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تمت الموافقة على المستخدم ${user.name}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            if (user.reputationScore == 0) // Pending approval
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                tooltip: 'الرفض',
                onPressed: () {
                  // In a real app, you might want to delete or flag the user
                  // Here we'll just set a very low reputation score
                  final updatedUser = user.copyWith(reputationScore: 10);
                  ref.read(usersNotifierProvider.notifier).updateUser(updatedUser, user.id);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم رفض المستخدم ${user.name}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.visibility),
              tooltip: 'عرض التفاصيل',
              onPressed: () => _showUserDetailsDialog(user),
            ),
          ],
        ),
        onTap: () => _showUserDetailsDialog(user),
      ),
    );
  }
}

// This would be the provider implementation in user_provider.dart:
// Below is a simplified version of what you'd implement

/*
// In providers/user_provider.dart:

final userListProvider = StateNotifierProvider<UserListNotifier, AsyncValue<List<User>>>((ref) {
  return UserListNotifier(ref);
});

class UserListNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final Ref _ref;
  
  UserListNotifier(this._ref) : super(const AsyncValue.loading());
  
  Future<void> loadUsers() async {
    try {
      state = const AsyncValue.loading();
      // Get users from Firebase or local database
      // Example implementation:
      final usersBox = Hive.box<User>('users');
      final users = usersBox.values.toList();
      
      // If using Firebase:
      // final snapshot = await FirebaseFirestore.instance.collection('users').get();
      // final users = snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
      
      state = AsyncValue.data(users);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> updateUser(User updatedUser) async {
    try {
      // Get current state
      final currentUsers = state.value ?? [];
      final updatedUsers = currentUsers.map((user) {
        return user.id == updatedUser.id ? updatedUser : user;
      }).toList();
      
      // Update local state
      state = AsyncValue.data(updatedUsers);
      
      // Update in database
      final usersBox = Hive.box<User>('users');
      await usersBox.put(updatedUser.id, updatedUser);
      
      // Or with Firebase:
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(updatedUser.id)
      //     .update(updatedUser.toJson());
    } catch (error, stackTrace) {
      // Revert to previous state and handle error
      loadUsers();
      throw error;
    }
  }
}
*/