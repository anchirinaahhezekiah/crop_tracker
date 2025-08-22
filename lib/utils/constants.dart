class AppConstants {
  // App info
  static const String appName = 'Crop Tracker';
  static const String appVersion = '1.0.0';

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Dimensions
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;

  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Text limits
  static const int maxCropNameLength = 50;
  static const int maxNotesLength = 500;

  // Date formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';

  // Error messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNoConnection = 'No internet connection available.';
  static const String errorLoadingData = 'Failed to load data.';
  static const String errorSavingData = 'Failed to save data.';

  // Success messages
  static const String successCropAdded = 'Crop added successfully!';
  static const String successCropUpdated = 'Crop updated successfully!';
  static const String successCropDeleted = 'Crop deleted successfully!';

  // Form validation messages
  static const String validationRequired = 'This field is required';
  static const String validationCropName = 'Please enter a valid crop name';
  static const String validationDateInvalid = 'Please select a valid date';
  static const String validationHarvestBeforePlanting = 'Harvest date must be after planting date';

  // Crop statuses
  static const List<String> cropStatuses = ['Growing', 'Ready', 'Harvested'];

  // Popular crop names (for suggestions)
  static const List<String> popularCrops = [
    'Tomatoes',
    'Carrots',
    'Lettuce',
    'Bell Peppers',
    'Spinach',
    'Broccoli',
    'Cucumber',
    'Radish',
    'Corn',
    'Beans',
    'Peas',
    'Onions',
    'Potatoes',
    'Cabbage',
    'Kale',
  ];
}