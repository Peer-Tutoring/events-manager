import 'package:events_manager/models/event.dart';
import 'package:events_manager/screens/event_detail.dart';
import 'package:events_manager/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login'); // Optional navigation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(),
                  ),
                );
              } else if (value == 'logout') {
                _logout();
              }
            },
            icon: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            offset: const Offset(0, 50), // Adjusted offset
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: eventsCollection.orderBy('startTime').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final doc = events[index];
              final event = Event(
                name: doc['name'] ?? 'Unnamed Event',
                startTime: (doc['startTime'] as Timestamp).toDate(),
                endTime: (doc['endTime'] as Timestamp).toDate(),
                location: doc['location'] ?? 'No location provided',
                description: doc['description'] ?? 'No description',
                icon: Icons.event,
              );

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailScreen(event: event),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          event.icon,
                          size: 40,
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                event.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat('EEEE dd/MM, h:mm a')
                                                .format(event.startTime),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            event.location,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () =>
                              _showDeleteConfirmationDialog(doc.id),
                        ),
                      ],
                    ),
                  ),
                ),
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
          onPressed: () => _showAddEventDialog(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          tooltip: 'Add New Event',
          child: const Icon(
            Icons.add,
            size: 36,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Event"),
          content: const Text("Are you sure you want to delete this event?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await eventsCollection.doc(docId).delete();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Event deleted successfully")),
                );
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();

    DateTime? selectedStartDate;
    DateTime? selectedEndDate;

    Future<void> pickDateTime(
        BuildContext context, bool isStart, StateSetter setDialogState) async {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );

      if (date == null) return;

      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time == null) return;

      final selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      setDialogState(() {
        if (isStart) {
          selectedStartDate = selectedDateTime;
        } else {
          selectedEndDate = selectedDateTime;
        }
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return Container(
                padding: const EdgeInsets.all(20),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Add New Event",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Event Name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: "Location",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        selectedStartDate == null
                            ? 'Start Time'
                            : 'Start: ${DateFormat('EEEE dd/MM, h:mm a').format(selectedStartDate!)}',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                      TextButton(
                        onPressed: () async {
                          await pickDateTime(context, true, setDialogState);
                        },
                        child: const Text('Pick Start Time'),
                      ),
                      Text(
                        selectedEndDate == null
                            ? 'End Time'
                            : 'End: ${DateFormat('EEEE dd/MM, h:mm a').format(selectedEndDate!)}',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                      TextButton(
                        onPressed: () async {
                          await pickDateTime(context, false, setDialogState);
                        },
                        child: const Text('Pick End Time'),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (selectedStartDate == null ||
                                  selectedEndDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Please select start and end times."),
                                  ),
                                );
                                return;
                              }

                              await eventsCollection.add({
                                'name': nameController.text,
                                'location': locationController.text,
                                'description': descriptionController.text,
                                'startTime':
                                    Timestamp.fromDate(selectedStartDate!),
                                'endTime': Timestamp.fromDate(selectedEndDate!),
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text("Add Event"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
