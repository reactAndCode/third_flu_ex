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
}
