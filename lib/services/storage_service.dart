import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crop.dart';

class StorageService {
  static const String _cropsKey = 'crops';

  // Save crops to local storage
  static Future<void> saveCrops(List<Crop> crops) async {
    final prefs = await SharedPreferences.getInstance();
    final cropsJson = crops.map((crop) => crop.toJson()).toList();
    final jsonString = jsonEncode(cropsJson);
    await prefs.setString(_cropsKey, jsonString);
  }

  // Load crops from local storage
  static Future<List<Crop>> loadCrops() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cropsKey);

    if (jsonString == null) {
      return _getInitialCrops();
    }

    try {
      final List<dynamic> cropsJson = jsonDecode(jsonString);
      return cropsJson.map((json) => Crop.fromJson(json)).toList();
    } catch (e) {
      // If there's an error loading, return initial crops
      return _getInitialCrops();
    }
  }

  // Get initial mock crops
  static List<Crop> _getInitialCrops() {
    final now = DateTime.now();
    return [
      Crop(
        id: '1',
        name: 'Tomatoes',
        plantingDate: now.subtract(const Duration(days: 30)),
        expectedHarvestDate: now.add(const Duration(days: 60)),
        notes: 'Cherry tomatoes in greenhouse',
        status: CropStatus.growing,
      ),
      Crop(
        id: '2',
        name: 'Carrots',
        plantingDate: now.subtract(const Duration(days: 45)),
        expectedHarvestDate: now.add(const Duration(days: 30)),
        notes: 'Purple haze variety',
        status: CropStatus.ready,
      ),
      Crop(
        id: '3',
        name: 'Lettuce',
        plantingDate: now.subtract(const Duration(days: 60)),
        expectedHarvestDate: now.subtract(const Duration(days: 5)),
        notes: 'Buttercrunch lettuce',
        status: CropStatus.harvested,
      ),
      Crop(
        id: '4',
        name: 'Bell Peppers',
        plantingDate: now.subtract(const Duration(days: 20)),
        expectedHarvestDate: now.add(const Duration(days: 80)),
        notes: 'Red and yellow varieties',
        status: CropStatus.growing,
      ),
      Crop(
        id: '5',
        name: 'Spinach',
        plantingDate: now.subtract(const Duration(days: 25)),
        expectedHarvestDate: now.add(const Duration(days: 35)),
        notes: 'Baby spinach for salads',
        status: CropStatus.growing,
      ),
    ];
  }

  // Clear all data (useful for testing)
  static Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cropsKey);
  }
}