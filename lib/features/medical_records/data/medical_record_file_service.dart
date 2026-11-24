import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Keeps picked medical images inside the app's documents directory.
/// Existing external paths remain readable and are never deleted by this service.
class MedicalRecordFileService {
  Future<List<String>> importImages(List<XFile> images) async {
    if (images.isEmpty) return const [];

    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory('${documents.path}/medical_records');
    await directory.create(recursive: true);

    final savedPaths = <String>[];
    try {
      for (final image in images) {
        final source = File(image.path);
        if (!await source.exists()) continue;

        final rawName = image.name.isEmpty ? 'report_image' : image.name;
        final safeName = rawName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
        final extension = safeName.contains('.')
            ? safeName.substring(safeName.lastIndexOf('.'))
            : '.jpg';
        final destination = File(
          '${directory.path}/${DateTime.now().microsecondsSinceEpoch}_${savedPaths.length}$extension',
        );
        await source.copy(destination.path);
        savedPaths.add(destination.path);
      }
      return savedPaths;
    } catch (_) {
      await deleteManagedFiles(savedPaths);
      rethrow;
    }
  }

  Future<void> deleteManagedFiles(List<String> paths) async {
    final documents = await getApplicationDocumentsDirectory();
    final managedDirectory =
        '${documents.path}${Platform.pathSeparator}medical_records${Platform.pathSeparator}';

    for (final path in paths) {
      if (!path.startsWith(managedDirectory)) continue;
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
