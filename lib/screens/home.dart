import 'package:events_manager/models/event.dart';
import 'package:events_manager/screens/event_detail.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: eventsCollection.snapshots(),
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
            );
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
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
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '${DateFormat('yyyy-MM-dd HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      event.location,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
        height: 70, // Adjust the size
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.4),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 3), // Change position of shadow
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
            size: 36, // Increase icon size for visibility
          ),
        ),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();

    DateTime? selectedStartDate;
    DateTime? selectedEndDate;

    Future<void> _pickDateTime(BuildContext context, bool isStart) async {
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

      if (isStart) {
        selectedStartDate = selectedDateTime;
      } else {
        selectedEndDate = selectedDateTime;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Event"),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: "Event Name"),
                    ),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: "Location"),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: "Description"),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            selectedStartDate == null
                                ? 'Start Time'
                                : 'Start: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedStartDate!)}',
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow
                                .ellipsis, // Truncate overflowed text
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _pickDateTime(context, true);
                            setDialogState(() {}); // Update the dialog state
                          },
                          child: const Text('Pick Start Time'),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            selectedEndDate == null
                                ? 'End Time'
                                : 'End: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedEndDate!)}',
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow
                                .ellipsis, // Truncate overflowed text
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _pickDateTime(context, false);
                            setDialogState(() {}); // Update the dialog state
                          },
                          child: const Text('Pick End Time'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedStartDate == null || selectedEndDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please select start and end times.")),
                  );
                  return;
                }

                // Save event to Firestore
                await eventsCollection.add({
                  'name': nameController.text,
                  'location': locationController.text,
                  'description': descriptionController.text,
                  'startTime': Timestamp.fromDate(selectedStartDate!),
                  'endTime': Timestamp.fromDate(selectedEndDate!),
                });
                Navigator.of(context).pop();
              },
              child: const Text("Add Event"),
            ),
          ],
        );
      },
    );
  }
}
