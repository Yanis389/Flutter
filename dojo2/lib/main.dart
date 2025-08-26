import 'package:flutter/material.dart';

void main() {
  runApp(const Dojo2App());
}

class Dojo2App extends StatelessWidget {
  const Dojo2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dojo 2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ColorControllerPage(),
    );
  }
}

class ColorControllerPage extends StatefulWidget {
  const ColorControllerPage({super.key});

  @override
  State<ColorControllerPage> createState() => _ColorControllerPageState();
}

class _ColorControllerPageState extends State<ColorControllerPage> {
  final TextEditingController _controller = TextEditingController();
  Color _currentColor = Colors.grey;
  String _currentColorName = 'Gris';

  // Map des couleurs FR/EN
  final Map<String, Color> colorsMap = {
    'rouge': Colors.red,
    'red': Colors.red,
    'bleu': Colors.blue,
    'blue': Colors.blue,
    'vert': Colors.green,
    'green': Colors.green,
    'jaune': Colors.yellow,
    'yellow': Colors.yellow,
    'orange': Colors.orange,
    'violet': Colors.purple,
    'purple': Colors.purple,
    'noir': Colors.black,
    'black': Colors.black,
    'blanc': Colors.white,
    'white': Colors.white,
    'gris': Colors.grey,
    'grey': Colors.grey,
  };

  void _updateColor(String input) {
    String key = input.toLowerCase();
    setState(() {
      if (colorsMap.containsKey(key)) {
        _currentColor = colorsMap[key]!;
        _currentColorName = input;
      } else {
        _currentColor = Colors.grey;
        _currentColorName = 'Inconnue';
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Libère le TextEditingController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dojo 2 - Contrôleur de Couleur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Entrez une couleur (FR ou EN)',
                border: OutlineInputBorder(),
              ),
              onChanged: _updateColor,
            ),
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 200,
              color: _currentColor,
              alignment: Alignment.center,
              child: Text(
                'La couleur est $_currentColorName',
                style: TextStyle(
                  fontSize: 18,
                  color: _currentColor == Colors.black
                      ? Colors.white
                      : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}