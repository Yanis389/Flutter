class Habit {
  String id;
  String name;
  bool completed;
  DateTime lastCompleted;
  int streak;

  Habit({
    required this.id,
    required this.name,
    this.completed = false,
    DateTime? lastCompleted,
    this.streak = 0,
  }) : lastCompleted = lastCompleted ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'completed': completed,
      'lastCompleted': lastCompleted.toIso8601String(),
      'streak': streak,
    };
  }

  factory Habit.fromMap(String id, Map<String, dynamic> map) {
    return Habit(
      id: id,
      name: map['name'] ?? '',
      completed: map['completed'] ?? false,
      lastCompleted: DateTime.tryParse(map['lastCompleted'] ?? '') ?? DateTime.now(),
      streak: map['streak'] ?? 0,
    );
  }
}