import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../location/domain/entities/location_search_item.dart';
import '../../domain/entities/home_recent_search.dart';
import '../../domain/entities/trip_service.dart';

class HomeSearchLocalDataSource {
  HomeSearchLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const String _lastServicesKey = 'home_last_services';
  static const String _lastDepartureDateKey = 'home_last_departure_date';
  static const String _lastDepartureTimeKey = 'home_last_departure_time';
  // Legacy key from old implementation.
  static const String _legacyLastDepartureFromKey = 'home_last_departure_from';
  static const String _enableNearbySearchKey = 'home_last_enable_nearby';
  static const String _expandPickupKey = 'home_last_expand_pickup';
  static const String _expandDropoffKey = 'home_last_expand_dropoff';
  static const String _lastPickupLocationKey = 'home_last_pickup_location';
  static const String _lastDropoffLocationKey = 'home_last_dropoff_location';
  static const String _recentSearchesKey = 'home_recent_searches';

  Future<void> saveLastServices(List<TripService> services) async {
    final values = services.map((service) => service.apiValue).toList();
    await _prefs.setStringList(_lastServicesKey, values);
  }

  List<TripService> getLastServices() {
    final raw = _prefs.getStringList(_lastServicesKey) ?? <String>[];
    return raw.map(TripServiceX.fromApiValue).whereType<TripService>().toList();
  }

  Future<void> saveLastDepartureDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    await _prefs.setString(_lastDepartureDateKey, normalized.toIso8601String());
  }

  DateTime? getLastDepartureDate() {
    final text = _prefs.getString(_lastDepartureDateKey);
    if (text == null || text.isEmpty) {
      return _readLegacyDepartureDate();
    }
    final parsed = DateTime.tryParse(text);
    if (parsed == null) {
      return null;
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  Future<void> saveLastDepartureTime(String? timeText) async {
    if (timeText == null || timeText.trim().isEmpty) {
      await _prefs.remove(_lastDepartureTimeKey);
      return;
    }
    await _prefs.setString(_lastDepartureTimeKey, timeText.trim());
  }

  String? getLastDepartureTime() {
    final text = _prefs.getString(_lastDepartureTimeKey);
    if (text == null || text.trim().isEmpty) {
      return null;
    }
    return text.trim();
  }

  Future<void> saveNearbyFlags({
    required bool enableNearbySearch,
    required bool expandPickupLocation,
    required bool expandDropoffLocation,
  }) async {
    await _prefs.setBool(_enableNearbySearchKey, enableNearbySearch);
    await _prefs.setBool(_expandPickupKey, expandPickupLocation);
    await _prefs.setBool(_expandDropoffKey, expandDropoffLocation);
  }

  NearbyFlags getNearbyFlags() {
    return NearbyFlags(
      enableNearbySearch: _prefs.getBool(_enableNearbySearchKey) ?? true,
      expandPickupLocation: _prefs.getBool(_expandPickupKey) ?? true,
      expandDropoffLocation: _prefs.getBool(_expandDropoffKey) ?? false,
    );
  }

  Future<void> saveLastPickupLocation(LocationSearchItem? item) async {
    await _saveLocation(_lastPickupLocationKey, item);
  }

  Future<void> saveLastDropoffLocation(LocationSearchItem? item) async {
    await _saveLocation(_lastDropoffLocationKey, item);
  }

  LocationSearchItem? getLastPickupLocation() {
    return _readLocation(_lastPickupLocationKey);
  }

  LocationSearchItem? getLastDropoffLocation() {
    return _readLocation(_lastDropoffLocationKey);
  }

  List<HomeRecentSearch> getRecentSearches() {
    final rawItems = _prefs.getStringList(_recentSearchesKey) ?? <String>[];
    final results = <HomeRecentSearch>[];
    for (final value in rawItems) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) {
          results.add(HomeRecentSearch.fromJson(decoded));
        }
      } catch (_) {
        // Ignore malformed cached values.
      }
    }
    return results;
  }

  Future<void> saveRecentSearch({
    required LocationSearchItem pickup,
    required LocationSearchItem dropoff,
  }) async {
    final current = getRecentSearches();
    final updated = <HomeRecentSearch>[
      HomeRecentSearch(
        pickupLocationId: pickup.id,
        pickupDisplayName: pickup.displayName,
        dropoffLocationId: dropoff.id,
        dropoffDisplayName: dropoff.displayName,
        createdAt: DateTime.now(),
      ),
      ...current.where(
        (item) =>
            item.pickupLocationId != pickup.id ||
            item.dropoffLocationId != dropoff.id,
      ),
    ];

    final values = updated
        .take(8)
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await _prefs.setStringList(_recentSearchesKey, values);
  }

  Future<void> _saveLocation(String key, LocationSearchItem? item) async {
    if (item == null) {
      await _prefs.remove(key);
      return;
    }
    await _prefs.setString(key, jsonEncode(item.toJson()));
  }

  LocationSearchItem? _readLocation(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return LocationSearchItem.fromJson(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  DateTime? _readLegacyDepartureDate() {
    final legacyText = _prefs.getString(_legacyLastDepartureFromKey);
    if (legacyText == null || legacyText.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(legacyText);
    if (parsed == null) {
      return null;
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
}

class NearbyFlags {
  const NearbyFlags({
    required this.enableNearbySearch,
    required this.expandPickupLocation,
    required this.expandDropoffLocation,
  });

  final bool enableNearbySearch;
  final bool expandPickupLocation;
  final bool expandDropoffLocation;
}
