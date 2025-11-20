class Workout {
  final String? id;
  final String? userId;
  final String name;
  final String weight;
  final String reps;
  final String sets;
  final String bodyPart;
  final DateTime date;
  final String? notes;

  Workout({
    this.id,
    this.userId,
    required this.name,
    required this.weight,
    required this.reps,
    required this.sets,
    required this.bodyPart,
    required this.date,
    this.notes,
  });

  // Convert a Workout into a Map for Supabase operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'exercise_name': name,
      'weight': weight,
      'reps': reps,
      'sets': sets,
      'body_part': bodyPart,
      'workout_date': _formatDate(date),
      if (notes != null) 'notes': notes,
    };
  }

  // Create a Workout from a Map (Supabase response)
  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      userId: map['user_id'],
      name: map['exercise_name'] ?? '',
      weight: map['weight'] ?? '',
      reps: map['reps'] ?? '0',
      sets: map['sets'] ?? '0',
      bodyPart: map['body_part'] ?? '',
      date: _parseDate(map['workout_date']),
      notes: map['notes'],
    );
  }

  // Helper to format date as string for Supabase
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Helper to parse date from string
  static DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return DateTime.now();
    }
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  // Create a copy with modified fields
  Workout copyWith({
    String? id,
    String? userId,
    String? name,
    String? weight,
    String? reps,
    String? sets,
    String? bodyPart,
    DateTime? date,
    String? notes,
  }) {
    return Workout(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      sets: sets ?? this.sets,
      bodyPart: bodyPart ?? this.bodyPart,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}
