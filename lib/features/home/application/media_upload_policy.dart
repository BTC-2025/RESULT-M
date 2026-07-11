import 'package:file_picker/file_picker.dart';

class MediaUploadPolicy {
  static const int maxImageBytes = 12 * 1024 * 1024;
  static const int maxVideoBytes = 80 * 1024 * 1024;
  static const int maxTotalBytes = 120 * 1024 * 1024;

  static const Set<String> allowedImageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
  };

  static const Set<String> allowedVideoExtensions = {
    'mp4',
    'mov',
    'webm',
  };

  const MediaUploadPolicy();

  MediaValidationResult validate({
    required List<PlatformFile> existingFiles,
    required Iterable<PlatformFile> selectedFiles,
    required int maxFiles,
  }) {
    final accepted = <PlatformFile>[];
    final rejected = <String>[];
    var totalBytes = existingFiles.fold<int>(
      0,
      (total, file) => total + file.size,
    );

    for (final file in selectedFiles) {
      if (existingFiles.length + accepted.length >= maxFiles) {
        rejected.add('${file.name}: maximum $maxFiles files allowed');
        continue;
      }

      final extension = _extension(file.name);
      final isImage = allowedImageExtensions.contains(extension);
      final isVideo = allowedVideoExtensions.contains(extension);
      if (!isImage && !isVideo) {
        rejected.add('${file.name}: unsupported media type');
        continue;
      }

      final maxBytes = isVideo ? maxVideoBytes : maxImageBytes;
      if (file.size > maxBytes) {
        rejected.add(
          '${file.name}: file is too large. Compress it before upload.',
        );
        continue;
      }

      if (totalBytes + file.size > maxTotalBytes) {
        rejected.add('${file.name}: total upload size limit exceeded');
        continue;
      }

      totalBytes += file.size;
      accepted.add(file);
    }

    return MediaValidationResult(accepted: accepted, rejected: rejected);
  }

  String _extension(String name) {
    final index = name.lastIndexOf('.');
    if (index == -1 || index == name.length - 1) return '';
    return name.substring(index + 1).toLowerCase();
  }
}

class MediaValidationResult {
  final List<PlatformFile> accepted;
  final List<String> rejected;

  const MediaValidationResult({
    required this.accepted,
    required this.rejected,
  });

  bool get hasRejected => rejected.isNotEmpty;
}
