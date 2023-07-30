import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Urgency {urgent, mediumUrgency, notUrgent }

final formatter = DateFormat('dd/M/yyyy');

const urgencyIcons = {
  Urgency.urgent : Icon(Icons.warning_rounded,
  color: Color(0XFFD50000),),
  Urgency.mediumUrgency : Icon(Icons.warning_rounded,
  color: Color(0xFFEF6C00),),
  Urgency.notUrgent: Icon(Icons.warning_rounded,
  color: Color(0xFF1B5E20),)
};

class Plan {
  Plan({
    required this.id,
    required this.title,
    required this.urgency,
    required this.notes,
    required this.date,
  });

  final String id;
  late final String title;
  final DateTime date;
  final Urgency urgency;
  final String notes;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'urgency': urgency.toString().split('.').last, // Convert enum to string
      'notes': notes,
      'date': date.toIso8601String(), // Convert DateTime to string
    };
  }

  String get formattedDate{
    return formatter.format(date);
  }
}