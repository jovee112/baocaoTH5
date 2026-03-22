import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class ImageService {
  final ImagePicker _imagePicker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _bucketName = 'images';

  // Chọn ảnh từ gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi chọn ảnh: $e');
    }
  }

  // Chụp ảnh từ camera (chỉ hỗ trợ mobile)
  Future<File?> pickImageFromCamera() async {
    try {
      if (kIsWeb) {
        throw Exception('Camera không hỗ trợ trên Web');
      }
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi chụp ảnh: $e');
    }
  }

  // Upload ảnh lên Supabase Storage
  Future<String> uploadStudentImage(
    dynamic imageFile,
    String studentId,
  ) async {
    try {
      // Tạo tên file duy nhất
      final fileName =
          '${studentId}_${const Uuid().v4()}.jpg';
      final filePath = 'student_$studentId/$fileName';

      late final List<int> fileBytes;

      if (kIsWeb) {
        // Web: XFile bytes
        if (imageFile is XFile) {
          fileBytes = await imageFile.readAsBytes();
        } else {
          throw Exception('File không hợp lệ');
        }
      } else {
        // Mobile: File
        if (imageFile is File) {
          fileBytes = await imageFile.readAsBytes();
        } else if (imageFile is XFile) {
          fileBytes = await imageFile.readAsBytes();
        } else {
          throw Exception('File không hợp lệ');
        }
      }

      // Upload file lên Supabase Storage
      await _supabase.storage.from(_bucketName).uploadBinary(
            filePath,
            Uint8List.fromList(fileBytes),
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Lấy public URL
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Lỗi khi upload ảnh: $e');
    }
  }

  // Xóa ảnh từ Supabase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return;

      // Trích xuất đường dẫn từ URL public
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // URL format: .../storage/v1/object/public/student-images/student_xxx/file.jpg
      if (pathSegments.length >= 6) {
        final filePath =
            '${pathSegments[pathSegments.length - 2]}/${pathSegments[pathSegments.length - 1]}';
        await _supabase.storage.from(_bucketName).remove([filePath]);
      }
    } catch (e) {
      throw Exception('Lỗi khi xóa ảnh: $e');
    }
  }
}

