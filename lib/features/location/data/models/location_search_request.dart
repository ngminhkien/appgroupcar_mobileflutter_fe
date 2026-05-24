class LocationSearchRequest {
  const LocationSearchRequest({
    required this.query,
    this.isActive = true,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.availableForRoute = false,
  });

  final String query;
  final bool isActive;
  final int pageNumber;
  final int pageSize;
  final bool availableForRoute;

  Map<String, dynamic> toQueryParameters() {
    return {
      'query': query,
      'isActive': isActive,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };
  }

  LocationSearchRequest copyWith({
    String? query,
    bool? isActive,
    int? pageNumber,
    int? pageSize,
    bool? availableForRoute,
  }) {
    return LocationSearchRequest(
      query: query ?? this.query,
      isActive: isActive ?? this.isActive,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      availableForRoute: availableForRoute ?? this.availableForRoute,
    );
  }
}
