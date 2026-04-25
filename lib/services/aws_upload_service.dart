import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class AwsUploadService {
  // Your API Gateway endpoint
  static const String _baseUrl =
      'https://z51dnqg1cd.execute-api.ap-southeast-1.amazonaws.com';

  /// Step 1: Get presigned upload URL from Lambda
  static Future<Map<String, String>> getUploadUrl({
    required String fileType,
    required String userId,
    required String contentType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/generate-upload-url'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fileType': fileType,
          'userId': userId,
          'contentType': contentType,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'uploadUrl': data['uploadUrl'] as String,
          'fileKey': data['fileKey'] as String,
        };
      } else {
        throw Exception('Failed to get upload URL: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting upload URL: $e');
    }
  }

  /// Step 2: Upload file to S3 using presigned URL
  static Future<bool> uploadToS3({
    required String uploadUrl,
    required Uint8List fileBytes,
    required String contentType,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': contentType},
        body: fileBytes,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error uploading to S3: $e');
    }
  }

  /// Combined method: Get URL + Upload in one call
  static Future<String> uploadFile({
    required String fileType,
    required String userId,
    required Uint8List fileBytes,
    required String contentType,
  }) async {
    // Step 1: Get presigned URL
    final urlData = await getUploadUrl(
      fileType: fileType,
      userId: userId,
      contentType: contentType,
    );

    // Step 2: Upload to S3
    final success = await uploadToS3(
      uploadUrl: urlData['uploadUrl']!,
      fileBytes: fileBytes,
      contentType: contentType,
    );

    if (success) {
      return urlData['fileKey']!;
    } else {
      throw Exception('Upload failed');
    }
  }
}
