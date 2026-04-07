// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: custom_why_image_service.dart
// Purpose: BW-39 custom why image helper.
// Notes: Picks one gallery image and copies it into app-owned storage.
// ------------------------------------------------------------

import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CustomWhyImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickAndPersistWhyImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return null;

    final Directory dir = await getApplicationDocumentsDirectory();
    final Directory whyDir = Directory('${dir.path}/why');
    if (!await whyDir.exists()) {
      await whyDir.create(recursive: true);
    }

    final String sourcePath = picked.path;
    final String extension = sourcePath.contains('.')
        ? sourcePath.substring(sourcePath.lastIndexOf('.'))
        : '.jpg';

    final String targetPath = '${whyDir.path}/custom_why_image$extension';
    final File copied = await File(sourcePath).copy(targetPath);
    return copied.path;
  }

  static Future<void> deleteImageIfPresent(String imagePath) async {
    if (imagePath.trim().isEmpty) return;
    final File file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
