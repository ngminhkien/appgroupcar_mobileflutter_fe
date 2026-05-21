class TripDetailNavigationArgs {
  const TripDetailNavigationArgs({
    required this.tripId,
    required this.serviceCode,
    required this.detailApi,
  });

  final String tripId;
  final String serviceCode;
  final String detailApi;
}
