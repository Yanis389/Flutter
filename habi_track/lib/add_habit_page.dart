import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final TextEditingController _controller = TextEditingController();
  final CollectionReference habitsCollection =
      FirebaseFirestore.instance.collection('habits');

  void addHabit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Le nom de l'habitude ne peut pas être vide"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      // Vérifier si l'habitude existe déjà
      final query = await habitsCollection
          .where('name', isEqualTo: name)
          .get();

      if (query.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("L'habitude '$name' existe déjà !"),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // Ajouter l'habitude
      await habitsCollection.add({
        'name': name,
        'completed': false,
        'lastCompleted': DateTime.now().toIso8601String(),
        'streak': 0,
      });

      // Message succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Habitude '$name' ajoutée avec succès !"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Effacer le champ
      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de l'ajout"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une habitude'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Nom de l’habitude',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.checklist),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: addHabit,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}