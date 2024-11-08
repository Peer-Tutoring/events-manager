import 'package:flutter/material.dart';

class Event {
  final String name;
  final String time;
  final String location;
  final String description;
  final IconData icon;

  Event({
    required this.name,
    required this.time,
    required this.location,
    required this.description,
    required this.icon,
  });
}
