import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/screens/dialogs/add_event.dart';
import 'package:events_manager/screens/dialogs/delete_confirmation.dart';
import 'package:events_manager/screens/settings.dart';
import 'package:events_manager/screens/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  String? _userName;

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await usersCollection.doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _userName = data['firstName'];
        });
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _userName != null ? 'Events for $_userName' : 'Home Page',
          style: TextStyle(fontSize: 24),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              } else if (value == 'logout') {
                _logout();
              }
            },
            icon: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, color: Colors.white),
            ),
            offset: const Offset(0, 50),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: Stack(children: [
        Positioned.fill(
          child: Image.asset(
            'login2.jpg',
            fit: BoxFit.cover,
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: eventsCollection.orderBy('startTime').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final events = snapshot.data!.docs.map((doc) {
              return Event(
                name: doc['name'] ?? 'Unnamed Event',
                startTime: (doc['startTime'] as Timestamp).toDate(),
                endTime: (doc['endTime'] as Timestamp).toDate(),
                location: doc['location'] ?? 'No location provided',
                description: doc['description'] ?? 'No description',
                icon: Icons.event,
                imagePath: doc['imagePath'] ?? 'assets/default.jpg',
              );
            }).toList();

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                return EventCard(
                  event: events[index],
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (context) => DeleteConfirmationDialog(
                        docId: doc.id,
                        eventsCollection: eventsCollection,
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ]),
      floatingActionButton: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.4),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) =>
                  AddEventDialog(eventsCollection: eventsCollection),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          tooltip: 'Add New Event',
          child: const Icon(Icons.add, size: 36),
        ),
      ),
    );
  }
}
