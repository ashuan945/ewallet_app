import 'dart:convert';

/// Model for AI-generated credit insight from the generate-ai-insight API.
class AiCreditInsight {
  final double creditScore;
  final String creditTier;
  final List<String> scoreExplanation;
  final List<String> futureScoreDrivers;
  final List<String> improvementPlan;

  const AiCreditInsight({
    required this.creditScore,
    required this.creditTier,
    required this.scoreExplanation,
    required this.futureScoreDrivers,
    required this.improvementPlan,
  });

  /// Parse from the deeply nested API response.
  ///
  /// The response structure is:
  /// { statusCode: 200, body: '{"user_id":"...","analysis":{...}}' }
  ///
  /// Inside analysis.choices[0].message.content is a JSON string containing:
  /// { credit_analysis: {...}, improvement_plan: [...] }
  factory AiCreditInsight.fromApiResponse(Map<String, dynamic> json) {
    // Step 1: Unwrap API Gateway body if present
    final bodyRaw = json['body'];
    final Map<String, dynamic> body;
    if (bodyRaw is String) {
      body = _safeJsonDecode(bodyRaw);
    } else if (bodyRaw is Map<String, dynamic>) {
      body = bodyRaw;
    } else {
      body = json;
    }

    // Step 2: Extract analysis object
    final analysis = body['analysis'] as Map<String, dynamic>? ?? {};

    // Step 3: Extract choices -> message -> content
    final choices = analysis['choices'] as List<dynamic>? ?? [];
    final firstChoice = choices.isNotEmpty ? choices[0] as Map<String, dynamic>? ?? {} : {};
    final message = firstChoice['message'] as Map<String, dynamic>? ?? {};
    final contentRaw = message['content'] as String? ?? '{}';

    // Step 4: Parse the content JSON string
    final content = _safeJsonDecode(contentRaw);

    // Step 5: Extract credit_analysis fields
    final creditAnalysis = content['credit_analysis'] as Map<String, dynamic>? ?? {};

    final score = (creditAnalysis['credit_score'] as num?)?.toDouble() ?? 0.0;
    final tier = (creditAnalysis['credit_tier'] as String?) ?? 'Unknown';

    final explanations = _toStringList(creditAnalysis['score_explanation']);
    final drivers = _toStringList(creditAnalysis['future_score_drivers']);

    // Step 6: Extract improvement_plan
    final plan = _toStringList(content['improvement_plan']);

    return AiCreditInsight(
      creditScore: score,
      creditTier: tier,
      scoreExplanation: explanations,
      futureScoreDrivers: drivers,
      improvementPlan: plan,
    );
  }

  static Map<String, dynamic> _safeJsonDecode(String raw) {
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }
}
