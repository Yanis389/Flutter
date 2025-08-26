import 'package:flutter/material.dart';

void main() {
  runApp(const Dojo3App());
}

class Dojo3App extends StatelessWidget {
  const Dojo3App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dojo 3 - Todo List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _tasks = [];

  void _addTask(String task) {
    if (task.trim().isEmpty) return;
    setState(() {
      _tasks.add(task.trim());
    });
    _controller.clear();
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List Interactive'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Ajouter une tâche',
                border: OutlineInputBorder(),
              ),
              onSubmitted: _addTask,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucune tâche pour le moment.',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(_tasks[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeTask(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(_controller.text),
        child: const Icon(Icons.add),
      ),
    );
  }
}
