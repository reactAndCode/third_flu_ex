class BodyMeasurement {
  final String? id;
  final String? userId;
  final DateTime measurementDate;
  final double weight;
  final double? height;
  final double? bmi;
  final String? notes;
  final DateTime? createdAt;

  BodyMeasurement({
    this.id,
    this.userId,
    required this.measurementDate,
    required this.weight,
    this.height,
    this.bmi,
    this.notes,
    this.createdAt,
  });

  // Convert to Map for Supabase
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'measurement_date': _formatDate(measurementDate),
      'weight': weight,
      if (height != null) 'height': height,
      if (bmi != null) 'bmi': bmi,
      if (notes != null) 'notes': notes,
    };
  }

  // Create from Map (Supabase response)
  factory BodyMeasurement.fromMap(Map<String, dynamic> map) {
    return BodyMeasurement(
      id: map['id']?.toString(),
      userId: map['user_id'],
      measurementDate: _parseDate(map['measurement_date']),
      weight: (map['weight'] as num).toDouble(),
      height: map['height'] != null ? (map['height'] as num).toDouble() : null,
      bmi: map['bmi'] != null ? (map['bmi'] as num).toDouble() : null,
      notes: map['notes'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  // Helper to format date
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Helper to parse date
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

  // Calculate BMI
  static double? calculateBMI(double weightKg, double? heightCm) {
    if (heightCm == null || heightCm == 0) return null;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  // Copy with
  BodyMeasurement copyWith({
    String? id,
    String? userId,
    DateTime? measurementDate,
    double? weight,
    double? height,
    double? bmi,
    String? notes,
    DateTime? createdAt,
  }) {
    return BodyMeasurement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      measurementDate: measurementDate ?? this.measurementDate,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bmi: bmi ?? this.bmi,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
