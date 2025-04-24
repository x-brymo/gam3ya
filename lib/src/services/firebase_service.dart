// services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:gam3ya/src/models/gam3ya_model.dart';
import 'package:gam3ya/src/models/user_model.dart' as app_user;
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import 'upload_image_service.dart';

class FirebaseService {
  
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  // Auth related methods
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // uploadProfileImage on drive and select path url and add it in db firebase
  Future<void> uploadProfileImage(String? userId) async {
    ProfileImageService profileService = ProfileImageService();
    try {
      await profileService.updateUserProfileImage(userId!);
    } catch (e) {
      print('Error uploading profile image: $e');
    }
  }

  Future<firebase_auth.UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  Future<firebase_auth.UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // User related methods
  Future<void> createUserProfile(app_user.User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      print('Error deleting user profile: $e');
      rethrow;
    }
  }
  Future<void> deleteGam3ya(String gam3yaId) async {
    try {
      await _firestore.collection('gam3yas').doc(gam3yaId).delete();
    } catch (e) {
      print('Error deleting Gam3ya: $e');
      rethrow;
    }
  }
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  } 

  Future<app_user.User?> getUserProfile(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        return app_user.User.fromJson({
          'id': docSnapshot.id,
          ...docSnapshot.data()!,
        });
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(String id,app_user.User user) async {
    try {
      await _firestore.collection('users').doc(id).update(user.toJson());
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<void> updateUserReputationScore(String userId, int newScore) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'reputationScore': newScore,
      });
    } catch (e) {
      print('Error updating reputation score: $e');
      rethrow;
    }
  }

  // Gam3ya related methods
  Future<void> createGam3ya(Gam3ya gam3ya) async {
    try {
      await _firestore.collection('gam3yas').doc(gam3ya.id).set(gam3ya.toJson());
      
      // Update the creator's created Gam3yas list
      await _firestore.collection('users').doc(gam3ya.creatorId).update({
        'createdGam3yasIds': FieldValue.arrayUnion([gam3ya.id]),
      });
    } catch (e) {
      print('Error creating Gam3ya: $e');
      rethrow;
    }
  }

  Future<Gam3ya?> getGam3ya(String gam3yaId) async {
    try {
      final docSnapshot = await _firestore.collection('gam3yas').doc(gam3yaId).get();
      if (docSnapshot.exists) {
        return Gam3ya.fromJson({
          'id': docSnapshot.id,
          ...docSnapshot.data()!,
        });
      }
      return null;
    } catch (e) {
      print('Error fetching Gam3ya: $e');
      rethrow;
    }
  }

  Future<void> updateGam3ya(String id, Gam3ya gam3ya) async {
    try {
      await _firestore.collection('gam3yas').doc(id).update(gam3ya.toJson());
    } catch (e) {
      print('Error updating Gam3ya: $e');
      rethrow;
    }
  }

  Future<void> updateGam3yaStatus(String gam3yaId, Gam3yaStatus status) async {
    try {
      await _firestore.collection('gam3yas').doc(gam3yaId).update({
        'status': status.toString(),
      });
    } catch (e) {
      print('Error updating Gam3ya status: $e');
      rethrow;
    }
  }

  Future<void> addMemberToGam3ya(String gam3yaId, Gam3yaMember member) async {
    try {
      final gam3yaRef = _firestore.collection('gam3yas').doc(gam3yaId);
      
      // Add the member to the Gam3ya
      await gam3yaRef.update({
        'members': FieldValue.arrayUnion([member.toJson()]),
      });
      
      // Add the Gam3ya to the user's joined Gam3yas list
      await _firestore.collection('users').doc(member.userId).update({
        'joinedGam3yasIds': FieldValue.arrayUnion([gam3yaId]),
      });
    } catch (e) {
      print('Error adding member to Gam3ya: $e');
      rethrow;
    }
  }

  Future<void> recordPayment(String gam3yaId, Gam3yaPayment payment) async {
    try {
      await _firestore.collection('gam3yas').doc(gam3yaId).update({
        'payments': FieldValue.arrayUnion([payment.toJson()]),
      });
    } catch (e) {
      print('Error recording payment: $e');
      rethrow;
    }
  }


  Future<void> verifyPayment(String gam3yaId, String paymentId , String verificationCode) async {
    try {
      await _firestore.collection('gam3yas').doc(gam3yaId).update({
        'payments.$paymentId.verified': true,
        'payments.$paymentId.verificationCode': verificationCode,
      });
    } catch (e) {
      print('Error verifying payment: $e');
      rethrow;
    }
  }

  // Admin related methods
  Future<List<app_user.User>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) => app_user.User.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e) {
      print('Error fetching all users: $e');
      rethrow;
    }
  }

  Future<List<Gam3ya>> getAllGam3yas() async {
    try {
      final querySnapshot = await _firestore.collection('gam3yas').get();
      return querySnapshot.docs.map((doc) => Gam3ya.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e) {
      print('Error fetching all Gam3yas: $e');
      rethrow;
    }
  }

  Future<List<Gam3ya>> getPendingGam3yas() async {
    try {
      final querySnapshot = await _firestore
          .collection('gam3yas')
          .where('status', isEqualTo: Gam3yaStatus.pending.toString())
          .get();
      
      return querySnapshot.docs.map((doc) => Gam3ya.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e) {
      print('Error fetching pending Gam3yas: $e');
      rethrow;
    }
  }

  Stream<List<Gam3ya>> getUserGam3yasStream(String userId) {
    return _firestore
        .collection('gam3yas')
        .where('members', arrayContains: {
          'userId': userId,
        })
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Gam3ya.fromJson({
            'id': doc.id,
            ...doc.data(),
          })).toList();
        });
  }
  // here all methods for payment
  Stream<List<Gam3yaPayment>> getUserPaymentsStream(String userId) {
    return _firestore
        .collection('gam3yas')
        .where('payments', arrayContains: {
          'userId': userId,
        })
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Gam3yaPayment.fromJson({
            'id': doc.id,
            ...doc.data(),
          })).toList();
        });
  }
  Stream<List<Gam3yaPayment>> getGam3yaPaymentsStream(String gam3yaId) {
    return _firestore
        .collection('gam3yas')
        .doc(gam3yaId)
        .snapshots()
        .map((snapshot) {
          final gam3ya = Gam3ya.fromJson({
            'id': snapshot.id,
            ...snapshot.data()!,
          });
          return gam3ya.payments;
        });
  }
  // need create getAllPayments
  Future<List<Gam3yaPayment>> getAllPayments() async {
    try {
      final querySnapshot = await _firestore.collection('gam3yas').get();
      return querySnapshot.docs.map((doc) => Gam3yaPayment.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e) {
      print('Error fetching all payments: $e');
      rethrow;
    }
  }

  // need create createpayment
  Future<void> createPayment(Gam3yaPayment payment) async {
    try {
      await _firestore.collection('payments').doc(payment.id).set(payment.toJson());
    } catch (e) {
      print('Error creating payment: $e');
      rethrow;
    }
  }
  // need create getPaymentById 
  Future<Gam3yaPayment?> getPaymentById(String paymentId) async {
    try {
      final docSnapshot = await _firestore.collection('payments').doc(paymentId).get();
      if (docSnapshot.exists) {
        return Gam3yaPayment.fromJson({
          'id': docSnapshot.id,
          ...docSnapshot.data()!,
        });
      }
      return null;
    } catch (e) {
      print('Error fetching payment: $e');
      rethrow;
    }
  }
  // need create getAllPaymentsByUserId 
  Future<List<Gam3yaPayment>> getAllPaymentsByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore.collection('payments').where('userId', isEqualTo: userId).get();
      return querySnapshot.docs.map((doc) => Gam3yaPayment.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e) {
      print('Error fetching payments by user ID: $e');
      rethrow;
    }
  }
  // need create getAllPaymentsByGam3yaId
  Future<List<Gam3yaPayment>> getAllPaymentsByGam3yaId(String gam3yaId) async {
    try {
      final querySnapshot = await _firestore.collection('payments').where('gam3yaId', isEqualTo: gam3yaId).get();
      return querySnapshot.docs.map((doc) => Gam3yaPayment.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e) {
      print('Error fetching payments by Gam3ya ID: $e');
      rethrow;
    }
  }
}

