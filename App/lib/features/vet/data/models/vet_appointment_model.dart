class VetAppointment {
  final String id;
  final String appointmentNumber;
  final String petOwnerId;
  final String vetUserId;
  final String petId;
  final String? petName;
  final String? petType;
  final String reason;
  final String? symptoms;
  final String? ownerNotes;
  final DateTime appointmentDatetime;
  final int durationMinutes;
  final String meetingType;
  final String? clinicAddress;
  final String? meetingLink;
  final double feeAmount;
  final String currency;
  final String status;
  final String? responseNote;
  final DateTime? respondedAt;
  final DateTime? cancelledAt;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? ownerName;
  final String? ownerAvatar;
  final String? vetName;
  final String? vetAvatar;

  const VetAppointment({
    required this.id,
    required this.appointmentNumber,
    required this.petOwnerId,
    required this.vetUserId,
    required this.petId,
    required this.reason,
    required this.appointmentDatetime,
    required this.durationMinutes,
    required this.meetingType,
    required this.feeAmount,
    required this.currency,
    required this.status,
    this.petName,
    this.petType,
    this.symptoms,
    this.ownerNotes,
    this.clinicAddress,
    this.meetingLink,
    this.responseNote,
    this.respondedAt,
    this.cancelledAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.ownerName,
    this.ownerAvatar,
    this.vetName,
    this.vetAvatar,
  });

  factory VetAppointment.fromJson(Map<String, dynamic> json) {
    return VetAppointment(
      id: json['id'] as String,
      appointmentNumber: json['appointmentNumber'] as String? ?? '',
      petOwnerId: json['petOwnerId'] as String,
      vetUserId: json['vetUserId'] as String,
      petId: json['petId'] as String,
      petName: json['petName'] as String?,
      petType: json['petType'] as String?,
      reason: json['reason'] as String? ?? '',
      symptoms: json['symptoms'] as String?,
      ownerNotes: json['ownerNotes'] as String?,
      appointmentDatetime: DateTime.parse(
        json['appointmentDatetime'] as String,
      ),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 30,
      meetingType: json['meetingType'] as String? ?? 'in_person',
      clinicAddress: json['clinicAddress'] as String?,
      meetingLink: json['meetingLink'] as String?,
      feeAmount: (json['feeAmount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'PKR',
      status: json['status'] as String? ?? 'requested',
      responseNote: json['responseNote'] as String?,
      respondedAt:
          json['respondedAt'] != null
              ? DateTime.tryParse(json['respondedAt'] as String)
              : null,
      cancelledAt:
          json['cancelledAt'] != null
              ? DateTime.tryParse(json['cancelledAt'] as String)
              : null,
      completedAt:
          json['completedAt'] != null
              ? DateTime.tryParse(json['completedAt'] as String)
              : null,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'] as String)
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'] as String)
              : null,
      ownerName: json['ownerName'] as String?,
      ownerAvatar: json['ownerAvatar'] as String?,
      vetName: json['vetName'] as String?,
      vetAvatar: json['vetAvatar'] as String?,
    );
  }
}

class CreateVetAppointmentRequest {
  final String vetUserId;
  final String petId;
  final DateTime appointmentDatetime;
  final int durationMinutes;
  final String meetingType;
  final String reason;
  final String? symptoms;
  final String? ownerNotes;
  final String? clinicAddress;

  const CreateVetAppointmentRequest({
    required this.vetUserId,
    required this.petId,
    required this.appointmentDatetime,
    required this.reason,
    this.durationMinutes = 30,
    this.meetingType = 'in_person',
    this.symptoms,
    this.ownerNotes,
    this.clinicAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'vetUserId': vetUserId,
      'petId': petId,
      'appointmentDatetime': appointmentDatetime.toUtc().toIso8601String(),
      'durationMinutes': durationMinutes,
      'meetingType': meetingType,
      'reason': reason,
      if (symptoms != null && symptoms!.trim().isNotEmpty) 'symptoms': symptoms,
      if (ownerNotes != null && ownerNotes!.trim().isNotEmpty)
        'ownerNotes': ownerNotes,
      if (clinicAddress != null && clinicAddress!.trim().isNotEmpty)
        'clinicAddress': clinicAddress,
    };
  }
}
