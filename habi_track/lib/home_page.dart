import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'habit.dart';
import 'add_habit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference habitsRef =
      FirebaseFirestore.instance.collection('habits');

  final List<String> predefinedHabits = [
    'Boire 2L d’eau',
    'Faire 30 min de sport',
    'Lire 20 pages',
    'Écrire un journal',
    'Se lever tôt',
    'Méditer 10 min',
    'Apprendre une nouvelle chose',
    'Prendre des vitamines',
    'Se coucher avant 23h',
    'Marcher 10 000 pas',
  ];

  Future<void> addPredefinedHabit(String name) async {
    final query = await habitsRef
        .where('name_lower', isEqualTo: name.toLowerCase().trim())
        .get();

    if (query.docs.isEmpty) {
      await habitsRef.add({
        'name': name,
        'name_lower': name.toLowerCase().trim(),
        'completed': false,
        'lastCompleted': DateTime.now().toIso8601String(),
        'streak': 0,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("L'habitude '$name' existe déjà !"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HabiTrack'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: habitsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final habits = snapshot.data!.docs
              .map((doc) => Habit.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();

          final completedToday = habits.where((h) => h.completed).length;
          final maxStreak = habits.isEmpty
              ? 0
              : habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Card(
                  color: Colors.blue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Total habitudes', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('${habits.length}'),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Complétées aujourd’hui', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('$completedToday'),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Streak max', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('$maxStreak'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(habit.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          subtitle: Text('Streak: ${habit.streak}'),
                          leading: Checkbox(
                            value: habit.completed,
                            onChanged: (value) async {
                              await habitsRef.doc(habit.id).update({
                                'completed': value,
                                'streak': value! ? habit.streak + 1 : habit.streak,
                                'lastCompleted': DateTime.now().toIso8601String(),
                              });
                            },
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () async {
                              await habitsRef.doc(habit.id).delete();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: predefinedHabits.map((habitName) {
                    return ElevatedButton(
                      onPressed: () => addPredefinedHabit(habitName),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(habitName),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHabitPage()),
          );
        },
      ),
    );
  }
}