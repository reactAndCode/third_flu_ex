import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/chat_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final ChatService _chatService = ChatService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<AuthState>? _authSubscription;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _user = _supabaseService.currentUser;
    _authSubscription = _supabaseService.authStateChanges.listen((authState) {
      _user = authState.session?.user;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabaseService.signUp(email, password);
      _user = response.user;

      // Create user profile automatically
      if (_user != null) {
        try {
          final nickname = email.split('@')[0]; // Use email prefix as default nickname
          await _chatService.upsertUserProfile(
            userId: _user!.id,
            nickname: nickname,
          );
        } catch (profileError) {
          debugPrint('Error creating user profile: $profileError');
          // Don't fail signup if profile creation fails
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabaseService.signIn(email, password);
      _user = response.user;

      // Create user profile if it doesn't exist
      if (_user != null) {
        try {
          final existingProfile = await _chatService.getUserProfile(_user!.id);
          if (existingProfile == null) {
            final nickname = email.split('@')[0];
            await _chatService.upsertUserProfile(
              userId: _user!.id,
              nickname: nickname,
            );
          }
        } catch (profileError) {
          debugPrint('Error checking/creating user profile: $profileError');
          // Don't fail signin if profile check fails
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabaseService.signOut();
      _user = null;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return '이메일 또는 비밀번호가 올바르지 않습니다.';
        case 'Email not confirmed':
          return '이메일 인증이 필요합니다.';
        case 'User already registered':
          return '이미 등록된 이메일입니다.';
        default:
          return error.message;
      }
    }
    return '오류가 발생했습니다. 다시 시도해주세요.';
  }
}
