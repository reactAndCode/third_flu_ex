import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../services/supabase_service.dart';

class WorkoutProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Workout> _workouts = [];
  DateTime _selectedDate = DateTime.now();
  bool _isListView = true;
  bool _isLoading = false;

  List<Workout> get workouts => _workouts;
  DateTime get selectedDate => _selectedDate;
  bool get isListView => _isListView;
  bool get isLoading => _isLoading;

  // Load workouts for the selected date
  Future<void> loadWorkouts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _workouts = await _supabaseService.getWorkoutsByDate(_selectedDate);
    } catch (e) {
      debugPrint('Error loading workouts: $e');
      _workouts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mock data methods for demonstration without Supabase
  void addMockWorkout(Map<String, dynamic> workoutData) {
    final newWorkout = Workout(
      id: workoutData['id'],
      userId: 'mock_user',
      name: workoutData['name'],
      weight: workoutData['weight'],
      reps: workoutData['reps'],
      sets: workoutData['sets'],
      bodyPart: workoutData['bodyPart'],
      date: workoutData['date'],
    );
    _workouts.add(newWorkout);
    notifyListeners();
  }

  void deleteMockWorkout(String id) {
    _workouts.removeWhere((workout) => workout.id == id);
    notifyListeners();
  }

  // Add a new workout
  Future<void> addWorkout(Workout workout) async {
    try {
      await _supabaseService.insertWorkout(workout);
      await loadWorkouts();
    } catch (e) {
      debugPrint('Error adding workout: $e');
      rethrow;
    }
  }

  // Update an existing workout
  Future<void> updateWorkout(Workout workout) async {
    try {
      await _supabaseService.updateWorkout(workout);
      await loadWorkouts();
    } catch (e) {
      debugPrint('Error updating workout: $e');
      rethrow;
    }
  }

  // Delete a workout
  Future<void> deleteWorkout(String id) async {
    try {
      await _supabaseService.deleteWorkout(id);
      await loadWorkouts();
    } catch (e) {
      debugPrint('Error deleting workout: $e');
      rethrow;
    }
  }

  // Change selected date
  void changeDate(DateTime newDate) {
    _selectedDate = newDate;
    loadWorkouts();
  }

  // Go to previous day
  void previousDay() {
    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    loadWorkouts();
  }

  // Go to next day
  void nextDay() {
    _selectedDate = _selectedDate.add(const Duration(days: 1));
    loadWorkouts();
  }

  // Toggle view mode
  void toggleView() {
    _isListView = !_isListView;
    notifyListeners();
  }

  // Get workout count for selected date
  Future<int> getWorkoutCount() async {
    try {
      return await _supabaseService.getWorkoutCountByDate(_selectedDate);
    } catch (e) {
      debugPrint('Error getting workout count: $e');
      return 0;
    }
  }

  // Get monthly statistics
  Future<Map<String, dynamic>> getMonthlyStats() async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final monthlyWorkouts = await _supabaseService.getWorkoutsByDateRange(
        firstDayOfMonth,
        lastDayOfMonth,
      );

      // 운동 횟수
      final workoutCount = monthlyWorkouts.length;

      // 총 운동 시간 (8, 9, 10분 중 랜덤)
      int totalMinutes = 0;
      for (var workout in monthlyWorkouts) {
        final randomMinutes = [8, 9, 10][workout.hashCode % 3];
        totalMinutes += randomMinutes;
      }

      // 총 칼로리 (95, 100, 105 칼로리 중 랜덤)
      int totalCalories = 0;
      for (var workout in monthlyWorkouts) {
        final randomCalories = [95, 100, 105][workout.hashCode % 3];
        totalCalories += randomCalories;
      }

      return {
        'workoutCount': workoutCount,
        'totalMinutes': totalMinutes,
        'totalCalories': totalCalories,
      };
    } catch (e) {
      debugPrint('Error getting monthly stats: $e');
      return {
        'workoutCount': 0,
        'totalMinutes': 0,
        'totalCalories': 0,
      };
    }
  }

  // Get all workouts for the current month
  Future<List<Workout>> getMonthlyWorkouts() async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      return await _supabaseService.getWorkoutsByDateRange(
        firstDayOfMonth,
        lastDayOfMonth,
      );
    } catch (e) {
      debugPrint('Error getting monthly workouts: $e');
      return [];
    }
  }
}
