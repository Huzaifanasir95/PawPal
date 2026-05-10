import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/di/service_locator.dart';
import '../../../pets/data/models/pet_model.dart';
import '../../../pets/data/repositories/pet_repository_api.dart';
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
  final PetRepositoryApi _petRepository = getIt<PetRepositoryApi>();
  List<PetModel> _userPets = [];
  bool _isLoadingPets = false;

  // Step 4: Additional Details
  String _locationType = 'owner_home';
  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _repository = getIt<BookingRepository>();
    _loadUserPets();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Book ${widget.caregiver.userName ?? "Caregiver"}',
          style: AppTextStyles.titleLarge.copyWith(color: theme.colorScheme.onSurface),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
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
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 16.w)
                        : Text(
                            '${index + 1}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isCurrent ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 2.h,
                      color: isCompleted
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6).withOpacity(0.2),
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
    final services = widget.services.where((service) => service.isAvailable).toList();

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
          style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
        SizedBox(height: 24.h),
        if (services.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6).withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Icon(Icons.schedule_outlined, size: 40.w, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                SizedBox(height: 10.h),
                Text(
                  'No bookable services available right now.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
              ],
            ),
          )
        else
          ...services.map((service) => _buildServiceCard(service)),
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: service.id,
              groupValue: _selectedService?.id,
              onChanged: (_) => setState(() => _selectedService = service),
              activeColor: Theme.of(context).colorScheme.primary,
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
                      style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ],
                  SizedBox(height: 4.h),
                  Text(
                    '${service.durationMinutes ?? 60} mins • Max ${widget.caregiver.maxPetsAtOnce} pets',
                    style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${service.currency} ${service.rateAmount.toStringAsFixed(0)}',
                  style: AppTextStyles.titleMedium.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                if (service.additionalPetRate > 0)
                  Text(
                    '+${service.additionalPetRate.toStringAsFixed(0)}/pet',
                    style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
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
          style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
        SizedBox(height: 24.h),
        _buildDateSelector(),
        SizedBox(height: 16.h),
        _buildTimeSelectors(),
        SizedBox(height: 16.h),
        _buildDateTimeValidationHint(),
        SizedBox(height: 12.h),
        _buildAvailabilityHint(),
      ],
    );
  }

  Widget _buildDateTimeValidationHint() {
    final start = _buildStartDateTime();
    final end = _buildEndDateTime();
    final nowCutoff = DateTime.now().add(const Duration(minutes: 5));

    String? message;
    Color tone = Colors.green;
    IconData icon = Icons.check_circle;

    if (!end.isAfter(start)) {
      message = 'End time must be after the start time.';
      tone = Colors.orange;
      icon = Icons.warning_amber_rounded;
    } else if (!start.isAfter(nowCutoff)) {
      message = 'Start time should be at least 5 minutes in the future.';
      tone = Colors.orange;
      icon = Icons.schedule_rounded;
    } else {
      message = 'Selected time range is valid.';
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: tone, size: 20.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: tone.withValues(alpha: 0.92),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6).withOpacity(0.2)),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary, size: 20.w),
                  SizedBox(width: 12.w),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
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
        color: Theme.of(context).colorScheme.surface,
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
                      border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6).withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        Text('Start', style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
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
              Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              SizedBox(width: 16.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(false),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6).withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        Text('End', style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
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
          style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
        SizedBox(height: 24.h),
        if (_isLoadingPets)
          const Center(child: CircularProgressIndicator())
        else
          ..._userPets.map((pet) => _buildPetCard(pet)),
        if (_userPets.isEmpty)
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Icon(Icons.pets, size: 48.w, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                SizedBox(height: 12.h),
                Text(
                  _isLoadingPets ? 'Loading pets...' : 'No pets found',
                  style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Add your pets first to book a service',
                  style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPetCard(PetModel pet) {
    final isSelected = _selectedPetIds.contains(pet.id);
    final petTypeLabel =
        pet.type.isNotEmpty ? '${pet.type[0].toUpperCase()}${pet.type.substring(1)}' : 'Pet';
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedPetIds.remove(pet.id);
          } else {
            if (_selectedService != null && 
                _selectedPetIds.length < widget.caregiver.maxPetsAtOnce) {
              _selectedPetIds.add(pet.id);
            } else if (_selectedService == null) {
              _selectedPetIds.add(pet.id);
            }
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
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
                    _selectedPetIds.remove(pet.id);
                  } else {
                    if (_selectedService != null && 
                        _selectedPetIds.length < widget.caregiver.maxPetsAtOnce) {
                      _selectedPetIds.add(pet.id);
                    }
                  }
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: 24.r,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Text(
                pet.type.toLowerCase() == 'dog' ? '🐕' : '🐈',
                style: TextStyle(fontSize: 24.sp),
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  petTypeLabel,
                  style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
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
          style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
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
        color: Theme.of(context).colorScheme.surface,
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
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: _locationType == 'owner_home'
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.home,
                          color: _locationType == 'owner_home'
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'My Home',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _locationType == 'owner_home'
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: _locationType == 'caregiver_home'
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_pin_circle,
                          color: _locationType == 'caregiver_home'
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Caregiver's",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _locationType == 'caregiver_home'
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
        color: Theme.of(context).colorScheme.surface,
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
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                style: AppTextStyles.titleLarge.copyWith(color: Theme.of(context).colorScheme.primary),
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
        color: Theme.of(context).colorScheme.surface,
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
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
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
        return _hasValidDateTimeRange() && _isStartTimeInFuture();
      case 2:
        return _selectedPetIds.isNotEmpty;
      case 3:
        return _locationType == 'caregiver_home' ||
            _addressController.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  DateTime _buildStartDateTime() {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
  }

  DateTime _buildEndDateTime() {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );
  }

  bool _hasValidDateTimeRange() {
    return _buildEndDateTime().isAfter(_buildStartDateTime());
  }

  bool _isStartTimeInFuture() {
    return _buildStartDateTime().isAfter(
      DateTime.now().add(const Duration(minutes: 5)),
    );
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
    if (_selectedService == null) {
      CustomSnackbar.showError(context, 'Please select a service first');
      return;
    }

    if (_selectedPetIds.isEmpty) {
      CustomSnackbar.showError(context, 'Please select at least one pet');
      return;
    }

    if (_selectedPetIds.length > widget.caregiver.maxPetsAtOnce) {
      CustomSnackbar.showError(
        context,
        'You can select up to ${widget.caregiver.maxPetsAtOnce} pets for this service',
      );
      return;
    }

    if (!_hasValidDateTimeRange()) {
      CustomSnackbar.showError(
        context,
        'End time must be later than start time',
      );
      return;
    }

    if (!_isStartTimeInFuture()) {
      CustomSnackbar.showError(
        context,
        'Please choose a start time at least 5 minutes in the future',
      );
      return;
    }

    final trimmedAddress = _addressController.text.trim();
    if (_locationType == 'owner_home' && trimmedAddress.isEmpty) {
      CustomSnackbar.showError(
        context,
        'Please enter your service address',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final startDatetime = _buildStartDateTime();
      final endDatetime = _buildEndDateTime();
      final trimmedInstructions = _instructionsController.text.trim();

      final request = CreateBookingRequest(
        caregiverId: widget.caregiver.id,
        serviceId: _selectedService!.id,
        petIds: _selectedPetIds,
        startDatetime: startDatetime.toUtc().toIso8601String(),
        endDatetime: endDatetime.toUtc().toIso8601String(),
        serviceLocationType: _locationType,
        serviceAddress: _locationType == 'owner_home' ? trimmedAddress : null,
        specialInstructions:
            trimmedInstructions.isNotEmpty ? trimmedInstructions : null,
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

  Future<void> _loadUserPets() async {
    setState(() => _isLoadingPets = true);

    try {
      final pets = await _petRepository.getPets();
      if (!mounted) return;
      setState(() {
        _userPets = pets;
        _isLoadingPets = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingPets = false);
      CustomSnackbar.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

