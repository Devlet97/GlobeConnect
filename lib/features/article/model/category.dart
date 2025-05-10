import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;
  bool isSelected;

  Category({
    required this.name,
    required this.icon,
    this.isSelected = false,
  });
}
