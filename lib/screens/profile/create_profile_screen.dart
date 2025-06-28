import 'dart:convert';
import 'dart:io';
import 'package:algobait/screens/subscription/subscription_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

// Top-level function for isolate to process the image.
// This needs to be a top-level function or a static method.
Future<String> _processImage(Uint8List imageBytes) async {
  img.Image? originalImage = img.decodeImage(imageBytes);
  if (originalImage != null) {
    img.Image resizedImage = img.copyResize(originalImage, width: 500);
    final resizedBytes = img.encodeJpg(resizedImage, quality: 85);
    return base64Encode(resizedBytes);
  }
  return base64Encode(imageBytes);
}

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  static const primaryColor = Color(0xFF4B39EF);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Пользователь не найден. Пожалуйста, войдите снова.');
      }

      String? imageBase64;
      if (_imageFile != null) {
        final imageBytes = await _imageFile!.readAsBytes();
        imageBase64 = await compute(_processImage, imageBytes);
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': _nameController.text.trim(),
        'profile_picture_base64': imageBase64,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_route', '/subscription');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль успешно сохранен!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Произошла неизвестная ошибка.';
        if (e is PlatformException) {
          errorMessage = 'Ошибка платформы: ${e.message ?? "нет данных"} (Код: ${e.code})';
        } else {
          errorMessage = 'Ошибка сохранения: ${e.toString()}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), duration: const Duration(seconds: 5)),
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
    return WillPopScope(
      onWillPop: () async => false, // Orqaga qaytishni bloklash
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false, // Orqaga tugmasini olib tashlash
          title: Text(
            'Создайте свой профиль',
            style: GoogleFonts.outfit(
              color: primaryColor,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20), // Elementlarni tepaga surish uchun
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null
                        ? const Icon(Icons.camera_alt, color: Colors.grey, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Ваше имя',
                    labelStyle: GoogleFonts.plusJakartaSans(color: primaryColor, fontWeight: FontWeight.w600),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red.shade700, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red.shade700, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Пожалуйста, введите имя';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: 270,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _saveProfile,
                          child: Text(
                            'Сохранить',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
