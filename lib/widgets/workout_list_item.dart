import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../screens/workout_detail_screen.dart';

class WorkoutListItem extends StatelessWidget {
  final Workout workout;
  final VoidCallback onDelete;

  const WorkoutListItem({
    super.key,
    required this.workout,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Icon with first letter
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                workout.name.isNotEmpty ? workout.name[0] : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Exercise name
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutDetailScreen(workout: workout),
                  ),
                );
              },
              child: Text(
                workout.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),

          // Weight
          Expanded(
            child: Text(
              workout.weight,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Reps
          Expanded(
            child: Text(
              workout.reps,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Sets
          Expanded(
            child: Text(
              workout.sets,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Body part
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                workout.bodyPart,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
