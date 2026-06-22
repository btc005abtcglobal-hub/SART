import 'package:flutter/material.dart';

class ServiceItem {
  final String name;
  final IconData icon;
  final String routeName;
  final String? subtitle;

  const ServiceItem({
    required this.name,
    required this.icon,
    required this.routeName,
    this.subtitle,
  });
}
