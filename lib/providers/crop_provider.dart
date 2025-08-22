import 'package:flutter/foundation.dart';
import '../models/crop.dart';
import '../services/storage_service.dart';

class CropProvider with ChangeNotifier {
  List<Crop> _crops = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Crop> get crops {
    if (_searchQuery.isEmpty) {
      return List.unmodifiable(_crops);
    }
    return _crops
        .where((crop) => crop.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // Initialize crops from storage
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _crops = await StorageService.loadCrops();
    } catch (e) {
      debugPrint('Error loading crops: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add a new crop
  Future<void> addCrop(Crop crop) async {
    _crops.add(crop);
    await _saveCrops();
    notifyListeners();
  }

  // Update an existing crop
  Future<void> updateCrop(String id, Crop updatedCrop) async {
    final index = _crops.indexWhere((crop) => crop.id == id);
    if (index != -1) {
      _crops[index] = updatedCrop;
      await _saveCrops();
      notifyListeners();
    }
  }

  // Delete a crop
  Future<void> deleteCrop(String id) async {
    _crops.removeWhere((crop) => crop.id == id);
    await _saveCrops();
    notifyListeners();
  }

  // Update crop status
  Future<void> updateCropStatus(String id, CropStatus status) async {
    final index = _crops.indexWhere((crop) => crop.id == id);
    if (index != -1) {
      _crops[index] = _crops[index].copyWith(status: status);
      await _saveCrops();
      notifyListeners();
    }
  }

  // Get crop by ID
  Crop? getCropById(String id) {
    try {
      return _crops.firstWhere((crop) => crop.id == id);
    } catch (e) {
      return null;
    }
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _saveCrops() async {
    try {
      await StorageService.saveCrops(_crops);
    } catch (e) {
      debugPrint('Error saving crops: $e');
    }
  }

  // Generate unique ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Create crop with generated ID
  Crop createCrop({
    required String name,
    required DateTime plantingDate,
    required DateTime expectedHarvestDate,
    String notes = '',
    CropStatus status = CropStatus.growing,
  }) {
    return Crop(
      id: _generateId(),
      name: name,
      plantingDate: plantingDate,
      expectedHarvestDate: expectedHarvestDate,
      notes: notes,
      status: status,
    );
  }

  // Get crops by status
  List<Crop> getCropsByStatus(CropStatus status) {
    return _crops.where((crop) => crop.status == status).toList();
  }

  // Get crop count by status
  int getCropCountByStatus(CropStatus status) {
    return _crops.where((crop) => crop.status == status).length;
  }
}