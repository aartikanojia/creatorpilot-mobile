/// Domain entity for a video performance analysis.
class VideoAnalysis {
  const VideoAnalysis({
    this.answer = '',
    this.confidence = 0.0,
    this.success = true,
    this.error,
  });

  final String answer;
  final double confidence;
  final bool success;
  final Map<String, dynamic>? error;

  bool get isPlanLimitReached =>
      error != null && error!['code'] == 'PLAN_LIMIT_REACHED';

  factory VideoAnalysis.fromJson(Map<String, dynamic> json) {
    return VideoAnalysis(
      answer: json['answer'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      success: json['success'] as bool? ?? true,
      error: json['error'] as Map<String, dynamic>?,
    );
  }
}
