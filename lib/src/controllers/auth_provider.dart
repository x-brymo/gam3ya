// providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/models/user_model.dart';
import 'package:gam3ya/src/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges.map((firebaseUser) {
    if (firebaseUser == null) {
      return null;
    } else {
      return User(
        id: firebaseUser.id,
        email: firebaseUser.email,
        name: firebaseUser.name,
        photoUrl: firebaseUser.phone,
        phone: firebaseUser.phone,
        role: UserRole.user, // Default role, can be updated later
      );
    }
  });
});
final allUsersProvider = StreamProvider<List<User>>((ref) {
  final  authService = ref.watch(authServiceProvider);
  return authService.getAllUsers() as Stream<List<User>>;
});

final currentUserProvider = StateProvider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Check if user has admin rights
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role == UserRole.admin;
});
final authNotifierProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
}); 
class AuthNotifier extends StateNotifier<User?> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(null);
  void fetchCurrentUser() async {
    state = await _authService.getCurrentUser();
}
  Future<void> login(String email, String password) async {
    try {
      final user = await _authService.signIn(email: email, password: password);
      state = user;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = null;
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }
  Future<void> signUp(String email, String password, String name, String phone) async {
    try {
      final user = await _authService.signUp(email: email, password: password, name:name, phone:phone);
      state = user;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }
  Future<void> updateUserProfile(User user) async {
    try {
      await _authService.updateUserProfile(userId: user.id, name: user.name, phone: user.phone, photoUrl: user.photoUrl);
      state = user;
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }
}