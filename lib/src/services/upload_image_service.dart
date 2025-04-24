import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ProfileImageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ImgBB API key - you'll need to get your own free API key from https://api.imgbb.com/
  // After registering, you can get a free API key with limited daily uploads
  final String _imgbbApiKey = 'ffba365610440d75965743577db7b416';
  
  // Function to pick an image from gallery or camera
  Future<File?> pickImage({bool fromCamera = false}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
  
  // Upload image to ImgBB and return the URL
  Future<String?> uploadToImgBB(File imageFile) async {
    try {
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload?key=$_imgbbApiKey'),
      );
      
      // Get file name
      final fileName = path.basename(imageFile.path);
      
      // Attach file to request
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          filename: fileName,
        ),
      );
      
      // Send request
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);
      
      // Check if upload was successful
      if (response.statusCode == 200 && jsonData['success'] == true) {
        // Return image URL
        return jsonData['data']['url'];
      } else {
        print('Failed to upload image: ${jsonData['error']['message']}');
        return null;
      }
    } catch (e) {
      print('Error uploading image to ImgBB: $e');
      return null;
    }
  }
  
  // Update user profile with image URL in Firestore
  Future<void> updateProfileImageInFirestore(String userId, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profileImage': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Profile image updated successfully');
    } catch (e) {
      print('Error updating profile image in Firestore: $e');
      rethrow;
    }
  }
  
  // Complete process: Pick image, upload to ImgBB, update Firestore
  Future<bool> updateUserProfileImage(String userId, {bool fromCamera = false}) async {
    try {
      // Pick image
      final imageFile = await pickImage(fromCamera: fromCamera);
      if (imageFile == null) {
        print('No image selected');
        return false;
      }
      
      // Upload to ImgBB
      final imageUrl = await uploadToImgBB(imageFile);
      if (imageUrl == null) {
        print('Failed to get image URL from ImgBB');
        return false;
      }
      
      // Update Firestore
      await updateProfileImageInFirestore(userId, imageUrl);
      return true;
    } catch (e) {
      print('Error updating user profile image: $e');
      return false;
    }
  }
}

// Example usage:
// ProfileImageService profileService = ProfileImageService();
// await profileService.updateUserProfileImage('userIdHere');