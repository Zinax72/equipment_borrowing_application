import 'package:flutter/material.dart';

class Equipment {
  final String name;
  final String category;
  final int available;
  final IconData icon;
  final String description;
  final String imageUrl;

  const Equipment({
    required this.name,
    required this.category,
    required this.available,
    required this.icon,
    required this.description,
    required this.imageUrl,
  });
}
