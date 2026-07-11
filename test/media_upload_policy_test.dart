import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:result_publishing_app/features/home/application/media_upload_policy.dart';

void main() {
  const policy = MediaUploadPolicy();

  test('accepts supported media within size limits', () {
    final result = policy.validate(
      existingFiles: const [],
      selectedFiles: [
        PlatformFile(name: 'proof.jpg', size: 2 * 1024 * 1024),
        PlatformFile(name: 'clip.mp4', size: 10 * 1024 * 1024),
      ],
      maxFiles: 4,
    );

    expect(result.accepted.length, 2);
    expect(result.rejected, isEmpty);
  });

  test('rejects unsupported media extensions', () {
    final result = policy.validate(
      existingFiles: const [],
      selectedFiles: [
        PlatformFile(name: 'script.exe', size: 100),
      ],
      maxFiles: 4,
    );

    expect(result.accepted, isEmpty);
    expect(result.rejected.single, contains('unsupported'));
  });

  test('rejects files beyond allowed count', () {
    final result = policy.validate(
      existingFiles: [
        PlatformFile(name: 'existing.jpg', size: 100),
      ],
      selectedFiles: [
        PlatformFile(name: 'new.jpg', size: 100),
      ],
      maxFiles: 1,
    );

    expect(result.accepted, isEmpty);
    expect(result.rejected.single, contains('maximum 1 files'));
  });
}
