import 'package:flutter_test/flutter_test.dart';
import 'package:crop_tracker/models/crop.dart';

void main() {
  group('Crop Model Tests', () {
    late DateTime plantingDate;
    late DateTime harvestDate;

    setUp(() {
      plantingDate = DateTime(2024, 3, 15);
      harvestDate = DateTime(2024, 6, 15);
    });

    test('should create a crop with all required fields', () {
      // Arrange & Act
      final crop = Crop(
        id: '1',
        name: 'Test Crop',
        plantingDate: plantingDate,
        expectedHarvestDate: harvestDate,
        notes: 'Test notes',
        status: CropStatus.growing,
      );

      // Assert
      expect(crop.id, '1');
      expect(crop.name, 'Test Crop');
      expect(crop.plantingDate, plantingDate);
      expect(crop.expectedHarvestDate, harvestDate);
      expect(crop.notes, 'Test notes');
      expect(crop.status, CropStatus.growing);
    });

    test('should create a crop with default values', () {
      // Arrange & Act
      final crop = Crop(
        id: '1',
        name: 'Test Crop',
        plantingDate: plantingDate,
        expectedHarvestDate: harvestDate,
      );

      // Assert
      expect(crop.notes, '');
      expect(crop.status, CropStatus.growing);
    });

    test('should create a copy with updated values', () {
      // Arrange
      final originalCrop = Crop(
        id: '1',
        name: 'Original Crop',
        plantingDate: plantingDate,
        expectedHarvestDate: harvestDate,
        status: CropStatus.growing,
      );

      // Act
      final updatedCrop = originalCrop.copyWith(
        name: 'Updated Crop',
        status: CropStatus.ready,
      );

      // Assert
      expect(updatedCrop.id, originalCrop.id);
      expect(updatedCrop.name, 'Updated Crop');
      expect(updatedCrop.plantingDate, originalCrop.plantingDate);
      expect(updatedCrop.expectedHarvestDate, originalCrop.expectedHarvestDate);
      expect(updatedCrop.status, CropStatus.ready);
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final crop = Crop(
        id: '1',
        name: 'Test Crop',
        plantingDate: plantingDate,
        expectedHarvestDate: harvestDate,
        notes: 'Test notes',
        status: CropStatus.ready,
      );

      // Act
      final json = crop.toJson();

      // Assert
      expect(json['id'], '1');
      expect(json['name'], 'Test Crop');
      expect(json['plantingDate'], plantingDate.millisecondsSinceEpoch);
      expect(json['expectedHarvestDate'], harvestDate.millisecondsSinceEpoch);
      expect(json['notes'], 'Test notes');
      expect(json['status'], 'Ready');
    });

    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'id': '1',
        'name': 'Test Crop',
        'plantingDate': plantingDate.millisecondsSinceEpoch,
        'expectedHarvestDate': harvestDate.millisecondsSinceEpoch,
        'notes': 'Test notes',
        'status': 'Ready',
      };

      // Act
      final crop = Crop.fromJson(json);

      // Assert
      expect(crop.id, '1');
      expect(crop.name, 'Test Crop');
      expect(crop.plantingDate, plantingDate);
      expect(crop.expectedHarvestDate, harvestDate);
      expect(crop.notes, 'Test notes');
      expect(crop.status, CropStatus.ready);
    });

    test('should format dates correctly', () {
      // Arrange
      final crop = Crop(
        id: '1',
        name: 'Test Crop',
        plantingDate: DateTime(2024, 3, 15),
        expectedHarvestDate: DateTime(2024, 6, 15),
      );

      // Act & Assert
      expect(crop.formattedPlantingDate, 'Mar 15, 2024');
      expect(crop.formattedHarvestDate, 'Jun 15, 2024');
    });

    group('Date Validation', () {
      test('should return null for valid dates', () {
        // Arrange
        final planting = DateTime(2024, 3, 15);
        final harvest = DateTime(2024, 6, 15);

        // Act
        final result = Crop.validateDates(planting, harvest);

        // Assert
        expect(result, isNull);
      });

      test('should return error message when harvest is before planting', () {
        // Arrange
        final planting = DateTime(2024, 6, 15);
        final harvest = DateTime(2024, 3, 15);

        // Act
        final result = Crop.validateDates(planting, harvest);

        // Assert
        expect(result, 'Harvest date must be after planting date');
      });

      test('should return null when harvest is same day as planting', () {
        // Arrange
        final planting = DateTime(2024, 3, 15);
        final harvest = DateTime(2024, 3, 15);

        // Act
        final result = Crop.validateDates(planting, harvest);

        // Assert
        expect(result, isNull);
      });
    });

    group('CropStatus Enum', () {
      test('should convert from string correctly', () {
        // Act & Assert
        expect(CropStatus.fromString('Growing'), CropStatus.growing);
        expect(CropStatus.fromString('Ready'), CropStatus.ready);
        expect(CropStatus.fromString('Harvested'), CropStatus.harvested);
        expect(CropStatus.fromString('Invalid'), CropStatus.growing); // Default
      });

      test('should have correct display names', () {
        // Act & Assert
        expect(CropStatus.growing.displayName, 'Growing');
        expect(CropStatus.ready.displayName, 'Ready');
        expect(CropStatus.harvested.displayName, 'Harvested');
      });
    });

    group('Equality', () {
      test('should be equal when ids are the same', () {
        // Arrange
        final crop1 = Crop(
          id: '1',
          name: 'Crop A',
          plantingDate: plantingDate,
          expectedHarvestDate: harvestDate,
        );
        final crop2 = Crop(
          id: '1',
          name: 'Crop B',
          plantingDate: DateTime(2024, 1, 1),
          expectedHarvestDate: DateTime(2024, 12, 31),
        );

        // Act & Assert
        expect(crop1, equals(crop2));
        expect(crop1.hashCode, equals(crop2.hashCode));
      });

      test('should not be equal when ids are different', () {
        // Arrange
        final crop1 = Crop(
          id: '1',
          name: 'Test Crop',
          plantingDate: plantingDate,
          expectedHarvestDate: harvestDate,
        );
        final crop2 = Crop(
          id: '2',
          name: 'Test Crop',
          plantingDate: plantingDate,
          expectedHarvestDate: harvestDate,
        );

        // Act & Assert
        expect(crop1, isNot(equals(crop2)));
      });
    });
  });
}