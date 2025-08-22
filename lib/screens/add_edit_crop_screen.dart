import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/crop_provider.dart';
import '../models/crop.dart';
import '../utils/constants.dart';

class AddEditCropScreen extends StatefulWidget {
  final String? cropId;

  const AddEditCropScreen({super.key, this.cropId});

  bool get isEditing => cropId != null;

  @override
  State<AddEditCropScreen> createState() => _AddEditCropScreenState();
}

class _AddEditCropScreenState extends State<AddEditCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _plantingDate;
  DateTime? _harvestDate;
  CropStatus _status = CropStatus.growing;
  bool _isLoading = false;
  Crop? _originalCrop;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadCropData();
    }
  }

  void _loadCropData() {
    final cropProvider = context.read<CropProvider>();
    _originalCrop = cropProvider.getCropById(widget.cropId!);

    if (_originalCrop != null) {
      _nameController.text = _originalCrop!.name;
      _notesController.text = _originalCrop!.notes;
      _plantingDate = _originalCrop!.plantingDate;
      _harvestDate = _originalCrop!.expectedHarvestDate;
      _status = _originalCrop!.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Crop' : 'Add New Crop'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveCrop,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isLoading ? Colors.grey : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Crop name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Crop Name',
                  hintText: 'e.g., Tomatoes, Carrots',
                  prefixIcon: Icon(Icons.eco),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppConstants.validationCropName;
                  }
                  if (value.trim().length > AppConstants.maxCropNameLength) {
                    return 'Crop name must be less than ${AppConstants.maxCropNameLength} characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Planting date field
              _buildDateField(
                label: 'Planting Date',
                icon: Icons.eco,
                selectedDate: _plantingDate,
                onDateSelected: (date) {
                  setState(() {
                    _plantingDate = date;
                  });
                },
                validator: (date) {
                  if (date == null) {
                    return 'Please select a planting date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Expected harvest date field
              _buildDateField(
                label: 'Expected Harvest Date',
                icon: Icons.schedule,
                selectedDate: _harvestDate,
                onDateSelected: (date) {
                  setState(() {
                    _harvestDate = date;
                  });
                },
                validator: (date) {
                  if (date == null) {
                    return 'Please select an expected harvest date';
                  }
                  if (_plantingDate != null && date.isBefore(_plantingDate!)) {
                    return AppConstants.validationHarvestBeforePlanting;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Status dropdown (only for editing)
              if (widget.isEditing) ...[
                DropdownButtonFormField<CropStatus>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.info),
                  ),
                  items: CropStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Notes field
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Additional information about this crop',
                  prefixIcon: Icon(Icons.note),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                maxLength: AppConstants.maxNotesLength,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveCrop,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    widget.isEditing ? 'Update Crop' : 'Add Crop',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              // Cancel button
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required DateTime? selectedDate,
    required void Function(DateTime) onDateSelected,
    required String? Function(DateTime?) validator,
  }) {
    return GestureDetector(
      onTap: () => _selectDate(onDateSelected),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          controller: TextEditingController(
            text: selectedDate != null
                ? DateFormat(AppConstants.dateFormat).format(selectedDate)
                : '',
          ),
          validator: (value) => validator(selectedDate),
        ),
      ),
    );
  }

  Future<void> _selectDate(void Function(DateTime) onDateSelected) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      onDateSelected(selectedDate);
    }
  }

  Future<void> _saveCrop() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Additional date validation
    if (_plantingDate != null && _harvestDate != null) {
      final dateError = Crop.validateDates(_plantingDate!, _harvestDate!);
      if (dateError != null) {
        _showErrorSnackBar(dateError);
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cropProvider = context.read<CropProvider>();

      if (widget.isEditing) {
        // Update existing crop
        final updatedCrop = _originalCrop!.copyWith(
          name: _nameController.text.trim(),
          plantingDate: _plantingDate!,
          expectedHarvestDate: _harvestDate!,
          notes: _notesController.text.trim(),
          status: _status,
        );

        await cropProvider.updateCrop(widget.cropId!, updatedCrop);
        _showSuccessSnackBar(AppConstants.successCropUpdated);
      } else {
        // Create new crop
        final newCrop = cropProvider.createCrop(
          name: _nameController.text.trim(),
          plantingDate: _plantingDate!,
          expectedHarvestDate: _harvestDate!,
          notes: _notesController.text.trim(),
          status: _status,
        );

        await cropProvider.addCrop(newCrop);
        _showSuccessSnackBar(AppConstants.successCropAdded);
      }

      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar(AppConstants.errorSavingData);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}