import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/crop.dart';
import '../services/storage_service.dart';

class CropProvider with ChangeNotifier {
  final Uuid _uuid = const Uuid();

  List<Crop> _crops = [];
  List<Crop> _filteredCrops = [];
  String _searchQuery = '';
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Get crops - filtered if searching
  List<Crop> get crops => _searchQuery.isEmpty ? _crops : _filteredCrops;

  String get searchQuery => _searchQuery;

  // Search crops by name or notes
  void searchCrops(String query) {
    _searchQuery = query.trim();

    if (_searchQuery.isEmpty) {
      _filteredCrops = [];
    } else {
      final lowerQuery = _searchQuery.toLowerCase();

      _filteredCrops = _crops.where((crop) {
        final nameMatch = crop.name.toLowerCase().contains(lowerQuery);
        final notesMatch = (crop.notes).toLowerCase().contains(lowerQuery);
        return nameMatch || notesMatch;
      }).toList();
    }

    notifyListeners();
  }

  void setSearchQuery(String query) => searchCrops(query);

  void clearSearch() {
    _searchQuery = '';
    _filteredCrops = [];
    notifyListeners();
  }

  // Get crop by ID
  Crop? getCropById(String id) {
    try {
      return _crops.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  //  Create a new crop with unique ID
  Crop createCrop({
    required String name,
    required DateTime plantingDate,
    required DateTime expectedHarvestDate,
    String notes = '',
    CropStatus status = CropStatus.growing,
  }) {
    return Crop(
      id: _uuid.v4(),
      name: name,
      plantingDate: plantingDate,
      expectedHarvestDate: expectedHarvestDate,
      notes: notes,
      status: status,
    );
  }

  //  Add crop
  Future<void> addCrop(Crop crop) async {
    _crops.add(crop);
    await _saveToStorage();
    if (_searchQuery.isNotEmpty) searchCrops(_searchQuery);
    notifyListeners();
  }

  //  Update crop by ID
  Future<void> updateCrop(String id, Crop updatedCrop) async {
    final index = _crops.indexWhere((c) => c.id == id);
    if (index != -1) {
      _crops[index] = updatedCrop;
      await _saveToStorage();
      if (_searchQuery.isNotEmpty) searchCrops(_searchQuery);
      notifyListeners();
    }
  }

  //  Delete crop by ID
  Future<void> deleteCrop(String id) async {
    _crops.removeWhere((c) => c.id == id);
    await _saveToStorage();
    if (_searchQuery.isNotEmpty) searchCrops(_searchQuery);
    notifyListeners();
  }

  //  Update crop status by ID
  Future<void> updateCropStatus(String id, CropStatus newStatus) async {
    final index = _crops.indexWhere((c) => c.id == id);
    if (index != -1) {
      _crops[index] = _crops[index].copyWith(status: newStatus);
      await _saveToStorage();
      notifyListeners();
    }
  }

  //  Count crops by status
  int getCropCountByStatus(CropStatus status) {
    return _crops.where((c) => c.status == status).length;
  }

  //  Load and save
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    _crops = await StorageService.loadCrops();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    await StorageService.saveCrops(_crops);
  }
}
