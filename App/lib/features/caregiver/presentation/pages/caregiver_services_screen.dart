import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/repositories/caregiver_repository.dart';
import '../../data/models/caregiver_models.dart';

class CaregiverServicesScreen extends StatefulWidget {
  const CaregiverServicesScreen({super.key});

  @override
  State<CaregiverServicesScreen> createState() => _CaregiverServicesScreenState();
}

class _CaregiverServicesScreenState extends State<CaregiverServicesScreen> {
  late CaregiverRepository _repository;
  List<CaregiverServiceType> _serviceTypes = [];
  List<CaregiverService> _myServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = getIt<CaregiverRepository>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final types = await _repository.getServiceTypes();
      final profileData = await _repository.getMyProfile();
      
      setState(() {
        _serviceTypes = types;
        // Extract services from profile if available
        _myServices = profileData.profile.services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        CustomSnackbar.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Services',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  Text(
                    'Active Services',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 12.h),
                  if (_myServices.isEmpty)
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.add_circle_outline, size: 48.w, color: AppColors.textSecondary),
                          SizedBox(height: 12.h),
                          Text(
                            'No services added yet',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                          Text(
                            'Add services below to start receiving bookings',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  else
                    ...(_myServices.map((service) => _buildServiceCard(service))),
                  
                  SizedBox(height: 24.h),
                  Text(
                    'Add New Service',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 12.h),
                  ..._serviceTypes.where((type) {
                    return !_myServices.any((s) => s.serviceTypeId == type.id);
                  }).map((type) => _buildServiceTypeCard(type)),
                ],
              ),
            ),
    );
  }

  Widget _buildServiceCard(CaregiverService service) {
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
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    _getServiceIcon(service.serviceTypeIcon),
                    color: AppColors.primary,
                    size: 24.w,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.serviceTypeDisplayName ?? service.serviceTypeName ?? 'Service',
                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${service.currency} ${service.rateAmount.toStringAsFixed(0)} / ${service.rateType}',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: service.isAvailable,
                  onChanged: (value) => _toggleServiceAvailability(service.id, value),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            if (service.description != null) ...[
              SizedBox(height: 12.h),
              Text(
                service.description!,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showEditServiceDialog(service),
                  child: Text('Edit', style: TextStyle(color: AppColors.primary)),
                ),
                TextButton(
                  onPressed: () => _deleteService(service.id),
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeCard(CaregiverServiceType type) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => _showAddServiceDialog(type),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getServiceIcon(type.iconName),
                  color: AppColors.textSecondary,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.displayName,
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      type.description ?? '',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.add_circle, color: AppColors.primary, size: 28.w),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon(String? iconName) {
    switch (iconName) {
      case 'directions_walk':
        return Icons.directions_walk;
      case 'house':
        return Icons.house;
      case 'hotel':
        return Icons.hotel;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'content_cut':
        return Icons.content_cut;
      case 'school':
        return Icons.school;
      case 'local_taxi':
        return Icons.local_taxi;
      case 'medical_services':
        return Icons.medical_services;
      default:
        return Icons.pets;
    }
  }

  Future<void> _showAddServiceDialog(CaregiverServiceType type) async {
    final rateController = TextEditingController();
    final descriptionController = TextEditingController();
    final durationController = TextEditingController();
    final additionalPetRateController = TextEditingController(text: '0');
    String rateType = 'hourly';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add ${type.displayName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: rateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Rate (PKR)',
                    hintText: 'e.g., 500',
                  ),
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<String>(
                  value: rateType,
                  decoration: const InputDecoration(labelText: 'Rate Type'),
                  items: const [
                    DropdownMenuItem(value: 'hourly', child: Text('Per Hour')),
                    DropdownMenuItem(value: 'daily', child: Text('Per Day')),
                    DropdownMenuItem(value: 'per_visit', child: Text('Per Visit')),
                    DropdownMenuItem(value: 'per_walk', child: Text('Per Walk')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => rateType = value!);
                  },
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                    hintText: 'e.g., 30',
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: additionalPetRateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Additional Pet Rate (PKR)',
                    hintText: 'Extra charge per additional pet',
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe what\'s included...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Add Service'),
            ),
          ],
        ),
      ),
    );

    if (result == true && rateController.text.isNotEmpty) {
      try {
        await _repository.addService(AddCaregiverServiceRequest(
          serviceTypeId: type.id,
          rateType: rateType,
          rateAmount: double.parse(rateController.text),
          durationMinutes: durationController.text.isNotEmpty
              ? int.parse(durationController.text)
              : null,
          additionalPetRate: additionalPetRateController.text.isNotEmpty
              ? double.parse(additionalPetRateController.text)
              : null,
          description: descriptionController.text.isNotEmpty
              ? descriptionController.text
              : null,
        ));
        if (mounted) {
          CustomSnackbar.showSuccess(
            context,
            'Service added successfully!',
          );
        }
        _loadData();
      } catch (e) {
        if (mounted) {
          CustomSnackbar.showError(
            context,
            e.toString().replaceFirst('Exception: ', ''),
          );
        }
      }
    }
  }

  Future<void> _showEditServiceDialog(CaregiverService service) async {
    final rateController = TextEditingController(text: service.rateAmount.toString());
    final descriptionController = TextEditingController(text: service.description ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${service.serviceTypeDisplayName ?? "Service"}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: rateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Rate (PKR)',
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _repository.updateService(service.id, {
          'rateAmount': double.parse(rateController.text),
          'description': descriptionController.text,
        });
        if (mounted) {
          CustomSnackbar.showSuccess(
            context,
            'Service updated!',
          );
        }
        _loadData();
      } catch (e) {
        if (mounted) {
          CustomSnackbar.showError(
            context,
            e.toString().replaceFirst('Exception: ', ''),
          );
        }
      }
    }
  }

  Future<void> _toggleServiceAvailability(String serviceId, bool available) async {
    try {
      await _repository.updateService(serviceId, {'isAvailable': available});
      _loadData();
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  Future<void> _deleteService(String serviceId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _repository.deleteService(serviceId);
        if (mounted) {
          CustomSnackbar.showSuccess(
            context,
            'Service deleted',
          );
        }
        _loadData();
      } catch (e) {
        if (mounted) {
          CustomSnackbar.showError(
            context,
            e.toString().replaceFirst('Exception: ', ''),
          );
        }
      }
    }
  }
}
