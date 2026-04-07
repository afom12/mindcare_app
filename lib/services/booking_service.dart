import '../models/therapist_listing.dart';
import 'api_client.dart';

class BookingService {
  BookingService(this._api);

  final ApiClient _api;

  Future<List<TherapistListing>> fetchTherapists() async {
    final res = await _api.getJson('/therapists', auth: true);
    dynamic raw = res['therapists'] ?? res['data'] ?? res['items'];
    if (raw is Map && raw['therapists'] is List) {
      raw = raw['therapists'];
    }
    if (raw is! List) {
      return [];
    }
    return raw
        .whereType<Map>()
        .map((e) => TherapistListing.fromJson(Map<String, dynamic>.from(e)))
        .where((t) => t.id.isNotEmpty)
        .toList();
  }

  Future<void> requestBooking({
    required String therapistId,
    String? note,
    String? preferredSlot,
  }) async {
    await _api.postJson(
      '/bookings',
      {
        'therapistId': therapistId,
        if (note != null && note.isNotEmpty) 'note': note,
        if (preferredSlot != null && preferredSlot.isNotEmpty) 'preferredSlot': preferredSlot,
      },
      auth: true,
    );
  }
}
