import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const DojoApp());
}

class DojoApp extends StatelessWidget {
  const DojoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dojo 1',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DojoPage(),
    );
  }
}

// StatefulWidget car le bouton doit changer de couleur
class DojoPage extends StatefulWidget {
  const DojoPage({super.key});

  @override
  State<DojoPage> createState() => _DojoPageState();
}

class _DojoPageState extends State<DojoPage> {
  // Liste de couleurs et leurs noms en anglais
  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
  ];

  final List<String> colorNames = [
    'Red',
    'Green',
    'Blue',
    'Orange',
    'Purple',
    'Yellow',
  ];

  Color currentColor = Colors.blue;
  String currentName = 'Blue';
  final Random random = Random();

  void changeColor() {
    int index = random.nextInt(colors.length);
    setState(() {
      currentColor = colors[index];
      currentName = colorNames[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dojo 1 - Bouton Interactif'),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: currentColor,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            textStyle: const TextStyle(fontSize: 24),
          ),
          onPressed: changeColor,
          child: Text(currentName),
        ),
      ),
    );
  }
}
