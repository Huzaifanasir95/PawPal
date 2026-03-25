import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/repositories/caregiver_repository.dart';
import '../../data/models/caregiver_models.dart';

class CaregiverAvailabilityScreen extends StatefulWidget {
  const CaregiverAvailabilityScreen({super.key});

  @override
  State<CaregiverAvailabilityScreen> createState() => _CaregiverAvailabilityScreenState();
}

class _CaregiverAvailabilityScreenState extends State<CaregiverAvailabilityScreen> {
  late CaregiverRepository _repository;
  List<CaregiverAvailability> _availability = [];
  bool _isLoading = true;
  bool _isSaving = false;

  // Local state for editing
  final Map<int, List<_TimeSlot>> _weeklySchedule = {};

  final List<String> _dayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  @override
  void initState() {
    super.initState();
    _repository = getIt<CaregiverRepository>();
    // Initialize empty schedule
    for (int i = 0; i < 7; i++) {
      _weeklySchedule[i] = [];
    }
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final availability = await _repository.getAvailability();
      
      // Convert to local state
      for (int i = 0; i < 7; i++) {
        _weeklySchedule[i] = [];
      }
      for (final slot in availability) {
        _weeklySchedule[slot.dayOfWeek]?.add(_TimeSlot(
          startTime: TimeOfDay(
            hour: int.parse(slot.startTime.split(':')[0]),
            minute: int.parse(slot.startTime.split(':')[1]),
          ),
          endTime: TimeOfDay(
            hour: int.parse(slot.endTime.split(':')[0]),
            minute: int.parse(slot.endTime.split(':')[1]),
          ),
          isAvailable: slot.isAvailable,
        ));
      }

      setState(() {
        _availability = availability;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        CustomSnackbar.showError(context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _saveAvailability() async {
    setState(() => _isSaving = true);
    try {
      final slots = <AvailabilitySlot>[];
      _weeklySchedule.forEach((dayOfWeek, timeSlots) {
        for (final slot in timeSlots) {
          slots.add(AvailabilitySlot(
            dayOfWeek: dayOfWeek,
            startTime: '${slot.startTime.hour.toString().padLeft(2, '0')}:${slot.startTime.minute.toString().padLeft(2, '0')}',
            endTime: '${slot.endTime.hour.toString().padLeft(2, '0')}:${slot.endTime.minute.toString().padLeft(2, '0')}',
            isAvailable: slot.isAvailable,
          ));
        }
      });

      await _repository.setAvailability(SetAvailabilityRequest(slots: slots));
      
      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Availability saved!');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Availability',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveAvailability,
            child: _isSaving
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: AppTextStyles.buttonMedium.copyWith(color: AppColors.primary),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: 7,
              itemBuilder: (context, index) {
                return _buildDayCard(index);
              },
            ),
    );
  }

  Widget _buildDayCard(int dayOfWeek) {
    final slots = _weeklySchedule[dayOfWeek] ?? [];
    final hasSlots = slots.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              _dayNames[dayOfWeek],
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!hasSlots)
                  Text(
                    'Not Available',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  onPressed: () => _addTimeSlot(dayOfWeek),
                ),
              ],
            ),
          ),
          if (hasSlots)
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.h),
              child: Column(
                children: slots.asMap().entries.map((entry) {
                  final index = entry.key;
                  final slot = entry.value;
                  return _buildTimeSlotTile(dayOfWeek, index, slot);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotTile(int dayOfWeek, int index, _TimeSlot slot) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: slot.isAvailable
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => _selectTime(dayOfWeek, index, true),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                slot.startTime.format(context),
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text('-', style: AppTextStyles.bodyMedium),
          ),
          InkWell(
            onTap: () => _selectTime(dayOfWeek, index, false),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                slot.endTime.format(context),
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ),
          const Spacer(),
          Switch(
            value: slot.isAvailable,
            onChanged: (value) {
              setState(() {
                _weeklySchedule[dayOfWeek]![index] = _TimeSlot(
                  startTime: slot.startTime,
                  endTime: slot.endTime,
                  isAvailable: value,
                );
              });
            },
            activeColor: AppColors.primary,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _removeTimeSlot(dayOfWeek, index),
            iconSize: 20.w,
          ),
        ],
      ),
    );
  }

  void _addTimeSlot(int dayOfWeek) {
    setState(() {
      _weeklySchedule[dayOfWeek]!.add(_TimeSlot(
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
        isAvailable: true,
      ));
    });
  }

  void _removeTimeSlot(int dayOfWeek, int index) {
    setState(() {
      _weeklySchedule[dayOfWeek]!.removeAt(index);
    });
  }

  Future<void> _selectTime(int dayOfWeek, int index, bool isStart) async {
    final slot = _weeklySchedule[dayOfWeek]![index];
    final initialTime = isStart ? slot.startTime : slot.endTime;

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        _weeklySchedule[dayOfWeek]![index] = _TimeSlot(
          startTime: isStart ? picked : slot.startTime,
          endTime: isStart ? slot.endTime : picked,
          isAvailable: slot.isAvailable,
        );
      });
    }
  }
}

class _TimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isAvailable;

  _TimeSlot({
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });
}
