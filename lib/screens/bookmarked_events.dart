import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/screens/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookmarkedEventsScreen extends StatefulWidget {
  const BookmarkedEventsScreen({super.key});

  @override
  State<BookmarkedEventsScreen> createState() => _BookmarkedEventsScreenState();
}

class _BookmarkedEventsScreenState extends State<BookmarkedEventsScreen> {
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  User? _currentUser;
  List<String> _favoriteEventIds = [];

  @override
  void initState() {
    super.initState();
    _fetchFavoriteEventIds();
  }

  Future<void> _fetchFavoriteEventIds() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      final userDoc = await usersCollection.doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _favoriteEventIds = List<String>.from(data['favorites'] ?? []);
        });
      }
    }
  }

  Future<void> _toggleFavorite(String eventId) async {
    if (_favoriteEventIds.contains(eventId)) {
      _favoriteEventIds.remove(eventId);
    } else {
      _favoriteEventIds.add(eventId);
    }
    await usersCollection.doc(_currentUser!.uid).update({
      'favorites': _favoriteEventIds,
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookmarked Events"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: eventsCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteEvents = snapshot.data!.docs
              .where((doc) => _favoriteEventIds.contains(doc.id))
              .map((doc) {
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
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: favoriteEvents.length,
            itemBuilder: (context, index) {
              final event = favoriteEvents[index];
              return EventCard(
                event: event,
                isFavorite: true,
                onToggleFavorite: () => _toggleFavorite(event.id),
                eventsCollection: eventsCollection,
              );
            },
          );
        },
      ),
    );
  }
}
