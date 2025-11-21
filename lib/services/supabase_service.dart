import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final _client = Supabase.instance.client;

  // Auth methods
  Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Create
  Future<Workout> insertWorkout(Workout workout) async {
    final response = await _client
        .from('workouts')
        .insert(workout.toMap())
        .select()
        .single();

    return Workout.fromMap(response);
  }

  // Read all workouts for a specific date
  Future<List<Workout>> getWorkoutsByDate(DateTime date) async {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final response = await _client
        .from('workouts')
        .select()
        .eq('workout_date', dateStr)
        .order('id', ascending: true);

    return response
        .map((item) => Workout.fromMap(item))
        .toList();
  }

  // Read all workouts in a date range
  Future<List<Workout>> getWorkoutsByDateRange(DateTime startDate, DateTime endDate) async {
    final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

    final response = await _client
        .from('workouts')
        .select()
        .gte('workout_date', startDateStr)
        .lte('workout_date', endDateStr)
        .order('workout_date', ascending: false);

    return response
        .map((item) => Workout.fromMap(item))
        .toList();
  }

  // Read all workouts
  Future<List<Workout>> getAllWorkouts() async {
    final response = await _client.from('workouts').select().order('workout_date', ascending: false);

    return response
        .map((item) => Workout.fromMap(item))
        .toList();
  }

  // Update
  Future<Workout> updateWorkout(Workout workout) async {
    final response = await _client
        .from('workouts')
        .update(workout.toMap())
        .eq('id', workout.id!)
        .select()
        .single();

    return Workout.fromMap(response);
  }

  // Delete
  Future<void> deleteWorkout(String id) async {
    await _client.from('workouts').delete().eq('id', id);
  }

  // Get workout count for a specific date
  Future<int> getWorkoutCountByDate(DateTime date) async {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final response = await _client
        .from('workouts')
        .select()
        .eq('workout_date', dateStr)
        .count();

    return response.count;
  }

  // Upload image to Supabase Storage
  Future<String?> uploadWorkoutImage(String filePath, Uint8List fileBytes, String workoutId) async {
    try {
      final now = DateTime.now();
      final dateTimeStr = '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      
      String sequence = 'a';
      if (filePath == 'photo1') {
        sequence = 'a';
      } else if (filePath == 'photo2') {
        sequence = 'b';
      } else if (filePath == 'photo3') {
        sequence = 'c';
      }

      final fileName = '${dateTimeStr}_$sequence.png';
      final path = 'myUp33/$fileName';

      await _client.storage
          .from('my-real-estate')
          .uploadBinary(path, fileBytes);

      final publicUrl = _client.storage
          .from('my-real-estate')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
