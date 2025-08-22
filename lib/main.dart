import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/crop_provider.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const CropTrackerApp());
}

class CropTrackerApp extends StatelessWidget {
  const CropTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CropProvider(),
      child: MaterialApp(
        title: 'Crop Tracker',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}