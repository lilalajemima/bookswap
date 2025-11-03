import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF36213E);
  static const Color secondary = Color(0xFF554971);
  static const Color accent = Color(0xFFFDB913);
  static const Color background = Color(0xFFF5F5F5);
  static const Color white = Colors.white;
  static const Color textDark = Color(0xFF36213E);
  static const Color textLight = Color(0xFF666666);
}

class AppConstants {
  static const String appName = 'BookSwap';
  static const String appTagline = 'Swap Your Books With Other Students';
  
  // Book Conditions
  static const List<String> bookConditions = [
    'New',
    'Like New',
    'Good',
    'Used'
  ];
  
  // Swap Status
  static const String swapPending = 'Pending';
  static const String swapAccepted = 'Accepted';
  static const String swapRejected = 'Rejected';
}