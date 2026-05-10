import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxAttendeesController = TextEditingController();

  String _eventType = 'meetup';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isPetFriendly = true;

  static const _eventTypes = {
    'Meetup': 'meetup',
    'Adoption Drive': 'adoption_drive',
    'Training': 'training',
    'Competition': 'competition',
    'Charity': 'charity',
    'Other': 'other',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxAttendeesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventsCubit, EventsState>(
      listener: (context, state) {
        if (state.error != null) {
          CustomSnackbar.showError(context, state.error!);
          context.read<EventsCubit>().clearError();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6F2),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.secondary, size: 24.sp),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Create Event',
            style: AppTextStyles.onboardingTitle.copyWith(
              fontSize: 20.sp,
              color: Theme.of(context).colorScheme.secondary,
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
                // Event type
                _sectionLabel('Event Type *'),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _eventTypes.entries.map((e) {
                    final isActive = _eventType == e.value;
                    return GestureDetector(
                      onTap: () => setState(() => _eventType = e.value),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isActive ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isActive ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: Text(
                          e.key,
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 13.sp,
                            color: isActive ? Colors.white : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20.h),

                _buildField('Title *', _titleController,
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),

                _buildField('Description *', _descriptionController,
                    maxLines: 4,
                    hint: 'Describe your event...',
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),

                // Start date
                _sectionLabel('Start Date & Time *'),
                SizedBox(height: 8.h),
                _datePicker(
                  value: _startDate,
                  hint: 'Select start date & time',
                  onTap: () => _pickDateTime(isStart: true),
                ),
                SizedBox(height: 16.h),

                // End date
                _sectionLabel('End Date & Time'),
                SizedBox(height: 8.h),
                _datePicker(
                  value: _endDate,
                  hint: 'Select end date & time (optional)',
                  onTap: () => _pickDateTime(isStart: false),
                ),
                SizedBox(height: 16.h),

                _buildField('Location', _locationController),
                _buildField('Max Attendees', _maxAttendeesController,
                    hint: 'Leave empty for unlimited',
                    keyboardType: TextInputType.number),

                // Pet friendly toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionLabel('Pet Friendly'),
                    Switch(
                      value: _isPetFriendly,
                      onChanged: (v) => setState(() => _isPetFriendly = v),
                      activeColor: Colors.green,
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                _buildSubmitButton(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _datePicker({DateTime? value, required String hint, required VoidCallback onTap}) {
    final fmt = DateFormat('EEE, MMM d, yyyy · h:mm a');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 18.sp, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                value != null ? fmt.format(value) : hint,
                style: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 14.sp,
                  color: value != null ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? _startDate ?? now),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        isStart ? (_startDate ?? now) : (_endDate ?? _startDate ?? now),
      ),
    );
    if (time == null || !mounted) return;

    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _startDate = dt;
      } else {
        _endDate = dt;
      }
    });
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.onboardingBody.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.onboardingBody.copyWith(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: state.isCreating ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: state.isCreating
                ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Create Event',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) {
      CustomSnackbar.showError(context, 'Please select a start date');
      return;
    }

    final maxText = _maxAttendeesController.text.trim();
    final maxAttendees = maxText.isNotEmpty ? int.tryParse(maxText) : null;

    final success = await context.read<EventsCubit>().createEvent(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          eventType: _eventType,
          startDate: _startDate!.toUtc().toIso8601String(),
          endDate: _endDate?.toUtc().toIso8601String(),
          location: _optional(_locationController),
          maxAttendees: maxAttendees,
          isPetFriendly: _isPetFriendly,
        );

    if (success && mounted) {
      CustomSnackbar.showSuccess(context, 'Event created successfully!');
      Navigator.pop(context, true);
    }
  }

  String? _optional(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }
}

