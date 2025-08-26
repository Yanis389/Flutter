import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const Dojo4App());
}

class Dojo4App extends StatelessWidget {
  const Dojo4App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dojo 4 - Contacts API',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ContactsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Modèle de Contact
class Contact {
  final int id;
  final String name;
  final String email;

  Contact({required this.id, required this.name, required this.email});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

// Page principale
class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  late Future<List<Contact>> _contactsFuture;
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _contactsFuture = fetchContacts();
  }

  // Récupérer les contacts depuis l'API
  Future<List<Contact>> fetchContacts() async {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/users'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _allContacts = data.map((json) => Contact.fromJson(json)).toList();
      _filteredContacts = _allContacts;
      return _allContacts;
    } else {
      throw Exception('Impossible de charger les contacts');
    }
  }

  // Filtrer les contacts
  void _filterContacts(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredContacts = _allContacts
          .where((contact) => contact.name.toLowerCase().contains(lowerQuery))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts API'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Contact>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun contact trouvé.'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Rechercher un contact',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _filterContacts,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = _filteredContacts[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(contact.name[0]),
                        ),
                        title: Text(contact.name),
                        subtitle: Text(contact.email),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}