class LocationSearchScreenArgs {
  const LocationSearchScreenArgs({
    this.title = 'Tim dia diem',
    this.hintText = 'Tim dia diem...',
    this.initialQuery,
    this.availableForRoute = false,
  });

  final String title;
  final String hintText;
  final String? initialQuery;
  final bool availableForRoute;
}
