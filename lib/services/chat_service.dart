import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/user_profile.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  // ==================== Conversation Methods ====================

  // Create a new conversation
  Future<Conversation> createConversation({
    String? name,
    String type = 'direct',
    required List<String> participantIds,
  }) async {
    // Create conversation
    final conversationResponse = await _client
        .from('conversations')
        .insert({
          'name': name,
          'type': type,
        })
        .select()
        .single();

    final conversation = Conversation.fromMap(conversationResponse);

    // Add participants
    final participants = participantIds.map((userId) => {
          'conversation_id': conversation.id,
          'user_id': userId,
        }).toList();

    await _client.from('conversation_participants').insert(participants);

    return conversation;
  }

  // Get all conversations for current user
  Future<List<Conversation>> getConversations() async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('conversations')
        .select('''
          *,
          conversation_participants!inner(user_id)
        ''')
        .eq('conversation_participants.user_id', userId)
        .order('updated_at', ascending: false);

    final conversations = <Conversation>[];

    for (var item in response) {
      final conversation = Conversation.fromMap(item);

      // Get last message for this conversation
      final lastMessageResponse = await _client
          .from('messages')
          .select()
          .eq('conversation_id', conversation.id!)
          .order('created_at', ascending: false)
          .limit(1);

      if (lastMessageResponse.isNotEmpty) {
        final lastMessage = Message.fromMap(lastMessageResponse.first);
        conversations.add(conversation.copyWith(
          lastMessageContent: lastMessage.content,
          lastMessageTime: lastMessage.createdAt,
        ));
      } else {
        conversations.add(conversation);
      }
    }

    return conversations;
  }

  // Get conversation by ID
  Future<Conversation?> getConversation(String conversationId) async {
    final response = await _client
        .from('conversations')
        .select()
        .eq('id', conversationId)
        .single();

    return Conversation.fromMap(response);
  }

  // Get conversation participants
  Future<List<String>> getConversationParticipants(String conversationId) async {
    final response = await _client
        .from('conversation_participants')
        .select('user_id')
        .eq('conversation_id', conversationId);

    return response.map((item) => item['user_id'] as String).toList();
  }

  // Find or create direct conversation with another user
  Future<Conversation> findOrCreateDirectConversation(String otherUserId) async {
    final currentUserId = currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Check if conversation already exists
    final response = await _client
        .from('conversation_participants')
        .select('conversation_id')
        .eq('user_id', currentUserId);

    for (var item in response) {
      final conversationId = item['conversation_id'];

      // Check if other user is also in this conversation
      final otherUserResponse = await _client
          .from('conversation_participants')
          .select()
          .eq('conversation_id', conversationId)
          .eq('user_id', otherUserId);

      if (otherUserResponse.isNotEmpty) {
        // Check if this is a direct conversation (only 2 participants)
        final allParticipants = await _client
            .from('conversation_participants')
            .select()
            .eq('conversation_id', conversationId);

        if (allParticipants.length == 2) {
          return await getConversation(conversationId) ??
              await createConversation(
                type: 'direct',
                participantIds: [currentUserId, otherUserId],
              );
        }
      }
    }

    // Create new conversation
    return await createConversation(
      type: 'direct',
      participantIds: [currentUserId, otherUserId],
    );
  }

  // ==================== Message Methods ====================

  // Send a message
  Future<Message> sendMessage({
    required String conversationId,
    required String content,
    String messageType = 'text',
  }) async {
    final userId = currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _client
        .from('messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': userId,
          'content': content,
          'message_type': messageType,
        })
        .select()
        .single();

    // Update conversation updated_at
    await _client
        .from('conversations')
        .update({'updated_at': DateTime.now().toIso8601String()})
        .eq('id', conversationId);

    return Message.fromMap(response);
  }

  // Get messages for a conversation
  Future<List<Message>> getMessages(String conversationId, {int limit = 50}) async {
    final response = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .eq('is_deleted', false)
        .order('created_at', ascending: true)
        .limit(limit);

    return response.map((item) => Message.fromMap(item)).toList();
  }

  // Subscribe to new messages in a conversation
  Stream<Message> subscribeToMessages(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .map((data) => data.map((item) => Message.fromMap(item)))
        .expand((messages) => messages);
  }

  // Delete a message (soft delete)
  Future<void> deleteMessage(String messageId) async {
    await _client
        .from('messages')
        .update({'is_deleted': true})
        .eq('id', messageId);
  }

  // Update last read timestamp for user in conversation
  Future<void> updateLastRead(String conversationId) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    await _client
        .from('conversation_participants')
        .update({'last_read_at': DateTime.now().toIso8601String()})
        .eq('conversation_id', conversationId)
        .eq('user_id', userId);
  }

  // Get unread message count for a conversation
  Future<int> getUnreadCount(String conversationId) async {
    final userId = currentUser?.id;
    if (userId == null) return 0;

    // Get user's last_read_at for this conversation
    final participantResponse = await _client
        .from('conversation_participants')
        .select('last_read_at')
        .eq('conversation_id', conversationId)
        .eq('user_id', userId)
        .single();

    final lastReadAt = participantResponse['last_read_at'];
    if (lastReadAt == null) return 0;

    // Count messages after last_read_at
    final response = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .neq('sender_id', userId)
        .gt('created_at', lastReadAt)
        .count();

    return response.count;
  }

  // ==================== User Profile Methods ====================

  // Create or update user profile
  Future<UserProfile> upsertUserProfile({
    required String userId,
    String? nickname,
    String? avatarUrl,
    String? statusMessage,
  }) async {
    final response = await _client
        .from('user_profiles')
        .upsert({
          'user_id': userId,
          if (nickname != null) 'nickname': nickname,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          if (statusMessage != null) 'status_message': statusMessage,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return UserProfile.fromMap(response);
  }

  // Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .single();

      return UserProfile.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  // Get multiple user profiles
  Future<List<UserProfile>> getUserProfiles(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    final response = await _client
        .from('user_profiles')
        .select()
        .inFilter('user_id', userIds);

    return response.map((item) => UserProfile.fromMap(item)).toList();
  }

  // Search users by nickname
  Future<List<UserProfile>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final response = await _client
        .from('user_profiles')
        .select()
        .ilike('nickname', '%$query%')
        .limit(20);

    return response.map((item) => UserProfile.fromMap(item)).toList();
  }
}
