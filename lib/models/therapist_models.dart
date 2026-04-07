/// Backend roles (JWT claims / user profile). Documented for server parity.
enum UserRole {
  student,
  therapist,
  admin,
}

/// Assignment lifecycle between student and therapist.
enum TherapistAssignmentStatus {
  none,
  pending,
  assigned,
  closed,
}

extension TherapistAssignmentStatusX on TherapistAssignmentStatus {
  static TherapistAssignmentStatus fromApi(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'pending':
        return TherapistAssignmentStatus.pending;
      case 'assigned':
        return TherapistAssignmentStatus.assigned;
      case 'closed':
        return TherapistAssignmentStatus.closed;
      case 'none':
      default:
        return TherapistAssignmentStatus.none;
    }
  }
}

/// Minimal therapist info safe to show a student after assignment.
class TherapistSummary {
  const TherapistSummary({required this.id, this.name});

  final String id;
  final String? name;

  factory TherapistSummary.fromJson(Map<String, dynamic> json) {
    return TherapistSummary(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] as String? ?? json['fullName'] as String?,
    );
  }
}

/// GET /therapist/status
class TherapistConnectionState {
  TherapistConnectionState({
    required this.status,
    this.therapist,
  });

  final TherapistAssignmentStatus status;
  final TherapistSummary? therapist;

  bool get canUseTherapistChat =>
      status == TherapistAssignmentStatus.assigned && therapist != null && therapist!.id.isNotEmpty;

  factory TherapistConnectionState.fromJson(Map<String, dynamic> json) {
    final statusRaw = json['status'] as String?;
    final t = json['therapist'];
    return TherapistConnectionState(
      status: TherapistAssignmentStatusX.fromApi(statusRaw),
      therapist: t is Map<String, dynamic> ? TherapistSummary.fromJson(t) : null,
    );
  }
}

/// Optimistic send lifecycle for the student app (server messages use [sent]).
enum TherapistMessageDelivery {
  sent,
  pending,
  failed,
}

/// Human therapist ↔ student message (separate from AI chat).
class TherapistThreadMessage {
  TherapistThreadMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.isFromStudent,
    this.delivery = TherapistMessageDelivery.sent,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isFromStudent;
  final TherapistMessageDelivery delivery;

  bool get isOptimistic => delivery != TherapistMessageDelivery.sent;

  factory TherapistThreadMessage.fromJson(Map<String, dynamic> json, {required String currentUserId}) {
    final sid = (json['senderId'] ?? json['sender_id'] ?? '').toString();
    final rid = (json['receiverId'] ?? json['receiver_id'] ?? '').toString();
    final ts = json['timestamp'] ?? json['createdAt'] ?? json['created_at'];
    return TherapistThreadMessage(
      id: (json['id'] ?? json['_id'] ?? ts?.toString() ?? '').toString(),
      senderId: sid,
      receiverId: rid,
      message: (json['message'] ?? json['text'] ?? json['body'] ?? '').toString(),
      timestamp: ts is String
          ? (DateTime.tryParse(ts) ?? DateTime.now())
          : DateTime.now(),
      isFromStudent: sid == currentUserId,
      delivery: TherapistMessageDelivery.sent,
    );
  }

  factory TherapistThreadMessage.optimistic({
    required String id,
    required String text,
    required String currentUserId,
    required TherapistMessageDelivery delivery,
  }) {
    return TherapistThreadMessage(
      id: id,
      senderId: currentUserId,
      receiverId: '',
      message: text,
      timestamp: DateTime.now(),
      isFromStudent: true,
      delivery: delivery,
    );
  }
}
