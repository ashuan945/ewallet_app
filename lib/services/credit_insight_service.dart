import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_credit_insight.dart';

class CreditInsightService {
  static const String _baseUrl =
      'https://u2yet7si41.execute-api.ap-southeast-1.amazonaws.com/prod';

  /// Fetch AI-generated credit insight for a given user.
  static Future<AiCreditInsight> fetchInsight({required String userId}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/generate-ai-insight'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AiCreditInsight.fromApiResponse(data);
      } else {
        throw Exception('Failed to fetch insight: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching credit insight: $e');
    }
  }
}
