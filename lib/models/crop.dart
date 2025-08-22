import 'package:intl/intl.dart';

enum CropStatus {
  growing('Growing'),
  ready('Ready'),
  harvested('Harvested');

  const CropStatus(this.displayName);
  final String displayName;

  static CropStatus fromString(String status) {
    return CropStatus.values
        .firstWhere((s) => s.displayName == status, orElse: () => CropStatus.growing);
  }
}

class Crop {
  final String id;
  final String name;
  final DateTime plantingDate;
  final DateTime expectedHarvestDate;
  final String notes;
  final CropStatus status;

  Crop({
    required this.id,
    required this.name,
    required this.plantingDate,
    required this.expectedHarvestDate,
    this.notes = '',
    this.status = CropStatus.growing,
  });

  // Create a copy of the crop with updated values
  Crop copyWith({
    String? id,
    String? name,
    DateTime? plantingDate,
    DateTime? expectedHarvestDate,
    String? notes,
    CropStatus? status,
  }) {
    return Crop(
      id: id ?? this.id,
      name: name ?? this.name,
      plantingDate: plantingDate ?? this.plantingDate,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  // Convert crop to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plantingDate': plantingDate.millisecondsSinceEpoch,
      'expectedHarvestDate': expectedHarvestDate.millisecondsSinceEpoch,
      'notes': notes,
      'status': status.displayName,
    };
  }

  // Create crop from JSON
  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'],
      name: json['name'],
      plantingDate: DateTime.fromMillisecondsSinceEpoch(json['plantingDate']),
      expectedHarvestDate: DateTime.fromMillisecondsSinceEpoch(json['expectedHarvestDate']),
      notes: json['notes'] ?? '',
      status: CropStatus.fromString(json['status']),
    );
  }

  // Formatted dates for display
  String get formattedPlantingDate => DateFormat('MMM dd, yyyy').format(plantingDate);
  String get formattedHarvestDate => DateFormat('MMM dd, yyyy').format(expectedHarvestDate);

  // Validation
  static String? validateDates(DateTime plantingDate, DateTime harvestDate) {
    if (harvestDate.isBefore(plantingDate)) {
      return 'Harvest date must be after planting date';
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Crop && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}