import '../../domain/entities/trip_search_request.dart';

class TripSearchScreenArgs {
  const TripSearchScreenArgs({
    required this.request,
    required this.pickupDisplayName,
    required this.dropoffDisplayName,
  });

  final TripSearchRequest request;
  final String pickupDisplayName;
  final String dropoffDisplayName;
}
