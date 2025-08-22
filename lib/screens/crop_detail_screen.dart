import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/crop_provider.dart';
import '../models/crop.dart';
import '../screens/add_edit_crop_screen.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class CropDetailScreen extends StatelessWidget {
  final String cropId;

  const CropDetailScreen({
    super.key,
    required this.cropId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CropProvider>(
      builder: (context, cropProvider, child) {
        final crop = cropProvider.getCropById(cropId);

        if (crop == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Crop Not Found')),
            body: const Center(
              child: Text('This crop could not be found.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(crop.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditCropScreen(cropId: cropId),
                    ),
                  );
                },
                tooltip: 'Edit Crop',
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteConfirmation(context, crop);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Crop'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status section
                _buildStatusSection(context, crop, cropProvider),
                const SizedBox(height: 24),

                // Basic info card
                _buildInfoCard(
                  context,
                  title: 'Basic Information',
                  children: [
                    _buildInfoRow(
                      context,
                      icon: Icons.eco,
                      label: 'Crop Name',
                      value: crop.name,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      icon: Icons.calendar_today,
                      label: 'Planting Date',
                      value: crop.formattedPlantingDate,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      icon: Icons.schedule,
                      label: 'Expected Harvest',
                      value: crop.formattedHarvestDate,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Timeline card
                _buildTimelineCard(context, crop),
                const SizedBox(height: 16),

                // Notes card (if any notes exist)
                if (crop.notes.isNotEmpty) ...[
                  _buildInfoCard(
                    context,
                    title: 'Notes',
                    children: [
                      Text(
                        crop.notes,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Status update section
                _buildStatusUpdateSection(context, crop, cropProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusSection(
      BuildContext context,
      Crop crop,
      CropProvider cropProvider,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.getStatusColor(crop.status.displayName).withOpacity(0.1),
            AppTheme.getStatusColor(crop.status.displayName).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getStatusColor(crop.status.displayName).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(crop.status),
            size: 48,
            color: AppTheme.getStatusColor(crop.status.displayName),
          ),
          const SizedBox(height: 12),
          Text(
            'Current Status',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            crop.status.displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.getStatusColor(crop.status.displayName),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required String title,
        required List<Widget> children,
      }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineCard(BuildContext context, Crop crop) {
    final now = DateTime.now();
    final totalDays = crop.expectedHarvestDate.difference(crop.plantingDate).inDays;
    final daysPassed = now.difference(crop.plantingDate).inDays;
    final daysRemaining = crop.expectedHarvestDate.difference(now).inDays;
    final progress = totalDays > 0 ? (daysPassed / totalDays).clamp(0.0, 1.0) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Growth Timeline',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.getStatusColor(crop.status.displayName),
              ),
            ),
            const SizedBox(height: 16),

            // Timeline stats
            Row(
              children: [
                Expanded(
                  child: _buildTimelineItem(
                    context,
                    'Days Passed',
                    daysPassed.toString(),
                    Icons.history,
                  ),
                ),
                Expanded(
                  child: _buildTimelineItem(
                    context,
                    'Days Remaining',
                    daysRemaining > 0 ? daysRemaining.toString() : 'Overdue',
                    Icons.schedule,
                  ),
                ),
                Expanded(
                  child: _buildTimelineItem(
                    context,
                    'Total Days',
                    totalDays.toString(),
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatusUpdateSection(
      BuildContext context,
      Crop crop,
      CropProvider cropProvider,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CropStatus.values.map((status) {
                final isSelected = crop.status == status;
                return FilterChip(
                  selected: isSelected,
                  label: Text(status.displayName),
                  onSelected: isSelected
                      ? null
                      : (selected) {
                    if (selected) {
                      _updateCropStatus(context, cropProvider, crop, status);
                    }
                  },
                  selectedColor: AppTheme.getStatusBackgroundColor(status.displayName),
                  checkmarkColor: AppTheme.getStatusColor(status.displayName),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(CropStatus status) {
    switch (status) {
      case CropStatus.growing:
        return Icons.eco;
      case CropStatus.ready:
        return Icons.schedule;
      case CropStatus.harvested:
        return Icons.check_circle;
    }
  }

  Future<void> _updateCropStatus(
      BuildContext context,
      CropProvider cropProvider,
      Crop crop,
      CropStatus newStatus,
      ) async {
    try {
      await cropProvider.updateCropStatus(crop.id, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${newStatus.displayName}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, Crop crop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Crop'),
        content: Text('Are you sure you want to delete "${crop.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteCrop(context, crop);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCrop(BuildContext context, Crop crop) async {
    try {
      await context.read<CropProvider>().deleteCrop(crop.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppConstants.successCropDeleted),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context); // Go back to home screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete crop'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}