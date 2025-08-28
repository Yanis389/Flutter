import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'habit.dart';
import 'add_habit_page.dart';
import 'notification_service.dart';

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

  bool _dailyReminderEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadReminderPref();
  }

  Future<void> _loadReminderPref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _dailyReminderEnabled = prefs.getBool('daily_reminder') ?? false);
  }

  Future<void> _toggleReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _dailyReminderEnabled = value);
    await prefs.setBool('daily_reminder', value);
    if (value) {
      await NotificationService.instance.enableDailyReminder();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rappel quotidien activé (toutes les 24h).')),
      );
    } else {
      await NotificationService.instance.disableDailyReminder();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rappel quotidien désactivé.')),
      );
    }
  }

  Future<void> addPredefinedHabit(String name) async {
    try {
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("L'habitude '$name' existe déjà !"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de l'ajout"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStatsCard(List<Habit> habits) {
    final completedToday = habits.where((h) => h.completed).length;
    final notCompleted = habits.length - completedToday;
    final maxStreak = habits.isEmpty
        ? 0
        : habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.insights),
                const SizedBox(width: 8),
                Text('Aperçu du jour',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                Switch.adaptive(
                  value: _dailyReminderEnabled,
                  onChanged: _toggleReminder,
                ),
                const SizedBox(width: 4),
                const Text('Rappel'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _miniStat('Total', habits.length.toString(), Icons.list_alt),
                _miniStat('Complétées', completedToday.toString(), Icons.check_circle),
                _miniStat('Streak max', maxStreak.toString(), Icons.local_fire_department),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 28,
                  sections: [
                    PieChartSectionData(
                      value: completedToday.toDouble(),
                      title: completedToday == 0 ? '' : '$completedToday',
                      radius: 48,
                      color: Colors.green,
                    ),
                    PieChartSectionData(
                      value: notCompleted.toDouble(),
                      title: notCompleted == 0 ? '' : '$notCompleted',
                      radius: 42,
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildHabitList(List<Habit> habits) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Checkbox(
              value: habit.completed,
              onChanged: (value) async {
                final newCompleted = value ?? false;
                int newStreak = habit.streak;
                if (newCompleted && !habit.completed) newStreak += 1;

                await habitsRef.doc(habit.id).update({
                  'completed': newCompleted,
                  'streak': newStreak,
                  'lastCompleted': DateTime.now().toIso8601String(),
                });

                if (newCompleted) {
                  await NotificationService.instance.showInstant(
                    'Bravo !',
                    'Tu as complété: ${habit.name}',
                  );
                }
              },
            ),
            title: Text(habit.name),
            subtitle: Text('Streak: ${habit.streak}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                await habitsRef.doc(habit.id).delete();
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HabiTrack'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F93F9), Color(0xFF6EC6FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: habitsRef.orderBy('name_lower').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final habits = snapshot.data!.docs
              .map((doc) => Habit.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildStatsCard(habits),
                  const SizedBox(height: 16),
                  _buildHabitList(habits),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: predefinedHabits.map((habitName) {
                      return ActionChip(
                        label: Text(habitName),
                        avatar: const Icon(Icons.add),
                        onPressed: () => addPredefinedHabit(habitName),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHabitPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle habitude'),
      ),
    );
  }
}