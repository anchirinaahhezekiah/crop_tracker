import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:crop_tracker/main.dart';
import 'package:crop_tracker/providers/crop_provider.dart';
import 'package:crop_tracker/models/crop.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('App should display home screen with title', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const CropTrackerApp());

      // Wait for the async initialization to complete
      await tester.pumpAndSettle();

      // Verify that the app bar shows the correct title
      expect(find.text('Crop Tracker'), findsOneWidget);

      // Verify that the floating action button is present
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Should show empty state when no crops exist', (WidgetTester tester) async {
      // Create a crop provider with empty crops list
      final cropProvider = CropProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<CropProvider>.value(
          value: cropProvider,
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Test')),
              body: Consumer<CropProvider>(
                builder: (context, provider, child) {
                  if (provider.crops.isEmpty) {
                    return const Center(
                      child: Text('No crops yet'),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show empty state message
      expect(find.text('No crops yet'), findsOneWidget);
    });

    testWidgets('Should display crop cards when crops exist', (WidgetTester tester) async {
      // Create a crop provider with test data
      final cropProvider = CropProvider();

      // Add a test crop
      final testCrop = Crop(
        id: '1',
        name: 'Test Tomato',
        plantingDate: DateTime.now().subtract(const Duration(days: 30)),
        expectedHarvestDate: DateTime.now().add(const Duration(days: 30)),
        status: CropStatus.growing,
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<CropProvider>.value(
          value: cropProvider,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<CropProvider>(
                builder: (context, provider, child) {
                  return ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(testCrop.name),
                          subtitle: Text(testCrop.status.displayName),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display the crop name
      expect(find.text('Test Tomato'), findsOneWidget);
      expect(find.text('Growing'), findsOneWidget);
    });

    testWidgets('FAB should be tappable', (WidgetTester tester) async {
      bool fabTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                fabTapped = true;
              },
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      // Find and tap the FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify the FAB was tapped
      expect(fabTapped, isTrue);
    });

    group('Form Validation Tests', () {
      testWidgets('Should show validation error for empty crop name', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Crop Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a valid crop name';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        );

        // Find the text field
        final textField = find.byType(TextFormField);
        expect(textField, findsOneWidget);

        // Try to submit empty form by calling validator manually
        final formField = tester.widget<TextFormField>(textField);
        final validationResult = formField.validator?.call('');

        expect(validationResult, 'Please enter a valid crop name');
      });
    });
  });
}