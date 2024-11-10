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
  String? selectedCategory;
  String? endTimeError;

  final Map<String, String> categoryImages = {
    'Conference': 'conference.jpg',
    'Workshop': 'workshop.png',
    'Hackathon': 'hackathon.png',
    'Party': 'party.jpg',
  };

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
        endTimeError = null;
      } else {
        selectedEndDate = selectedDateTime;
        if (selectedEndDate!.isBefore(selectedStartDate!)) {
          endTimeError = "End time should be after start time.";
        } else {
          endTimeError = null;
        }
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
              ),
              const SizedBox(height: 20),
              const Text(
                "General Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Event Name",
                  prefixIcon: const Icon(Icons.event),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: "Location",
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Category",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Select Category",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                value: selectedCategory,
                items: categoryImages.keys.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Date and Time",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  selectedStartDate == null
                      ? 'Pick Start Date & Time'
                      : 'Start: ${DateFormat('EEE, dd MMM yyyy, h:mm a').format(selectedStartDate!)}',
                  style: const TextStyle(fontSize: 16),
                ),
                onPressed: () async {
                  await pickDateTime(context, true, setState);
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  selectedEndDate == null
                      ? 'Pick End Date & Time'
                      : 'End: ${DateFormat('EEE, dd MMM yyyy, h:mm a').format(selectedEndDate!)}',
                  style: const TextStyle(fontSize: 16),
                ),
                onPressed: () async {
                  await pickDateTime(context, false, setState);
                },
              ),
              if (endTimeError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    endTimeError!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedStartDate == null ||
                          selectedEndDate == null ||
                          selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please complete all fields."),
                          ),
                        );
                        return;
                      }

                      if (selectedEndDate!.isBefore(selectedStartDate!)) {
                        setState(() {
                          endTimeError = "End time should be after start time.";
                        });
                        return;
                      }

                      final imagePath = categoryImages[selectedCategory!];

                      await widget.eventsCollection.add({
                        'name': nameController.text,
                        'location': locationController.text,
                        'description': descriptionController.text,
                        'startTime': Timestamp.fromDate(selectedStartDate!),
                        'endTime': Timestamp.fromDate(selectedEndDate!),
                        'category': selectedCategory,
                        'imagePath': imagePath,
                      });
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text(
                      "Add Event",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
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
