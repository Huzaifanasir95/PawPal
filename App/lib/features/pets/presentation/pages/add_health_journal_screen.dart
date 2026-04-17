import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_text_styles.dart';

import '../../data/repositories/health_repository_api.dart';

class AddHealthJournalScreen extends StatefulWidget {
  final String petId;
  final String petName;

  const AddHealthJournalScreen({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<AddHealthJournalScreen> createState() => _AddHealthJournalScreenState();
}

class _AddHealthJournalScreenState extends State<AddHealthJournalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _healthRepository = HealthRepositoryApi();

  // Form controllers
  final _weightController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _vetNotesController = TextEditingController();
  final _generalNotesController = TextEditingController();

  // Form values
  DateTime _selectedDate = DateTime.now();
  String _activityLevel = 'moderate'; // 'low', 'moderate', 'high'
  String _energyLevel = 'normal'; // 'low', 'normal', 'high'
  String _mood = 'happy'; // 'happy', 'sad', 'anxious', 'aggressive', 'calm'
  String _appetite = 'normal'; // 'good', 'poor', 'normal'
  String _weightUnit = 'kg'; // 'kg' or 'lbs'
  bool _vetVisit = false;
  String? _vetVisitReason;

  List<String> _symptoms = [];
  List<String> _medicationsTaken = [];

  @override
  void dispose() {
    _weightController.dispose();
    _symptomsController.dispose();
    _medicationsController.dispose();
    _vetNotesController.dispose();
    _generalNotesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addSymptom(String symptom) {
    if (symptom.trim().isNotEmpty && !_symptoms.contains(symptom.trim())) {
      setState(() {
        _symptoms.add(symptom.trim());
      });
      _symptomsController.clear();
    }
  }

  void _removeSymptom(int index) {
    setState(() {
      _symptoms.removeAt(index);
    });
  }

  void _addMedication(String medication) {
    if (medication.trim().isNotEmpty && !_medicationsTaken.contains(medication.trim())) {
      setState(() {
        _medicationsTaken.add(medication.trim());
      });
      _medicationsController.clear();
    }
  }

  void _removeMedication(int index) {
    setState(() {
      _medicationsTaken.removeAt(index);
    });
  }

  Future<void> _submitJournalEntry() async {
    if (_formKey.currentState!.validate()) {
      final colorScheme = Theme.of(context).colorScheme;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      );

      try {
        final entryId = await _healthRepository.createHealthJournalEntry(
          petId: widget.petId,
          date: _selectedDate,
          weight: _weightController.text.trim().isEmpty
              ? null
              : double.parse(_weightController.text.trim()),
          weightUnit: _weightController.text.trim().isEmpty ? null : _weightUnit,
          activityLevel: _activityLevel,
          energyLevel: _energyLevel,
          mood: _mood,
          appetite: _appetite,
          symptoms: _symptoms.isEmpty ? null : _symptoms,
          medicationsTaken: _medicationsTaken.isEmpty ? null : _medicationsTaken,
          vetVisit: _vetVisit,
          vetVisitReason: _vetVisit ? _vetVisitReason : null,
          vetNotes: _vetNotesController.text.trim().isEmpty
              ? null
              : _vetNotesController.text.trim(),
          generalNotes: _generalNotesController.text.trim().isEmpty
              ? null
              : _generalNotesController.text.trim(),
        );

        // Close loading
        Navigator.pop(context);

        if (entryId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Health journal entry added successfully!'),
              backgroundColor: colorScheme.tertiary,
            ),
          );
          Navigator.pop(context, true); // Return success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add health journal entry'),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      } catch (e) {
        // Close loading
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface,
            size: 24.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Health Journal - ${widget.petName}',
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 18.sp,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Selection
              Text(
                'Date',
                style: AppTextStyles.onboardingTitle.copyWith(
                  fontSize: 16.sp,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: colorScheme.primary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                        style: AppTextStyles.onboardingBody.copyWith(
                          fontSize: 16.sp,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Physical Health
              Text(
                'Physical Health',
                style: AppTextStyles.onboardingTitle.copyWith(
                  fontSize: 18.sp,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),

              // Weight
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      label: 'Weight (Optional)',
                      controller: _weightController,
                      hint: '25.5',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Unit',
                      value: _weightUnit,
                      items: ['kg', 'lbs'],
                      onChanged: (value) {
                        setState(() {
                          _weightUnit = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Activity Level
              _buildDropdown(
                label: 'Activity Level',
                value: _activityLevel,
                items: ['low', 'moderate', 'high'],
                onChanged: (value) {
                  setState(() {
                    _activityLevel = value!;
                  });
                },
              ),

              SizedBox(height: 16.h),

              // Energy Level
              _buildDropdown(
                label: 'Energy Level',
                value: _energyLevel,
                items: ['low', 'normal', 'high'],
                onChanged: (value) {
                  setState(() {
                    _energyLevel = value!;
                  });
                },
              ),

              SizedBox(height: 24.h),

              // Mood and Behavior
              Text(
                'Mood & Behavior',
                style: AppTextStyles.onboardingTitle.copyWith(
                  fontSize: 18.sp,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),

              // Mood
              _buildDropdown(
                label: 'Mood',
                value: _mood,
                items: ['happy', 'sad', 'anxious', 'aggressive', 'calm'],
                onChanged: (value) {
                  setState(() {
                    _mood = value!;
                  });
                },
              ),

              SizedBox(height: 16.h),

              // Appetite
              _buildDropdown(
                label: 'Appetite',
                value: _appetite,
                items: ['good', 'poor', 'normal'],
                onChanged: (value) {
                  setState(() {
                    _appetite = value!;
                  });
                },
              ),

              SizedBox(height: 24.h),

              // Health Observations
              Text(
                'Health Observations',
                style: AppTextStyles.onboardingTitle.copyWith(
                  fontSize: 18.sp,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),

              // Symptoms
              Text(
                'Symptoms (Optional)',
                style: AppTextStyles.onboardingTitle.copyWith(
                  fontSize: 16.sp,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _symptomsController,
                      decoration: InputDecoration(
                        hintText: 'Enter symptom...',
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                      onSubmitted: _addSymptom,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: () => _addSymptom(_symptomsController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Add',
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 14.sp,
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _symptoms.map((symptom) {
                  return Chip(
                    label: Text(
                      symptom,
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 12.sp,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    deleteIcon: Icon(
                      Icons.close,
                      size: 16.sp,
                      color: colorScheme.error,
                    ),
                    onDeleted: () => _removeSymptom(_symptoms.indexOf(symptom)),
                    backgroundColor: colorScheme.surface,
                  );
                }).toList(),
              ),

              SizedBox(height: 16.h),

              // Medications Taken
              Text(
                'Medications Taken (Optional)',
                style: AppTextStyles.onboardingTitle.copyWith(
                  fontSize: 16.sp,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _medicationsController,
                      decoration: InputDecoration(
                        hintText: 'Enter medication...',
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                      onSubmitted: _addMedication,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: () => _addMedication(_medicationsController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Add',
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 14.sp,
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _medicationsTaken.map((medication) {
                  return Chip(
                    label: Text(
                      medication,
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 12.sp,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    deleteIcon: Icon(
                      Icons.close,
                      size: 16.sp,
                      color: colorScheme.error,
                    ),
                    onDeleted: () => _removeMedication(_medicationsTaken.indexOf(medication)),
                    backgroundColor: colorScheme.surface,
                  );
                }).toList(),
              ),

              SizedBox(height: 24.h),

              // Vet Visit
              SwitchListTile(
                title: Text(
                  'Vet Visit Today',
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 16.sp,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: _vetVisit,
                onChanged: (value) {
                  setState(() {
                    _vetVisit = value;
                  });
                },
                activeColor: colorScheme.primary,
              ),

              if (_vetVisit) ...[
                SizedBox(height: 16.h),
                _buildTextField(
                  label: 'Reason for Visit',
                  controller: TextEditingController(text: _vetVisitReason),
                  hint: 'e.g., Check-up, Vaccination',
                  onChanged: (value) {
                    _vetVisitReason = value;
                  },
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  label: 'Vet Notes',
                  controller: _vetNotesController,
                  hint: 'Notes from the vet visit...',
                  maxLines: 3,
                ),
              ],

              SizedBox(height: 16.h),

              // General Notes
              _buildTextField(
                label: 'General Notes (Optional)',
                controller: _generalNotesController,
                hint: 'Any other observations or notes...',
                maxLines: 4,
              ),

              SizedBox(height: 30.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _submitJournalEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    'Save Journal Entry',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 18.sp,
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 16.sp,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 16.sp,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.onboardingBody.copyWith(
              fontSize: 16.sp,
              color: colorScheme.onSurfaceVariant,
            ),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.error),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 16.sp,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 16.sp,
                    color: colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}