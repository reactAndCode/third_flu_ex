class UserProfile {
  final String userId;
  final String? nickname;
  final String? avatarUrl;
  final String? statusMessage;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.userId,
    this.nickname,
    this.avatarUrl,
    this.statusMessage,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      if (nickname != null) 'nickname': nickname,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (statusMessage != null) 'status_message': statusMessage,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['user_id'] ?? '',
      nickname: map['nickname'],
      avatarUrl: map['avatar_url'],
      statusMessage: map['status_message'],
      createdAt: _parseDate(map['created_at']),
      updatedAt: map['updated_at'] != null ? _parseDate(map['updated_at']) : null,
    );
  }

  static DateTime _parseDate(dynamic dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      if (dateStr is String) {
        return DateTime.parse(dateStr);
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  UserProfile copyWith({
    String? userId,
    String? nickname,
    String? avatarUrl,
    String? statusMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      statusMessage: statusMessage ?? this.statusMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
