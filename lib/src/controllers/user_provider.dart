// providers/user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/models/user_model.dart';
import 'package:gam3ya/src/services/firebase_service.dart';

import '../constants/SharedPreferences.dart';
import '../services/upload_image_service.dart';
import 'auth_provider.dart';

final userServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});
late User currentUser;
final userProvider = FutureProvider.family<User?, String>((ref, userId) async {
  final userService = ref.watch(userServiceProvider);
  return await userService.getUserProfile(userId);
});
final currentUserProvider = FutureProvider<User>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final user = await authService.getCurrentUser();
   
  if (user != null) {
    final userService = ref.watch(userServiceProvider);
    final users = await userService.getUserProfile(user.id);

    PrefsHandler.saveString("userId", users.id);
    PrefsHandler.saveString("role", users.role.name);
    return users;
    } else {
    throw Exception('لم يتم تسجيل الدخول');
  }
});
final checkUser = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final user = await authService.getCurrentUser();
  return user != null;
});
final userStatsProvider = FutureProvider.family<User?, String>((ref, userId) async {
  final userService = ref.watch(userServiceProvider);
  return await userService.getUserProfile(userId);
});
final usersProvider = FutureProvider<List<User>>((ref) async {
  final userService = ref.watch(userServiceProvider);
  return await userService.getAllUsers();
});

final userGuarantorProvider = FutureProvider.family<User?, String>((ref, userId) async {
  final userService = ref.watch(userServiceProvider);
  final user = await userService.getUserProfile(userId);
  
  if (user.guarantorUserId == null) {
    return null;
  }
  
  return await userService.getUserProfile(user.guarantorUserId!);
});

final userReputationProvider = FutureProvider.family<int, String>((ref, userId) async {
  final userService = ref.watch(userServiceProvider);
  final user = await userService.getUserProfile(userId);
  
  return user.reputationScore;
});
final userListProvider = FutureProvider<List<User>>((ref) async {
  final userService = ref.watch(userServiceProvider);
  return await userService.getAllUsers();
});
final usersNotifierProvider = StateNotifierProvider<UsersNotifier, List<User>>((ref) {

  return UsersNotifier(ref.read(userServiceProvider));
});
class UsersNotifier extends StateNotifier<List<User>> {
  final FirebaseService _userService;

  UsersNotifier(this._userService) : super([]);

  Future<void> fetchUsers() async {
    final users = await _userService.getAllUsers();
    state = users;
  }

  Future<void> addUser(User user) async {
    await _userService.createUserProfile(user);
    fetchUsers();
  }

  Future<void> updateUser(User user, String userId) async {
    await _userService.updateUserProfile(userId, user);
    fetchUsers();
  }

  Future<void> deleteUser(String userId) async {
    await _userService.deleteUserProfile(userId);
    fetchUsers();
  }
  Future<void>uploadImageProfile(String userId)async{
    ProfileImageService profileService = ProfileImageService();
    await  profileService.updateUserProfileImage(userId);
  }
}