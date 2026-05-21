import 'package:equatable/equatable.dart';

class PagedResult<T> extends Equatable {
  const PagedResult({
    this.items = const [],
    this.totalCount = 0,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.totalPages = 0,
    this.hasPreviousPage = false,
    this.hasNextPage = false,
  });

  final List<T> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemParser,
  ) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems.whereType<Map<String, dynamic>>().map(itemParser).toList()
        : <T>[];
    return PagedResult<T>(
      items: items,
      totalCount: _readInt(json['totalCount']),
      pageNumber: _readInt(json['pageNumber'], fallback: 1),
      pageSize: _readInt(json['pageSize'], fallback: 10),
      totalPages: _readInt(json['totalPages']),
      hasPreviousPage: _readBool(json['hasPreviousPage']),
      hasNextPage: _readBool(json['hasNextPage']),
    );
  }

  static int _readInt(Object? value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static bool _readBool(Object? value, {bool fallback = false}) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return fallback;
  }

  @override
  List<Object?> get props => [
    items,
    totalCount,
    pageNumber,
    pageSize,
    totalPages,
    hasPreviousPage,
    hasNextPage,
  ];
}
