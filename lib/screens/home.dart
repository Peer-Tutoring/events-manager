import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/screens/bookmarked_events.dart';
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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  List<String> _favoriteEvents = [];

  Future<void> _fetchUserName() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      final userDoc = await usersCollection.doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _userName = data['firstName'];
          _favoriteEvents = List<String>.from(data['favorites'] ?? []);
        });
      }
    }
  }

  Future<void> _toggleFavorite(String eventId) async {
    if (_favoriteEvents.contains(eventId)) {
      _favoriteEvents.remove(eventId);
    } else {
      _favoriteEvents.add(eventId);
    }
    await usersCollection.doc(_currentUser!.uid).update({
      'favorites': _favoriteEvents,
    });
    setState(() {});
  }

  Future<void> _logout() async {
    await _auth.signOut();
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
          style: const TextStyle(fontSize: 24),
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
              } else if (value == 'bookmarks') {
                // Navigate to bookmarks
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookmarkedEventsScreen(),
                  ),
                );
              }
            },
            icon: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, color: Colors.white),
            ),
            offset: const Offset(0, 50),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(
                  value: 'bookmarks', child: Text('Bookmarks')), // New item
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: eventsCollection.orderBy('startTime').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!.docs.map((doc) {
            return Event(
              id: doc.id,
              name: doc['name'] ?? 'Unnamed Event',
              startTime: (doc['startTime'] as Timestamp).toDate(),
              endTime: (doc['endTime'] as Timestamp).toDate(),
              location: doc['location'] ?? 'No location provided',
              description: doc['description'] ?? 'No description',
              icon: Icons.event,
              imagePath: doc['imagePath'] ?? 'assets/default.jpg',
            );
          }).where((event) {
            final eventName = event.name.toLowerCase();
            final eventLocation = event.location.toLowerCase();
            return eventName.contains(_searchQuery) ||
                eventLocation.contains(_searchQuery);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return EventCard(
                event: event,
                isFavorite: _favoriteEvents.contains(event.id),
                onToggleFavorite: () => _toggleFavorite(event.id),
                onDelete: () {
                  showDialog(
                    context: context,
                    builder: (context) => DeleteConfirmationDialog(
                      docId: event.id,
                      eventsCollection: eventsCollection,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
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
