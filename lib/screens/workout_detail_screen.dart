import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy년 MM월 dd일');
    final formattedDate = dateFormat.format(widget.workout.date);
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final weekday = weekdays[widget.workout.date.weekday - 1];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '운동 상세',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditWorkoutDialog(context),
            tooltip: '수정',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fitness_center, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.workout.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$formattedDate $weekday',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Workout Info Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow('운동 부위', widget.workout.bodyPart),
                  const Divider(height: 24),
                  _buildInfoRow('중량', widget.workout.weight),
                  const Divider(height: 24),
                  _buildInfoRow('횟수', widget.workout.reps),
                  const Divider(height: 24),
                  _buildInfoRow('세트', widget.workout.sets),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Notes Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.description, size: 20, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        '운동방법상세',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.workout.notes?.isNotEmpty == true
                        ? widget.workout.notes!
                        : '등록된 운동 방법이 없습니다.',
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.workout.notes?.isNotEmpty == true
                          ? Colors.black87
                          : Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _showEditWorkoutDialog(BuildContext context) async {
    final nameController = TextEditingController(text: widget.workout.name);
    final weightController = TextEditingController(text: widget.workout.weight);
    final repsController = TextEditingController(text: widget.workout.reps);
    final setsController = TextEditingController(text: widget.workout.sets);
    final bodyPartController = TextEditingController(text: widget.workout.bodyPart);
    final notesController = TextEditingController(text: widget.workout.notes ?? '');

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운동 수정'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '운동명',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: '중량',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: repsController,
                decoration: const InputDecoration(
                  labelText: '횟수',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: setsController,
                decoration: const InputDecoration(
                  labelText: '세트',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyPartController,
                decoration: const InputDecoration(
                  labelText: '운동 부위',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: '운동방법상세',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              final updatedWorkout = Workout(
                id: widget.workout.id,
                userId: widget.workout.userId,
                name: nameController.text,
                weight: weightController.text,
                reps: repsController.text,
                sets: setsController.text,
                bodyPart: bodyPartController.text,
                notes: notesController.text,
                date: widget.workout.date,
              );

              if (context.mounted) {
                await context.read<WorkoutProvider>().updateWorkout(updatedWorkout);

                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  if (context.mounted) {
                    Navigator.pop(context); // Go back to home screen
                  }
                }
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
