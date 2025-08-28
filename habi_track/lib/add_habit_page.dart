import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final TextEditingController _controller = TextEditingController();
  final CollectionReference habitsRef =
      FirebaseFirestore.instance.collection('habits');

  Future<void> addHabit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    final query = await habitsRef.where('name_lower', isEqualTo: name.toLowerCase()).get();
    if (query.docs.isNotEmpty) return;

    await habitsRef.add({
      'name': name,
      'name_lower': name.toLowerCase(),
      'completed': false,
      'lastCompleted': DateTime.now().toIso8601String(),
      'streak': 0,
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une habitude')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Nom de l’habitude'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: addHabit, child: const Text('Ajouter')),
          ],
        ),
      ),
    );
  }
}