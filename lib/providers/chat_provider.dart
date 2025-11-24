import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/user_profile.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<Conversation> _conversations = [];
  List<Message> _messages = [];
  Conversation? _currentConversation;
  bool _isLoading = false;
  StreamSubscription<Message>? _messageSubscription;

  List<Conversation> get conversations => _conversations;
  List<Message> get messages => _messages;
  Conversation? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;

  // ==================== Conversation Methods ====================

  // Load all conversations
  Future<void> loadConversations() async {
    _isLoading = true;
    notifyListeners();

    try {
      _conversations = await _chatService.getConversations();
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      _conversations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new conversation
  Future<Conversation?> createConversation({
    String? name,
    String type = 'direct',
    required List<String> participantIds,
  }) async {
    try {
      final conversation = await _chatService.createConversation(
        name: name,
        type: type,
        participantIds: participantIds,
      );
      await loadConversations();
      return conversation;
    } catch (e) {
      debugPrint('Error creating conversation: $e');
      return null;
    }
  }

  // Find or create direct conversation with another user
  Future<Conversation?> startDirectChat(String otherUserId) async {
    try {
      final conversation = await _chatService.findOrCreateDirectConversation(otherUserId);
      await loadConversations();
      return conversation;
    } catch (e) {
      debugPrint('Error starting direct chat: $e');
      return null;
    }
  }

  // Set current conversation and load messages
  Future<void> setCurrentConversation(String conversationId) async {
    try {
      _currentConversation = await _chatService.getConversation(conversationId);
      await loadMessages(conversationId);

      // Subscribe to new messages
      subscribeToMessages(conversationId);

      // Mark as read
      await _chatService.updateLastRead(conversationId);
    } catch (e) {
      debugPrint('Error setting current conversation: $e');
    }
  }

  // Clear current conversation
  void clearCurrentConversation() {
    _currentConversation = null;
    _messages = [];
    _messageSubscription?.cancel();
    _messageSubscription = null;
    notifyListeners();
  }

  // Get conversation participants
  Future<List<String>> getConversationParticipants(String conversationId) async {
    try {
      return await _chatService.getConversationParticipants(conversationId);
    } catch (e) {
      debugPrint('Error getting conversation participants: $e');
      return [];
    }
  }

  // ==================== Message Methods ====================

  // Load messages for a conversation
  Future<void> loadMessages(String conversationId, {int limit = 50}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await _chatService.getMessages(conversationId, limit: limit);
    } catch (e) {
      debugPrint('Error loading messages: $e');
      _messages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send a message
  Future<void> sendMessage({
    required String conversationId,
    required String content,
    String messageType = 'text',
  }) async {
    try {
      final message = await _chatService.sendMessage(
        conversationId: conversationId,
        content: content,
        messageType: messageType,
      );

      // Add message to local list immediately
      _messages.add(message);
      notifyListeners();

      // Reload conversations to update last message
      await loadConversations();
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  // Subscribe to new messages in current conversation
  void subscribeToMessages(String conversationId) {
    _messageSubscription?.cancel();

    _messageSubscription = _chatService.subscribeToMessages(conversationId).listen(
      (message) {
        // Check if message already exists
        final existingIndex = _messages.indexWhere((m) => m.id == message.id);

        if (existingIndex == -1) {
          // New message
          _messages.add(message);
          notifyListeners();

          // Update last read if user is viewing this conversation
          if (_currentConversation?.id == conversationId) {
            _chatService.updateLastRead(conversationId);
          }
        }
      },
      onError: (error) {
        debugPrint('Error in message subscription: $error');
      },
    );
  }

  // Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _chatService.deleteMessage(messageId);
      _messages.removeWhere((m) => m.id == messageId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting message: $e');
      rethrow;
    }
  }

  // Get unread count for a conversation
  Future<int> getUnreadCount(String conversationId) async {
    try {
      return await _chatService.getUnreadCount(conversationId);
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  // ==================== User Profile Methods ====================

  // Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      return await _chatService.getUserProfile(userId);
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // Get multiple user profiles
  Future<List<UserProfile>> getUserProfiles(List<String> userIds) async {
    try {
      return await _chatService.getUserProfiles(userIds);
    } catch (e) {
      debugPrint('Error getting user profiles: $e');
      return [];
    }
  }

  // Create or update user profile
  Future<UserProfile?> upsertUserProfile({
    required String userId,
    String? nickname,
    String? avatarUrl,
    String? statusMessage,
  }) async {
    try {
      return await _chatService.upsertUserProfile(
        userId: userId,
        nickname: nickname,
        avatarUrl: avatarUrl,
        statusMessage: statusMessage,
      );
    } catch (e) {
      debugPrint('Error upserting user profile: $e');
      return null;
    }
  }

  // Search users by nickname
  Future<List<UserProfile>> searchUsers(String query) async {
    try {
      return await _chatService.searchUsers(query);
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}
