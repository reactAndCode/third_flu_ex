class Conversation {
  final String? id;
  final String? name;
  final String type;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? lastMessageContent;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final List<String>? participantIds;

  Conversation({
    this.id,
    this.name,
    this.type = 'direct',
    required this.createdAt,
    this.updatedAt,
    this.lastMessageContent,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.participantIds,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'],
      name: map['name'],
      type: map['type'] ?? 'direct',
      createdAt: _parseDate(map['created_at']),
      updatedAt: map['updated_at'] != null ? _parseDate(map['updated_at']) : null,
      lastMessageContent: map['last_message_content'],
      lastMessageTime: map['last_message_time'] != null ? _parseDate(map['last_message_time']) : null,
      unreadCount: map['unread_count'] ?? 0,
      participantIds: map['participant_ids'] != null
          ? List<String>.from(map['participant_ids'])
          : null,
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

  Conversation copyWith({
    String? id,
    String? name,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessageContent,
    DateTime? lastMessageTime,
    int? unreadCount,
    List<String>? participantIds,
  }) {
    return Conversation(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      participantIds: participantIds ?? this.participantIds,
    );
  }
}
