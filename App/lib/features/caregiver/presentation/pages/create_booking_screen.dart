import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/models/caregiver_models.dart';
import '../../data/models/booking_models.dart';
import 'booking_detail_screen.dart';

class CreateBookingScreen extends StatefulWidget {
  final CaregiverProfile caregiver;
  final List<CaregiverService> services;
  final List<CaregiverAvailability> availability;

  const CreateBookingScreen({
    super.key,
    required this.caregiver,
    required this.services,
    required this.availability,
  });

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  late BookingRepository _repository;
  int _currentStep = 0;

  // Step 1: Service Selection
  CaregiverService? _selectedService;

  // Step 2: Date & Time
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  // Step 3: Pet Selection
  List<String> _selectedPetIds = [];
  List<Map<String, String>> _userPets = []; // Mock data - should come from pet repository

  // Step 4: Additional Details
  String _locationType = 'owner_home';
  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _repository = getIt<BookingRepository>();
    // Mock pets - In real app, load from pet repository
    _userPets = [
      {'id': 'pet1', 'name': 'Max', 'type': 'Dog'},
      {'id': 'pet2', 'name': 'Whiskers', 'type': 'Cat'},
    ];
  }

  @override
  void dispose() {
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Book ${widget.caregiver.userName ?? "Caregiver"}',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: _buildCurrentStep(),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: List.generate(4, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? AppColors.primary
                        : AppColors.textSecondary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 16.w)
                        : Text(
                            '${index + 1}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isCurrent ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 2.h,
                      color: isCompleted
                          ? AppColors.primary
                          : AppColors.textSecondary.withOpacity(0.2),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildServiceStep();
      case 1:
        return _buildDateTimeStep();
      case 2:
        return _buildPetSelectionStep();
      case 3:
        return _buildDetailsStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildServiceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a Service',
          style: AppTextStyles.titleLarge,
        ),
        SizedBox(height: 8.h),
        Text(
          'Choose the type of care you need',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 24.h),
        ...widget.services.map((service) => _buildServiceCard(service)),
      ],
    );
  }

  Widget _buildServiceCard(CaregiverService service) {
    final isSelected = _selectedService?.id == service.id;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedService = service),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: service.id,
              groupValue: _selectedService?.id,
              onChanged: (_) => setState(() => _selectedService = service),
              activeColor: AppColors.primary,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.serviceTypeDisplayName ?? service.serviceTypeName ?? 'Pet Care Service',
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (service.description != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      service.description!,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                  SizedBox(height: 4.h),
                  Text(
                    '${service.durationMinutes ?? 60} mins • Max ${widget.caregiver.maxPetsAtOnce} pets',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${service.currency} ${service.rateAmount.toStringAsFixed(0)}',
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
                ),
                if (service.additionalPetRate > 0)
                  Text(
                    '+${service.additionalPetRate.toStringAsFixed(0)}/pet',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date & Time',
          style: AppTextStyles.titleLarge,
        ),
        SizedBox(height: 8.h),
        Text(
          'When do you need the service?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 24.h),
        _buildDateSelector(),
        SizedBox(height: 16.h),
        _buildTimeSelectors(),
        SizedBox(height: 16.h),
        _buildAvailabilityHint(),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Date', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.primary, size: 20.w),
                  SizedBox(width: 12.w),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelectors() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Time', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(true),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        Text('Start', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                        SizedBox(height: 4.h),
                        Text(
                          _formatTime(_startTime),
                          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Icon(Icons.arrow_forward, color: AppColors.textSecondary),
              SizedBox(width: 16.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(false),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        Text('End', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                        SizedBox(height: 4.h),
                        Text(
                          _formatTime(_endTime),
                          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityHint() {
    final dayOfWeek = _selectedDate.weekday - 1; // 0 = Monday
    final dayAvailability = widget.availability.where(
      (a) => a.dayOfWeek == dayOfWeek && a.isAvailable,
    ).toList();

    if (dayAvailability.isEmpty) {
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 20.w),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Caregiver may not be available on this day',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.orange[800]),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Caregiver is available on this day',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.green[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Pets',
          style: AppTextStyles.titleLarge,
        ),
        SizedBox(height: 8.h),
        Text(
          'Which pets need care?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 24.h),
        ..._userPets.map((pet) => _buildPetCard(pet)),
        if (_userPets.isEmpty)
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Icon(Icons.pets, size: 48.w, color: AppColors.textSecondary),
                SizedBox(height: 12.h),
                Text(
                  'No pets found',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Add your pets first to book a service',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPetCard(Map<String, String> pet) {
    final isSelected = _selectedPetIds.contains(pet['id']);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedPetIds.remove(pet['id']);
          } else {
            if (_selectedService != null && 
                _selectedPetIds.length < widget.caregiver.maxPetsAtOnce) {
              _selectedPetIds.add(pet['id']!);
            } else if (_selectedService == null) {
              _selectedPetIds.add(pet['id']!);
            }
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) {
                setState(() {
                  if (isSelected) {
                    _selectedPetIds.remove(pet['id']);
                  } else {
                    if (_selectedService != null && 
                        _selectedPetIds.length < widget.caregiver.maxPetsAtOnce) {
                      _selectedPetIds.add(pet['id']!);
                    }
                  }
                });
              },
              activeColor: AppColors.primary,
            ),
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: 24.r,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                pet['type'] == 'Dog' ? '🐕' : '🐈',
                style: TextStyle(fontSize: 24.sp),
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet['name']!,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  pet['type']!,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Details',
          style: AppTextStyles.titleLarge,
        ),
        SizedBox(height: 8.h),
        Text(
          'Final details for your booking',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 24.h),
        _buildLocationSelector(),
        SizedBox(height: 16.h),
        _buildInstructionsField(),
        SizedBox(height: 24.h),
        _buildPriceSummary(),
      ],
    );
  }

  Widget _buildLocationSelector() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Location',
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _locationType = 'owner_home'),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: _locationType == 'owner_home'
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: _locationType == 'owner_home'
                            ? AppColors.primary
                            : AppColors.textSecondary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.home,
                          color: _locationType == 'owner_home'
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'My Home',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _locationType == 'owner_home'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _locationType = 'caregiver_home'),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: _locationType == 'caregiver_home'
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: _locationType == 'caregiver_home'
                            ? AppColors.primary
                            : AppColors.textSecondary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_pin_circle,
                          color: _locationType == 'caregiver_home'
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Caregiver's",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _locationType == 'caregiver_home'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_locationType == 'owner_home') ...[
            SizedBox(height: 12.h),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Enter your address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.all(12.w),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructionsField() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Special Instructions',
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _instructionsController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Any special instructions for the caregiver...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.all(12.w),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    final basePrice = _selectedService?.rateAmount ?? 0.0;
    final additionalPetsCount = _selectedPetIds.length > 1 ? _selectedPetIds.length - 1 : 0;
    final additionalPetsFee = (additionalPetsCount * (_selectedService?.additionalPetRate ?? 0.0)).toDouble();
    final serviceFee = (basePrice + additionalPetsFee) * 0.1; // 10% service fee
    final total = basePrice + additionalPetsFee + serviceFee;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Summary',
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          _buildPriceRow('Base Price', basePrice),
          if (additionalPetsFee > 0)
            _buildPriceRow('Additional Pets ($additionalPetsCount)', additionalPetsFee),
          _buildPriceRow('Service Fee', serviceFee),
          Divider(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                'PKR ${total.toStringAsFixed(0)}',
                style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text('PKR ${amount.toStringAsFixed(0)}', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep--),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) SizedBox(width: 16.w),
            Expanded(
              flex: _currentStep > 0 ? 2 : 1,
              child: ElevatedButton(
                onPressed: _canProceed() ? _handleNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        _currentStep < 3 ? 'Continue' : 'Confirm Booking',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedService != null;
      case 1:
        return true;
      case 2:
        return _selectedPetIds.isNotEmpty;
      case 3:
        return _locationType == 'caregiver_home' || _addressController.text.isNotEmpty;
      default:
        return false;
    }
  }

  void _handleNext() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _submitBooking();
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    
    if (time != null) {
      setState(() {
        if (isStart) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _submitBooking() async {
    setState(() => _isSubmitting = true);

    try {
      final startDatetime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDatetime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      final request = CreateBookingRequest(
        caregiverId: widget.caregiver.id,
        serviceId: _selectedService!.id,
        petIds: _selectedPetIds,
        startDatetime: startDatetime.toIso8601String(),
        endDatetime: endDatetime.toIso8601String(),
        serviceLocationType: _locationType,
        serviceAddress: _locationType == 'owner_home' ? _addressController.text : null,
        specialInstructions: _instructionsController.text.isNotEmpty 
            ? _instructionsController.text 
            : null,
      );

      final booking = await _repository.createBooking(request);

      setState(() => _isSubmitting = false);

      if (mounted) {
        CustomSnackbar.showSuccess(
          context,
          'Booking created successfully!',
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BookingDetailScreen(
              bookingId: booking.id,
              isCaregiver: false,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        CustomSnackbar.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }
}
