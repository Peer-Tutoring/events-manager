import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddEventDialog extends StatefulWidget {
  final CollectionReference eventsCollection;

  const AddEventDialog({super.key, required this.eventsCollection});

  @override
  AddEventDialogState createState() => AddEventDialogState();
}

class AddEventDialogState extends State<AddEventDialog> {
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

    setState(() {
      if (isStart) {
        selectedStartDate = selectedDateTime;
      } else {
        selectedEndDate = selectedDateTime;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add New Event",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
              ),
              TextButton(
                onPressed: () async {
                  await pickDateTime(context, true, setState);
                },
                child: const Text('Pick Start Time'),
              ),
              Text(
                selectedEndDate == null
                    ? 'End Time'
                    : 'End: ${DateFormat('EEEE dd/MM, h:mm a').format(selectedEndDate!)}',
                style: const TextStyle(fontSize: 16),
              ),
              TextButton(
                onPressed: () async {
                  await pickDateTime(context, false, setState);
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
                            content: Text("Please select start and end times."),
                          ),
                        );
                        return;
                      }

                      await widget.eventsCollection.add({
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
