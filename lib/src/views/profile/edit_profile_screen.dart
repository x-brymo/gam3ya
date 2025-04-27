// edit_profile_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/controllers/user_provider.dart' show currentUserProvider, userServiceProvider;

import 'package:gam3ya/src/widgets/common/custom_text_field.dart';
import 'package:gam3ya/src/widgets/common/loading_indicator.dart';

import '../../services/upload_image_service.dart';


class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  File? _imageFile;
  bool _isLoading = false;

  final ProfileImageService _profileImageService = ProfileImageService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();

    Future.microtask(() {
      final userAsync = ref.read(currentUserProvider);
      userAsync.whenData((user) {
        _nameController.text = user.name;
        _phoneController.text = user.phone;
            });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _profileImageService.pickImage();
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = await ref.read(currentUserProvider.future);

      String? photoUrl = currentUser.photoUrl;

      // ارفع الصورة لو تم اختيارها
      if (_imageFile != null) {
        final uploadedUrl = await _profileImageService.uploadToImgBB(_imageFile!);
        if (uploadedUrl != null) {
          photoUrl = uploadedUrl;
          await _profileImageService.updateProfileImageInFirestore(currentUser.id, photoUrl);
        }
      }

      // تحديث البيانات الأخرى
      final updatedUser = currentUser.copyWith(
        name: _nameController.text,
        phone: _phoneController.text,
        photoUrl: photoUrl,
      );

      final userService = ref.read(userServiceProvider);
      await userService.updateUserProfile(currentUser.id, updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي'),
      ),
      body: userAsync.when(
        data: (user) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 64,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!) as ImageProvider
                              : (user.photoUrl.isNotEmpty
                                  ? NetworkImage(user.photoUrl)
                                  : const AssetImage('assets/images/default_profile.png')) as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  CustomTextField(
                    controller: _nameController,
                    labelText: 'الاسم الكامل',
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'من فضلك أدخل اسمك';
                      if (value.length < 3) return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _phoneController,
                    labelText: 'رقم الهاتف',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'من فضلك أدخل رقم الهاتف';
                      if (value.length < 10) return 'رقم الهاتف غير صحيح';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    initialValue: user.email,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: const Tooltip(
                        message: 'لا يمكن تغيير البريد الإلكتروني',
                        child: Icon(Icons.info_outline),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: _updateProfile,
                          icon: const Icon(Icons.save),
                          label: const Text('حفظ التغييرات'),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        ),
                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile/change-password');
                    },
                    icon: const Icon(Icons.lock),
                    label: const Text('تغيير كلمة المرور'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                  const SizedBox(height: 16),

                  if (user.guarantorUserId == null)
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile/add-guarantor');
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('إضافة ضامن'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, stack) => Center(child: Text('حدث خطأ: $error')),
      ),
    );
  }
}
