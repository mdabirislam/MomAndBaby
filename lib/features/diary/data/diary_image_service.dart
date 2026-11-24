import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class DiaryImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<List<String>> pickAndSaveImages({
    required List<String> existingPaths,
    required bool fromCamera,
  }) async {
    List<XFile> picked;
    if (fromCamera) {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      picked = file == null ? <XFile>[] : <XFile>[file];
    } else {
      picked = await _picker.pickMultiImage(imageQuality: 85, maxWidth: 1800);
    }

    if (picked.isEmpty) return existingPaths;

    final appDir = await getApplicationDocumentsDirectory();
    final diaryDir = Directory('${appDir.path}/diary_images');
    if (!await diaryDir.exists()) await diaryDir.create(recursive: true);

    final paths = [...existingPaths];
    for (final image in picked) {
      final extension = image.path.contains('.')
          ? image.path.substring(image.path.lastIndexOf('.'))
          : '.jpg';
      final target = File(
        '${diaryDir.path}/diary_${DateTime.now().microsecondsSinceEpoch}_${paths.length}$extension',
      );
      await File(image.path).copy(target.path);
      paths.add(target.path);
    }
    return paths;
  }

  static Future<void> deleteUnusedImages(
    List<String> oldPaths,
    List<String> retainedPaths,
  ) async {
    final retained = retainedPaths.toSet();
    for (final path in oldPaths) {
      if (retained.contains(path)) continue;
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {
        // A missing image should not prevent saving or deleting a diary entry.
      }
    }
  }
}
