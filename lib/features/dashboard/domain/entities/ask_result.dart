/// Domain entity for AI ask/execute results.
class AskResult {
  const AskResult({
    this.answer = '',
    this.confidence = 0.0,
    this.toolsUsed = const [],
    this.contentType,
    this.success = true,
    this.error,
  });

  final String answer;
  final double confidence;
  final List<String> toolsUsed;
  final String? contentType;
  final bool success;
  final Map<String, dynamic>? error;

  /// Whether the query hit the plan limit.
  bool get isPlanLimitReached =>
      error != null && error!['code'] == 'PLAN_LIMIT_REACHED';

  factory AskResult.fromJson(Map<String, dynamic> json) {
    return AskResult(
      answer: json['answer'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      toolsUsed: (json['tools_used'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      contentType: json['content_type'] as String?,
      success: json['success'] as bool? ?? true,
      error: json['error'] as Map<String, dynamic>?,
    );
  }
}