// class ProfileImageService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final ImagePicker _picker = ImagePicker();

//   // Pick image from gallery
//   Future<File?> pickImageFromGallery() async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1000,
//         maxHeight: 1000,
//         imageQuality: 85,
//       );
      
//       if (pickedFile == null) return null;
//       return File(pickedFile.path);
//     } catch (e) {
//       debugPrint('Error picking image: $e');
//       return null;
//     }
//   }

//   // Pick image from camera
//   Future<File?> pickImageFromCamera() async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: ImageSource.camera,
//         maxWidth: 1000,
//         maxHeight: 1000,
//         imageQuality: 85,
//       );
      
//       if (pickedFile == null) return null;
//       return File(pickedFile.path);
//     } catch (e) {
//       debugPrint('Error taking photo: $e');
//       return null;
//     }
//   }

//   // Upload image to Firebase Storage
//   Future<String?> uploadImageToStorage(String userId, File imageFile) async {
//     try {
//       // Create a reference to the location you want to upload to in Firebase Storage
//       final String fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.${path.extension(imageFile.path).replaceAll('.', '')}';
//       final Reference storageRef = _storage.ref().child('profile_images/$fileName');
      
//       // Upload the file to Firebase Storage
//       final UploadTask uploadTask = storageRef.putFile(imageFile);
      
//       // Wait until the file is uploaded then return the download URL
//       final TaskSnapshot taskSnapshot = await uploadTask;
//       final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      
//       return downloadUrl;
//     } catch (e) {
//       debugPrint('Error uploading image to storage: $e');
//       return null;
//     }
//   }

//   // Update user's profile image URL in Firestore
//   Future<bool> updateProfileImageUrl(String userId, String imageUrl) async {
//     try {
//       await _firestore.collection('users').doc(userId).update({
//         'profileImage': imageUrl,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//       return true;
//     } catch (e) {
//       debugPrint('Error updating profile image in Firestore: $e');
//       return false;
//     }
//   }

//   // Complete flow: Pick, upload and update profile image
//   Future<bool> updateProfileImage({
//     required String userId,
//     required bool fromCamera,
//   }) async {
//     try {
//       // 1. Pick image
//       final File? imageFile = fromCamera 
//           ? await pickImageFromCamera()
//           : await pickImageFromGallery();
      
//       if (imageFile == null) return false;
      
//       // 2. Upload to Firebase Storage
//       final String? downloadUrl = await uploadImageToStorage(userId, imageFile);
      
//       if (downloadUrl == null) return false;
      
//       // 3. Update user profile in Firestore
//       return await updateProfileImageUrl(userId, downloadUrl);
//     } catch (e) {
//       debugPrint('Error in profile image update flow: $e');
//       return false;
//     }
//   }
// }