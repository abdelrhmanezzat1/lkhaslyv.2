import 'package:flutter/material.dart';

/// Defines consistent shadow styles for the application.
///
/// These subtle shadows enhance depth and contribute to the premium UI feel.
class AppShadows {
  AppShadows._(); // Private constructor to prevent instantiation

  // A very subtle shadow, good for general elevation on dark surfaces
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Colors.black26, // Slightly visible on dark background
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  // A slightly more pronounced shadow for elevated elements
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Colors.black38,
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
}
