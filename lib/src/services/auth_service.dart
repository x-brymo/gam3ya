// services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:gam3ya/src/models/user_model.dart' as app_model;
import 'package:hive/hive.dart';

import '../constants/constants.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FlutterSecureStorage _secureStorage;
  
  AuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FlutterSecureStorage? secureStorage,
  }) : 
    _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
    _firestore = firestore ?? FirebaseFirestore.instance,
    _secureStorage = secureStorage ?? const FlutterSecureStorage();
  
  Stream<app_model.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }
      
      // Get user data from Firestore
      try {
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(firebaseUser.uid)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final user = app_model.User.fromJson({
            'id': firebaseUser.uid,
            ...userData,
          });
          
          // Store user in Hive for offline access
          final userBox = Hive.box<app_model.User>(AppConstants.usersBox);
          await userBox.put(user.id, user);
          
          return user;
        }
      } catch (e) {
        print('Error getting user data: $e');
        
        // Try to get user from local storage if network is not available
        final userBox = Hive.box<app_model.User>(AppConstants.usersBox);
        final localUser = userBox.get(firebaseUser.uid);
        if (localUser != null) {
          return localUser;
        }
      }
      
      return null;
    });
  }

  
  Future<app_model.User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return app_model.User.fromJson({
          'id': firebaseUser.uid,
          ...userData,
        });
      }
    } catch (e) {
      print('Error getting current user: $e');
      
      // Try to get user from local storage
      final userBox = Hive.box<app_model.User>(AppConstants.usersBox);
      final localUser = userBox.get(firebaseUser.uid);
      if (localUser != null) {
        return localUser;
      }
    }
    
    return null;
  }
  
  Future<app_model.User> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      // Create user in Firebase Auth
      final credentials = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final uid = credentials.user!.uid;
      
      // Create new user with default values
      final newUser = app_model.User(
        id: uid,
        name: name,
        email: email,
        phone: phone,
        role: app_model.UserRole.user,
        reputationScore: AppConstants.defaultReputationScore,
      );
      
      // Save user data to Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .set(newUser.toJson());
      
      // Save user locally to Hive
      final userBox = Hive.box<app_model.User>(AppConstants.usersBox);
      await userBox.put(uid, newUser);
      
      return newUser;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }
  
  Future<app_model.User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Auth
      final credentials = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final uid = credentials.user!.uid;
      
      // Get user data from Firestore
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      
      if (!userDoc.exists) {
        throw Exception('User not found');
      }
      
      final userData = userDoc.data()!;
      final user = app_model.User.fromJson({
        'id': uid,
        ...userData,
      });
      
      // Save user locally to Hive
      final userBox = Hive.box<app_model.User>(AppConstants.usersBox);
      await userBox.put(uid, user);
      
      return user;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
  
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }
  Future<void> deleteUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
        
        // Remove user from Firestore
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .delete();
        
        // Remove user from Hive
        final userBox = Hive.box<app_model.User>(AppConstants.usersBox);
        await userBox.delete(user.uid);
      }
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  } 
  Future<List<app_model.User>> getAllUsers() async {
    final userCollection = _firestore.collection(AppConstants.usersCollection);
    final querySnapshot = await userCollection.get();
    try {
      final users = querySnapshot.docs.map((doc) {
        final userData = doc.data();
        return app_model.User.fromJson({
          'id': doc.id,
          ...userData,
        });
      }).toList();
      
      // Save users locally to Hive
      final userBox = Hive.box<app_model.User>(AppConstants.usersBox);
      for (final user in users) {
        await userBox.put(user.id, user);
      }
      
      return users;
    } catch (e) {
      print('Error getting all users: $e');
      rethrow;
    }
  }
  Future<app_model.User>getUserFromFirebase(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return app_model.User.fromJson({
          'id': userId,
          ...userData,
        });
      }
    } catch (e) {
      print('Error getting user from Firebase: $e');
      rethrow;
    }
    return app_model.User(
      id: userId,
      name: 'Unknown',
      email: 'Unknown',
      phone: 'Unknown',
      role: app_model.UserRole.user,
      reputationScore: AppConstants.defaultReputationScore,
    );
  }
   
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      
      if (updateData.isNotEmpty) {
        // Update in Firestore
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .update(updateData);
        
        // Update locally in Hive
        final userBox = Hive.box<app_model.User>(AppConstants.usersBox);
        final currentUser = userBox.get(userId);
        
        if (currentUser != null) {
          final updatedUser = currentUser.copyWith(
            name: name ?? currentUser.name,
            phone: phone ?? currentUser.phone,
            photoUrl: photoUrl ?? currentUser.photoUrl,
          );
          
          await userBox.put(userId, updatedUser);
        }
      }
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }
  
  Future<void> updateUserReputation({
    required String userId,
    required int newScore,
  }) async {
    try {
      // Update in Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'reputationScore': newScore});
      
      // Update locally in Hive
      final userBox = Hive.box<app_model.User>(AppConstants.usersBox);
      final currentUser = userBox.get(userId);
      
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          reputationScore: newScore,
        );
        
        await userBox.put(userId, updatedUser);
      }
    } catch (e) {
      print('Error updating user reputation: $e');
      rethrow;
    }
  }
  
  Future<String?> getAuthToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }
  
  Future<void> saveCredentials(String email, String password) async {
    try {
      await _secureStorage.write(key: 'email', value: email);
      await _secureStorage.write(key: 'password', value: password);
    } catch (e) {
      print('Error saving credentials: $e');
    }
  }
  
  Future<Map<String, String>> getCredentials() async {
    try {
      final email = await _secureStorage.read(key: 'email') ?? '';
      final password = await _secureStorage.read(key: 'password') ?? '';
      return {'email': email, 'password': password};
    } catch (e) {
      print('Error getting credentials: $e');
      return {'email': '', 'password': ''};
    }
  }
  
  Future<void> clearCredentials() async {
    try {
      await _secureStorage.delete(key: 'email');
      await _secureStorage.delete(key: 'password');
    } catch (e) {
      print('Error clearing credentials: $e');
    }
  }
}
