import 'package:flutter/material.dart';

class Event {
  final String id;
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String description;
  final IconData icon;
  final String imagePath;

  Event({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.description,
    required this.icon,
    required this.imagePath,
  });
}
