// providers/gam3ya_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/controllers/user_provider.dart' show userServiceProvider;
import 'package:gam3ya/src/models/gam3ya_model.dart';
import 'package:gam3ya/src/models/user_model.dart';

import 'package:gam3ya/src/services/firebase_service.dart';

import 'auth_provider.dart';

final gam3yaServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService(); // Assuming FirebaseService is generic and can handle Gam3ya
});

final gam3yaProvider = FutureProvider.family<Gam3ya?, String>((ref, gam3yaId) async {
  final gam3yaService = ref.watch(gam3yaServiceProvider);
  return await gam3yaService.getGam3ya(gam3yaId);
});

final gam3yasProvider = FutureProvider<List<Gam3ya>>((ref) async {
  final gam3yaService = ref.watch(gam3yaServiceProvider);
  return await gam3yaService.getAllGam3yas();
});



final userGam3yasProvider = FutureProvider<List<Gam3ya>>((ref) async {
  final gam3yaService = ref.watch(gam3yaServiceProvider);
  final currentUser = ref.watch(currentUserProvider.notifier).state;
  
  if (currentUser == null) {
    return [];
  }
  
  final joinedGam3yasIds = currentUser.joinedGam3yasIds;
  final gam3yas = await Future.wait(
    joinedGam3yasIds.map((id) => gam3yaService.getGam3ya(id)),
  );
  
  return gam3yas.whereType<Gam3ya>().toList();
});

final createdGam3yasProvider = FutureProvider<List<Gam3ya>>((ref) async {
  final gam3yaService = ref.watch(gam3yaServiceProvider);
  final currentUser = ref.watch(currentUserProvider.notifier).state;
  
  if (currentUser == null) {
    return [];
  }
  
  final List<Gam3ya> allGam3yas = await gam3yaService.getAllGam3yas();
  return allGam3yas.where((gam3ya) => gam3ya.creatorId == currentUser.id).toList();
});

final pendingGam3yasProvider = FutureProvider<List<Gam3ya>>((ref) async {
  final allGam3yas = await ref.watch(gam3yasProvider.future);
  return allGam3yas.where((gam3ya) => gam3ya.status == Gam3yaStatus.pending).toList();
});

final activeGam3yasProvider = FutureProvider<List<Gam3ya>>((ref) async {
  final allGam3yas = await ref.watch(gam3yasProvider.future);
  return allGam3yas.where((gam3ya) => gam3ya.status == Gam3yaStatus.active).toList();
});

final publicGam3yasProvider = FutureProvider<List<Gam3ya>>((ref) async {
  final activeGam3yas = await ref.watch(activeGam3yasProvider.future);
  return activeGam3yas.where((gam3ya) => gam3ya.access == Gam3yaAccess.public).toList();
});

final gam3yaMembersProvider = FutureProvider.family<List<User>, String>((ref, gam3yaId) async {
  final gam3ya = await ref.watch(gam3yaProvider(gam3yaId).future);
  
  if (gam3ya == null) {
    return [];
  }
  
  final userService = ref.watch(userServiceProvider);
  final userFutures = gam3ya.members.map((member) => userService.getUserProfile(member.userId));
  final users = await Future.wait(userFutures);
  
  return users.whereType<User>().toList();
});
final searchGam3yasProvider = FutureProvider.family<List<Gam3ya>, String>((ref, query) async {
  final gam3yaService = ref.watch(gam3yaServiceProvider);
  final allGam3yas = await gam3yaService.getAllGam3yas();
  
  if (query.isEmpty) {
    return allGam3yas;
  }
  
  return allGam3yas.where((gam3ya) => gam3ya.name.toLowerCase().contains(query.toLowerCase())).toList();
});
final singleGam3yaProvider = FutureProvider.family<Gam3ya?, String>((ref, gam3yaId) async {
  final gam3yaService = ref.watch(gam3yaServiceProvider);
  return await gam3yaService.getGam3ya(gam3yaId);
});

final userNextPaymentProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final currentUser = ref.watch(currentUserProvider.notifier).state;
  final gam3yaService = ref.watch(gam3yaServiceProvider);
  if (currentUser == null || currentUser.joinedGam3yasIds.isEmpty) {
    return {'hasPayment': false};
  }
  
  final userGam3yas = await ref.watch(userGam3yasProvider.future);
  
  if (userGam3yas.isEmpty) {
    return {'hasPayment': false};
  }
  
  final now = DateTime.now();
  
  // Find the next gam3ya payment due
  Gam3ya? nextPaymentGam3ya;
  DateTime? nextPaymentDate;
  
  for (final gam3ya in userGam3yas) {
    if (gam3ya.status != Gam3yaStatus.active) continue;
    
    final nextDate = gam3ya.getNextPaymentDate(now);
    if (nextDate == 'N/A') continue;
    
    final date = DateTime.parse(nextDate);
    
    if (nextPaymentDate == null || date.isBefore(nextPaymentDate)) {
      nextPaymentDate = date;
      nextPaymentGam3ya = gam3ya;
    }
  }
  
  if (nextPaymentGam3ya == null || nextPaymentDate == null) {
    return {'hasPayment': false};
  }
  
  return {
    'hasPayment': true,
    'gam3ya': nextPaymentGam3ya,
    'date': nextPaymentDate,
    'amount': nextPaymentGam3ya.monthlyPayment,
  };
});


