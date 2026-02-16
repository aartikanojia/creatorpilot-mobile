/// User entity representing an authenticated creator.
///
/// Holds session data persisted in secure storage and
/// plan/usage info fetched from the backend.
class User {
  const User({
    required this.userId,
    required this.channelId,
    required this.channelName,
    this.plan = 'free',
    this.queriesUsed = 0,
    this.queryLimit = 3,
    this.isLimitExhausted = false,
  });

  final String userId;
  final String channelId;
  final String channelName;
  final String plan;
  final int queriesUsed;
  final int queryLimit;
  final bool isLimitExhausted;

  /// Whether the user is on the free plan.
  bool get isFree => plan.toLowerCase() == 'free';

  /// Whether the user is on the PRO plan.
  bool get isPro => plan.toLowerCase() == 'pro';

  /// Remaining queries for the current billing period.
  int get queriesRemaining => (queryLimit - queriesUsed).clamp(0, queryLimit);

  /// Create a copy with updated fields.
  User copyWith({
    String? userId,
    String? channelId,
    String? channelName,
    String? plan,
    int? queriesUsed,
    int? queryLimit,
    bool? isLimitExhausted,
  }) {
    return User(
      userId: userId ?? this.userId,
      channelId: channelId ?? this.channelId,
      channelName: channelName ?? this.channelName,
      plan: plan ?? this.plan,
      queriesUsed: queriesUsed ?? this.queriesUsed,
      queryLimit: queryLimit ?? this.queryLimit,
      isLimitExhausted: isLimitExhausted ?? this.isLimitExhausted,
    );
  }
}
