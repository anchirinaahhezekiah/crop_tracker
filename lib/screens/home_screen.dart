import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_provider.dart';
import '../widgets/crop_card.dart';
import '../screens/add_edit_crop_screen.dart';
import '../models/crop.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    // Initialize crops when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CropProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearchBar ? _buildSearchBar() : const Text('Crop Tracker'),
        actions: [
          if (!_showSearchBar)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _showSearchBar = true;
                });
              },
            ),
          if (_showSearchBar)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showSearchBar = false;
                });
                _searchController.clear();
                context.read<CropProvider>().clearSearch();
              },
            ),
        ],
      ),
      body: Consumer<CropProvider>(
        builder: (context, cropProvider, child) {
          if (cropProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final crops = cropProvider.crops;

          if (crops.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              // Summary section
              _buildSummarySection(cropProvider),

              // Crops list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: crops.length,
                  itemBuilder: (context, index) {
                    return CropCard(crop: crops[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditCropScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add New Crop',
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        hintText: 'Search crops...',
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
      onChanged: (value) {
        context.read<CropProvider>().setSearchQuery(value);
      },
    );
  }

  Widget _buildSummarySection(CropProvider cropProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Growing',
              cropProvider.getCropCountByStatus(CropStatus.growing),
              CropStatus.growing,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Ready',
              cropProvider.getCropCountByStatus(CropStatus.ready),
              CropStatus.ready,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Harvested',
              cropProvider.getCropCountByStatus(CropStatus.harvested),
              CropStatus.harvested,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, int count, CropStatus status) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getStatusColor(status),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(CropStatus status) {
    switch (status) {
      case CropStatus.growing:
        return Colors.green;
      case CropStatus.ready:
        return Colors.orange;
      case CropStatus.harvested:
        return Colors.brown;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No crops yet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first crop',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditCropScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add First Crop'),
          ),
        ],
      ),
    );
  }
}