class Message {
  final String? id;
  final String conversationId;
  final String senderId;
  final String content;
  final String messageType;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Message({
    this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.messageType = 'text',
    this.isDeleted = false,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      conversationId: map['conversation_id'] ?? '',
      senderId: map['sender_id'] ?? '',
      content: map['content'] ?? '',
      messageType: map['message_type'] ?? 'text',
      isDeleted: map['is_deleted'] ?? false,
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

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    String? messageType,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
