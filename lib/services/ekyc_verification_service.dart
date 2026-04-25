import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Parse a DD/MM/YYYY string into DateTime, or return null.
DateTime? parseDmy(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    return DateFormat('dd/MM/yyyy').parse(raw);
  } catch (_) {
    return null;
  }
}

/// Format a DateTime as DD/MM/YYYY.
String formatDmy(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

class EkycVerificationService {
  // Your API Gateway endpoint for eKYC face check
  static const String _baseUrl =
      'https://lkbfwrwy56.execute-api.ap-southeast-1.amazonaws.com/prod';

  /// Unwrap API Gateway Lambda proxy response if needed.
  /// Some endpoints return the raw proxy object: { statusCode, headers, body }
  static Map<String, dynamic> _unwrapResponse(String responseBody) {
    final data = jsonDecode(responseBody);

    if (data is Map<String, dynamic> &&
        data.containsKey('body') &&
        data['body'] is String) {
      final inner = jsonDecode(data['body']);
      if (inner is Map<String, dynamic>) {
        return inner;
      }
    }

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw Exception('Unexpected response format');
  }

  /// Format a DateTime as DD/MM/YYYY for API payload.
  static String _formatDmy(DateTime date) => formatDmy(date);

  /// Call eKYC verification Lambda (handles both IC and Passport)
  /// NOTE: This only performs face comparison + OCR extraction.
  /// It does NOT persist data to DynamoDB.
  static Future<EkycResult> verifyIdentity({
    required String userId,
    required String documentType, // 'IC' or 'PASSPORT'
    required String documentKey, // S3 key for IC front or passport
    required String selfieKey, // S3 key for selfie
  }) async {
    try {
      final requestBody = jsonEncode({
        'userId': userId,
        'documentType': documentType,
        'documentKey': documentKey,
        'selfieKey': selfieKey,
      });

      print('🔵 Calling eKYC API: $_baseUrl/verify-ekyc');
      print('🔵 Request body: $requestBody');

      final response = await http.post(
        Uri.parse('$_baseUrl/verify-ekyc'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      print('🔵 Response status: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = _unwrapResponse(response.body);
        return EkycResult.fromJson(data);
      } else {
        throw Exception('Verification failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during verification: $e');
    }
  }

  /// Submit finalized KYC data to be persisted in DynamoDB
  /// Call this AFTER the user has reviewed and confirmed their details.
  static Future<SubmitKycResult> submitKyc({
    required String userId,
    required String documentType,
    required String documentKey,
    String? icBackKey,
    required String selfieKey,
    required String fullName,
    required String idNumber,
    required DateTime dateOfBirth,
    DateTime? dateOfExpiry,
    required String country,
    required String occupation,
    required String businessType,
    double? similarity,
    String? riskScore,
    String? message,
  }) async {
    try {
      final requestBody = jsonEncode({
        'userId': userId,
        'documentType': documentType,
        'documentKey': documentKey,
        if (icBackKey != null) 'icBackKey': icBackKey,
        'selfieKey': selfieKey,
        'fullName': fullName,
        'documentNumber': idNumber,
        'dateOfBirth': _formatDmy(dateOfBirth),
        if (dateOfExpiry != null) 'dateOfExpiry': _formatDmy(dateOfExpiry),
        'country': country,
        'occupation': occupation,
        'businessType': businessType,
        if (similarity != null) 'similarity': similarity,
        if (riskScore != null) 'riskScore': riskScore,
        if (message != null) 'message': message,
      });

      print('🟢 Calling submit-kyc API: $_baseUrl/submit-kyc');
      print('🟢 Request body: $requestBody');

      final response = await http.post(
        Uri.parse('$_baseUrl/submit-kyc'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      print('🟢 Response status: ${response.statusCode}');
      print('🟢 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = _unwrapResponse(response.body);

        if (data.containsKey('error')) {
          throw Exception(data['error']);
        }

        return SubmitKycResult.fromJson(data);
      } else {
        throw Exception('Submit KYC failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error submitting KYC: $e');
    }
  }
}

/// Result from eKYC verification
class EkycResult {
  final String status; // VERIFIED, PENDING, FAILED
  final double similarity; // Face match similarity score
  final String riskScore; // LOW, MEDIUM, HIGH
  final String message; // Human-readable message
  final String documentType; // IC or PASSPORT
  final String? documentNumber;
  final String? extractedName;
  final String? country;
  final DateTime? dateOfBirth; // Parsed from DD/MM/YYYY
  final DateTime? dateOfExpiry; // Passport only

  EkycResult({
    required this.status,
    required this.similarity,
    required this.riskScore,
    required this.message,
    required this.documentType,
    this.documentNumber,
    this.extractedName,
    this.country,
    this.dateOfBirth,
    this.dateOfExpiry,
  });

  factory EkycResult.fromJson(Map<String, dynamic> json) {
    return EkycResult(
      status: json['status'] as String,
      similarity: (json['similarity'] as num).toDouble(),
      riskScore: json['riskScore'] as String,
      message: json['message'] as String,
      documentType: json['documentType'] as String,
      documentNumber: json['documentNumber'] as String?,
      extractedName: json['extractedName'] as String?,
      country: json['country'] as String?,
      dateOfBirth: parseDmy(json['dateOfBirth'] as String?),
      dateOfExpiry: parseDmy(json['dateOfExpiry'] as String?),
    );
  }

  bool get isVerified => status == 'VERIFIED';
  bool get needsReview => status == 'PENDING';
  bool get isFailed => status == 'FAILED';
  bool get isPassport => documentType == 'PASSPORT';
  bool get isIc => documentType == 'IC';
}

/// Result from KYC submission (persist to DynamoDB)
class SubmitKycResult {
  final String status; // SUCCESS, FAILED
  final String message;
  final String? kycStatus; // VERIFIED, PENDING, FAILED

  SubmitKycResult({
    required this.status,
    required this.message,
    this.kycStatus,
  });

  factory SubmitKycResult.fromJson(Map<String, dynamic> json) {
    return SubmitKycResult(
      status: (json['status'] ?? 'UNKNOWN') as String,
      message: (json['message'] ?? '') as String,
      kycStatus: json['kycStatus'] as String?,
    );
  }

  bool get isSuccess => status == 'SUCCESS' || status == 'SUBMITTED';
}
