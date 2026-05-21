import 'trip_service.dart';

class TripSearchRequest {
  const TripSearchRequest({
    required this.services,
    required this.pickupLocationId,
    required this.dropoffLocationId,
    required this.departureDate,
    this.departureTime,
    this.enableNearbySearch = true,
    this.expandPickupLocation = true,
    this.expandDropoffLocation = false,
    this.pageNumber = 1,
    this.pageSize = 10,
  });

  final List<TripService> services;
  final String pickupLocationId;
  final String dropoffLocationId;
  final DateTime departureDate;
  final String? departureTime;
  final bool enableNearbySearch;
  final bool expandPickupLocation;
  final bool expandDropoffLocation;
  final int pageNumber;
  final int pageSize;

  TripSearchRequest copyWith({
    List<TripService>? services,
    String? pickupLocationId,
    String? dropoffLocationId,
    DateTime? departureDate,
    String? departureTime,
    bool? enableNearbySearch,
    bool? expandPickupLocation,
    bool? expandDropoffLocation,
    int? pageNumber,
    int? pageSize,
  }) {
    return TripSearchRequest(
      services: services ?? this.services,
      pickupLocationId: pickupLocationId ?? this.pickupLocationId,
      dropoffLocationId: dropoffLocationId ?? this.dropoffLocationId,
      departureDate: departureDate ?? this.departureDate,
      departureTime: departureTime ?? this.departureTime,
      enableNearbySearch: enableNearbySearch ?? this.enableNearbySearch,
      expandPickupLocation: expandPickupLocation ?? this.expandPickupLocation,
      expandDropoffLocation:
          expandDropoffLocation ?? this.expandDropoffLocation,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    final serviceNames = services.map((service) => service.apiValue).toList();
    final hasBus = services.contains(TripService.bus);
    final hasSharedRide = services.contains(TripService.sharedRide);
    final hasTruck = services.contains(TripService.truck);
    final normalizedDate = DateTime(
      departureDate.year,
      departureDate.month,
      departureDate.day,
    );
    final normalizedTime = departureTime?.trim();
    final hasTime = normalizedTime != null && normalizedTime.isNotEmpty;

    return {
      'services': serviceNames,
      'pickupLocationId': pickupLocationId,
      'dropoffLocationId': dropoffLocationId,
      // New contract: backend supports split date/time.
      'departureDate': _formatDateOnly(normalizedDate),
      if (hasTime) 'departureTime': normalizedTime,
      // Keep backward compatibility for old contract expecting departureFrom.
      if (hasTime)
        'departureFrom': _composeDepartureFrom(
          normalizedDate: normalizedDate,
          departureTime: normalizedTime,
        ),
      'enableNearbySearch': enableNearbySearch,
      'expandPickupLocation': expandPickupLocation,
      'expandDropoffLocation': expandDropoffLocation,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      // Backward compatibility with old query contract.
      'includeBus': hasBus,
      'includeSharedRide': hasSharedRide,
      'includeTruck': hasTruck,
    };
  }

  static String _formatDateOnly(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String _composeDepartureFrom({
    required DateTime normalizedDate,
    required String? departureTime,
  }) {
    final parts = (departureTime ?? '').split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final dateTime = DateTime(
      normalizedDate.year,
      normalizedDate.month,
      normalizedDate.day,
      hour,
      minute,
    );
    return dateTime.toIso8601String();
  }
}