class Gam3yasNotifier extends StateNotifier<List<Gam3ya>> {
  Gam3yasNotifier() : super([]);
final FirebaseService gam3yaServiceProviders = FirebaseService(); 
  Future<void> loadAllGam3yas() async {
    final allGam3yas = await gam3yaServiceProviders.getAllGam3yas();
    state = allGam3yas;
    
  }
  Future<void> addGam3ya(Gam3ya gam3ya) async {
    await gam3yaServiceProviders.createGam3ya(gam3ya);
    state = [...state, gam3ya];
  }
  Future<void> updateGam3ya(String id, Gam3ya gam3ya) async {
    await gam3yaServiceProviders.updateGam3ya(id,gam3ya);
    state = state.map((g) => g.id == gam3ya.id ? gam3ya : g).toList();
  }
  // Future<void> deleteGam3ya(String gam3yaId) async {
  //   await gam3yaServiceProviders.(gam3yaId);
  //   state = state.where((g) => g.id != gam3yaId).toList();
  // }
  Future<void> fetchUserGam3yas(String id) async {
    final currentUser = await gam3yaServiceProviders.getUserProfile(id); // current user
    if (currentUser == null) return;
    
    final joinedGam3yasIds = currentUser.joinedGam3yasIds;
    final gam3yas = await Future.wait(
      joinedGam3yasIds.map((id) => gam3yaServiceProviders.getGam3ya(id)),
    );
    
    state = gam3yas.whereType<Gam3ya>().toList();
  }
  Future<void> fetchCreatedGam3yas(String id) async {
    final currentUser = await gam3yaServiceProviders.getUserProfile(id); // current user
    if (currentUser == null) return;
    
    final List<Gam3ya> allGam3yas = await gam3yaServiceProviders.getAllGam3yas();
    state = allGam3yas.where((gam3ya) => gam3ya.creatorId == currentUser.id).toList();
  }
  Future<void> fetchPendingGam3yas() async {
    final allGam3yas = await gam3yaServiceProviders.getAllGam3yas();
    state = allGam3yas.where((gam3ya) => gam3ya.status == Gam3yaStatus.pending).toList();
  }
  Future<void> fetchActiveGam3yas() async {
    final allGam3yas = await gam3yaServiceProviders.getAllGam3yas();
    state = allGam3yas.where((gam3ya) => gam3ya.status == Gam3yaStatus.active).toList();
  }
  Future<void> fetchPublicGam3yas() async {
    final activeGam3yas = await gam3yaServiceProviders.getAllGam3yas();
    state = activeGam3yas.where((gam3ya) => gam3ya.access == Gam3yaAccess.public).toList();
  }
  Future<void> fetchGam3yaMembers(String gam3yaId) async {
    final gam3ya = await gam3yaServiceProviders.getGam3ya(gam3yaId);
    
    if (gam3ya == null) return;
    
    final userFutures = gam3ya.members.map((member) => gam3yaServiceProviders.getUserProfile(member.userId));
    final users = await Future.wait(userFutures);
    
    state = users.whereType<User>().cast<Gam3ya>().toList();
  }
  Future<void>updateGam3yaStatus(String gam3yaId, Gam3yaStatus status) async {
    final gam3ya = await gam3yaServiceProviders.getGam3ya(gam3yaId);
    
    if (gam3ya == null) return;
    
    gam3ya.status = status;
    await gam3yaServiceProviders.updateGam3ya(gam3yaId, gam3ya);
    
    state = state.map((g) => g.id == gam3ya.id ? gam3ya : g).toList();
  }
  // singleGam3yaProvider
  Future<void> fetchSingleGam3ya(String gam3yaId) async {
    final gam3ya = await gam3yaServiceProviders.getGam3ya(gam3yaId);
    
    if (gam3ya == null) return;
    
    state = [gam3ya];
  }
  // get current user
}
final gam3yasNotifierProvider = StateNotifierProvider<Gam3yasNotifier, List<Gam3ya>>((ref) {
  return Gam3yasNotifier();
});


// // providers/gam3ya_provider.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gam3ya/src/models/gam3ya_model.dart';
// import 'package:gam3ya/src/services/firebase_service.dart';
// import 'package:gam3ya/src/services/local_storage_service.dart';
// import 'package:gam3ya/src/providers/auth_provider.dart';

// final firebaseServiceProvider = Provider<FirebaseService>((ref) {
//   return FirebaseService();
// });

// final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
//   return LocalStorageService();
// });

// // Stream of all Gam3yas for the current user
// final userGam3yasProvider = StreamProvider<List<Gam3ya>>((ref) {
//   final firebaseService = ref.watch(firebaseServiceProvider);
//   final user = ref.watch(currentUserProvider);
  
//   if (user == null) return Stream.value([]);
  
//   return firebaseService.getUserGam3yas(user.id);
// });

// // Stream of all pending Gam3yas (for admin)
// final pendingGam3yasProvider = StreamProvider<List<Gam3ya>>((ref) {
//   final firebaseService = ref.watch(firebaseServiceProvider);
//   final isAdmin = ref.watch(isAdminProvider);
  
//   if (!isAdmin) return Stream.value([]);
  
//   return firebaseService.getPendingGam3yas();
// });

// // Provider for a specific Gam3ya by ID
// final gam3yaProvider = FutureProvider.family<Gam3ya?, String>((ref, gam3yaId) async {
//   final firebaseService = ref.watch(firebaseServiceProvider);
//   return firebaseService.getGam3yaById(gam3yaId);
// });

// // All Gam3yas where user can join (public ones with matching reputation)
// final availableGam3yasProvider = StreamProvider<List<Gam3ya>>((ref) {
//   final firebaseService = ref.watch(firebaseServiceProvider);
//   final user = ref.watch(currentUserProvider);
  
//   if (user == null) return Stream.value([]);
  
//   return firebaseService.getAvailableGam3yas(user.reputationScore);
// });