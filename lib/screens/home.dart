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

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  List<String> _favoriteEvents = [];
  int _currentIndex = 0;

  Future<void> _fetchUserName() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      final userDoc = await usersCollection.doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
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

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0
          ? buildHomeScreen()
          : _currentIndex == 1
              ? const BookmarkedEventsScreen()
              : const SettingsScreen(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 40),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite, size: 40),
              label: 'Bookmarks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, size: 40),
              label: 'Settings',
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(right: 16),
        height: 70,
        width: 70,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget buildHomeScreen() {
    return Column(
      children: [
        Padding(
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
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
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
        ),
      ],
    );
  }
}
