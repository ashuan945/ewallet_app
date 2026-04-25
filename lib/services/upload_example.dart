// =====================================================
// AWS S3 UPLOAD - USAGE EXAMPLE
// =====================================================
// This file shows how the upload service works.
// The actual implementation is already in:
// lib/screens/kyc/kyc_document_screen.dart
// =====================================================

import 'dart:typed_data';
import '../services/aws_upload_service.dart';

// NOTE: This is documentation-only. See kyc_document_screen.dart for real usage.

class UploadExample {
  /// Example 1: Two-step upload (manual control)
  Future<void> twoStepUpload(Uint8List imageBytes) async {
    try {
      // STEP 1: Call your API to get presigned URL
      final urlData = await AwsUploadService.getUploadUrl(
        fileType: 'ic_front', // or 'ic_back', 'passport'
        userId: 'user_12345', // your user ID
        contentType: 'image/jpeg', // or 'image/png'
      );

      print('Upload URL: ${urlData['uploadUrl']}');
      print('File Key: ${urlData['fileKey']}');

      // STEP 2: Upload image directly to S3
      final success = await AwsUploadService.uploadToS3(
        uploadUrl: urlData['uploadUrl']!,
        fileBytes: imageBytes,
        contentType: 'image/jpeg',
      );

      if (success) {
        print('✅ Upload successful!');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  /// Example 2: One-step upload (simplest)
  Future<void> oneStepUpload(Uint8List imageBytes) async {
    try {
      // This does both steps: get URL + upload
      final fileKey = await AwsUploadService.uploadFile(
        fileType: 'ic_front',
        userId: 'user_12345',
        fileBytes: imageBytes,
        contentType: 'image/jpeg',
      );

      print('✅ File uploaded! S3 Key: $fileKey');
      // File will be at: s3://ekyc-ashuan-01/uploads/ic_front_user_12345.jpg
    } catch (e) {
      print('❌ Upload failed: $e');
    }
  }
}

// =====================================================
// HOW IT WORKS:
// =====================================================
// 1. User taps "Upload IC Front" button
// 2. App picks image from camera/gallery
// 3. App calls: POST /generate-upload-url
//    → Lambda generates presigned URL
//    → Returns: { uploadUrl: "...", fileKey: "..." }
// 4. App calls: PUT <uploadUrl> with image bytes
//    → S3 stores the image
// 5. Success! Image is now in S3 bucket
//
// S3 File Structure:
// ekyc-ashuan-01/
//   └── uploads/
//       ├── ic_front_user_12345.jpg
//       ├── ic_back_user_12345.jpg
//       └── passport_user_67890.jpg
// =====================================================
