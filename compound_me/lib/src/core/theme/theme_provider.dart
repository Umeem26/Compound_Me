import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Saklar sederhana: Menyimpan status apakah Dark Mode atau Light Mode
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);