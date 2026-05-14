import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../chat/data/repositories/chat_repository.dart';
import '../../../chat/presentation/pages/chat_conversation_screen.dart';
import '../../data/models/vet_appointment_model.dart';
import '../../data/repositories/vet_appointment_repository.dart';
import '../../data/repositories/vet_repository.dart';

class VetAppointmentsScreen extends StatefulWidget {
  final bool isVetView;

  const VetAppointmentsScreen({super.key, this.isVetView = false});

  @override
  State<VetAppointmentsScreen> createState() => _VetAppointmentsScreenState();
}

class _VetAppointmentsScreenState extends State<VetAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late final VetAppointmentRepository _repository;
  late final VetRepository _vetRepository;
  late final ChatRepository _chatRepository;
  late final TabController _tabController;

  List<VetAppointment> _requested = [];
  List<VetAppointment> _upcoming = [];
  List<VetAppointment> _history = [];
  bool _isLoading = true;
  String? _busyAppointmentId;

  @override
  void initState() {
    super.initState();
    _repository = VetAppointmentRepository();
    _vetRepository = VetRepository(ApiClient.instance);
    _chatRepository = getIt<ChatRepository>();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _role => widget.isVetView ? 'vet' : 'owner';

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _busyAppointmentId = null;
    });

    try {
      final responses = await Future.wait([
        _repository.getMyAppointments(role: _role, status: 'requested'),
        _repository.getMyAppointments(role: _role, status: 'confirmed'),
        _repository.getMyAppointments(
          role: _role,
          status: 'completed,declined,cancelled_owner,cancelled_vet',
        ),
      ]);

      if (!mounted) return;

      setState(() {
        _requested = responses[0].appointments;
        _upcoming = responses[1].appointments;
        _history = responses[2].appointments;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomSnackbar.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _respondToAppointment(
    VetAppointment appointment,
    bool accept,
  ) async {
    final noteController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(accept ? 'Accept Appointment' : 'Decline Appointment'),
            content: TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Note (${accept ? 'optional' : 'required'})',
                hintText:
                    accept
                        ? 'Add any pre-consultation note'
                        : 'Reason for decline',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (!accept && noteController.text.trim().isEmpty) {
                    return;
                  }
                  Navigator.of(context).pop(true);
                },
                child: Text(accept ? 'Accept' : 'Decline'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _busyAppointmentId = appointment.id);
    try {
      final note = noteController.text.trim();
      await _repository.respondAppointment(
        appointment.id,
        accept: accept,
        responseNote: note.isEmpty ? null : note,
      );

      if (mounted) {
        CustomSnackbar.showSuccess(
          context,
          accept ? 'Appointment accepted' : 'Appointment declined',
        );
      }
      await _loadAppointments();
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busyAppointmentId = null);
      }
    }
  }

  Future<void> _completeAppointment(VetAppointment appointment) async {
    final noteController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Complete Appointment'),
            content: TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Completion Note (optional)',
                hintText: 'Summary of consultation',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Complete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _busyAppointmentId = appointment.id);
    try {
      final note = noteController.text.trim();
      await _repository.completeAppointment(
        appointment.id,
        responseNote: note.isEmpty ? null : note,
      );

      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Appointment marked as completed');
      }
      await _loadAppointments();
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busyAppointmentId = null);
      }
    }
  }

  Future<void> _cancelAppointment(VetAppointment appointment) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Appointment'),
            content: TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Please share why you are cancelling',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep'),
              ),
              TextButton(
                onPressed: () {
                  if (reasonController.text.trim().isEmpty) {
                    return;
                  }
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'Cancel Appointment',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _busyAppointmentId = appointment.id);
    try {
      await _repository.cancelAppointment(
        appointment.id,
        reasonController.text.trim(),
      );

      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Appointment cancelled');
      }
      await _loadAppointments();
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busyAppointmentId = null);
      }
    }
  }

  Future<void> _openAppointmentChat(VetAppointment appointment) async {
    setState(() => _busyAppointmentId = appointment.id);
    try {
      final chat = await _chatRepository.startAppointmentChat(
        appointmentId: appointment.id,
      );

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => ChatConversationScreen(
                chatId: chat.id,
                otherUserName:
                    widget.isVetView
                        ? (appointment.ownerName ?? 'Pet Owner')
                        : (appointment.vetName ?? 'Veterinarian'),
              ),
        ),
      );
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busyAppointmentId = null);
      }
    }
  }

  Future<void> _showVetReviewDialog(VetAppointment appointment) async {
    if (widget.isVetView || appointment.status != 'completed') {
      return;
    }

    if (appointment.vetUserId.trim().isEmpty) {
      CustomSnackbar.showError(
        context,
        'Unable to submit review: missing vet reference.',
      );
      return;
    }

    int rating = 5;
    final commentController = TextEditingController();

    final submit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Rate Veterinarian'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.vetName ?? 'Veterinarian',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setDialogState(() => rating = index + 1);
                        },
                        icon: Icon(
                          index < rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 32.sp,
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Review',
                      hintText: 'Share your experience (optional)',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    if (submit != true) return;

    setState(() => _busyAppointmentId = appointment.id);
    try {
      await _vetRepository.addVetReview(
        appointment.vetUserId,
        rating: rating,
        comment: commentController.text.trim(),
      );

      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Review submitted successfully!');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busyAppointmentId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.isVetView ? 'Appointment Requests' : 'My Vet Appointments',
          style: AppTextStyles.titleLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          tabs: [
            Tab(text: 'Requested (${_requested.length})'),
            Tab(text: 'Upcoming (${_upcoming.length})'),
            Tab(text: 'History (${_history.length})'),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadAppointments,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAppointmentsList(
                      _requested,
                      emptyMessage: 'No requested appointments',
                    ),
                    _buildAppointmentsList(
                      _upcoming,
                      emptyMessage: 'No upcoming appointments',
                    ),
                    _buildAppointmentsList(
                      _history,
                      emptyMessage: 'No appointment history yet',
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildAppointmentsList(
    List<VetAppointment> items, {
    required String emptyMessage,
  }) {
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 120.h),
          Icon(
            Icons.event_available_outlined,
            size: 56.w,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          SizedBox(height: 12.h),
          Center(
            child: Text(
              emptyMessage,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildAppointmentCard(items[index]),
    );
  }

  Widget _buildAppointmentCard(VetAppointment appointment) {
    final colorScheme = Theme.of(context).colorScheme;
    final isBusy = _busyAppointmentId == appointment.id;
    final canChat = !_isClosedStatus(appointment.status);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appointment.appointmentNumber,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildStatusChip(appointment.status),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            appointment.reason,
            style: AppTextStyles.bodyLarge.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            widget.isVetView
                ? (appointment.ownerName ?? 'Pet Owner')
                : (appointment.vetName ?? 'Veterinarian'),
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16.w,
                color: colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 6.w),
              Text(
                _formatDateTime(appointment.appointmentDatetime),
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '${appointment.currency} ${appointment.feeAmount.toStringAsFixed(0)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (canChat)
            OutlinedButton.icon(
              onPressed:
                  isBusy ? null : () => _openAppointmentChat(appointment),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(color: colorScheme.primary),
              ),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Open Chat'),
            ),
          if (widget.isVetView && appointment.status == 'requested') ...[
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        isBusy
                            ? null
                            : () => _respondToAppointment(appointment, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        isBusy
                            ? null
                            : () => _respondToAppointment(appointment, true),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
          if (widget.isVetView && appointment.status == 'confirmed') ...[
            SizedBox(height: 10.h),
            ElevatedButton(
              onPressed:
                  isBusy ? null : () => _completeAppointment(appointment),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 44.h),
              ),
              child: const Text('Mark as Completed'),
            ),
          ],
          if (!widget.isVetView &&
              (appointment.status == 'requested' ||
                  appointment.status == 'confirmed')) ...[
            SizedBox(height: 10.h),
            OutlinedButton(
              onPressed: isBusy ? null : () => _cancelAppointment(appointment),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: Size(double.infinity, 44.h),
              ),
              child: const Text('Cancel Appointment'),
            ),
          ],
          if (!widget.isVetView && appointment.status == 'completed') ...[
            SizedBox(height: 10.h),
            ElevatedButton.icon(
              onPressed:
                  isBusy ? null : () => _showVetReviewDialog(appointment),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 44.h),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              icon: const Icon(Icons.star_rate_rounded),
              label: const Text('Leave Review'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  bool _isClosedStatus(String status) {
    return status == 'declined' ||
        status == 'cancelled_owner' ||
        status == 'cancelled_vet';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'requested':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'declined':
      case 'cancelled_owner':
      case 'cancelled_vet':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    }
  }

  String _formatDateTime(DateTime datetime) {
    final minutes = datetime.minute.toString().padLeft(2, '0');
    return '${datetime.day}/${datetime.month}/${datetime.year}  ${datetime.hour}:$minutes';
  }
}

