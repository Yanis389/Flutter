class Habit {
  final String id;
  final String name;
  final bool completed;
  final String lastCompleted; // ISO8601 string
  final int streak;

  Habit({
    required this.id,
    required this.name,
    required this.completed,
    required this.lastCompleted,
    required this.streak,
  });

  factory Habit.fromMap(String id, Map<String, dynamic> map) {
    return Habit(
      id: id,
      name: map['name'] ?? '',
      completed: map['completed'] ?? false,
      lastCompleted: map['lastCompleted'] ?? DateTime.now().toIso8601String(),
      streak: map['streak'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'name_lower': name.toLowerCase().trim(),
        'completed': completed,
        'lastCompleted': lastCompleted,
        'streak': streak,
      };
}