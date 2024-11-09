import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String docId;
  final CollectionReference eventsCollection;

  const DeleteConfirmationDialog({
    super.key,
    required this.docId,
    required this.eventsCollection,
  });

  @override
  Widget build(BuildContext context) {
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
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          child: const Text("Delete"),
        ),
      ],
    );
  }
}
