import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Visit photos live as files in the app's documents folder; the visit only
/// stores their paths. The camera's own copy sits in a cache the system may
/// clear, so every photo is copied here before it is saved with a visit.
class LocalPhotos {
  LocalPhotos._();

  static Future<Directory> _visitFolder(String visitID) async {
    final documents = await getApplicationDocumentsDirectory();
    final folder =
        Directory('${documents.path}${Platform.pathSeparator}visit_photos'
            '${Platform.pathSeparator}$visitID');
    if (!await folder.exists()) await folder.create(recursive: true);
    return folder;
  }

  /// Copies [tempPath] into the visit's folder and returns the new path.
  static Future<String> keep(
      {required String tempPath,
      required String visitID,
      required String photoID}) async {
    final source = File(tempPath);
    if (!await source.exists()) {
      throw const FileSystemException('The photo file is missing.');
    }
    final dot = tempPath.lastIndexOf('.');
    final extension = dot == -1 ? '.jpg' : tempPath.substring(dot);
    final folder = await _visitFolder(visitID);
    final saved = await source
        .copy('${folder.path}${Platform.pathSeparator}$photoID$extension');
    return saved.path;
  }

  /// Best-effort clean-up of photo files, e.g. after a failed save.
  static Future<void> remove(Iterable<String> paths) async {
    for (final path in paths) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }

  /// Removes every photo of a deleted visit.
  static Future<void> removeVisit(String visitID) async {
    try {
      final folder = await _visitFolder(visitID);
      await folder.delete(recursive: true);
    } catch (_) {}
  }
}
