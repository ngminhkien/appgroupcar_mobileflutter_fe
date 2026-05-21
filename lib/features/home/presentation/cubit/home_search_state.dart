import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../../../location/domain/entities/location_search_item.dart';
import '../../domain/entities/home_recent_search.dart';
import '../../domain/entities/trip_service.dart';

enum HomeSearchStatus { initial, loading, ready, invalid }

const Object _unset = Object();

class HomeSearchState extends Equatable {
  const HomeSearchState({
    this.status = HomeSearchStatus.initial,
    this.selectedServices = const [],
    this.pickupLocation,
    this.dropoffLocation,
    this.departureDate,
    this.departureTime,
    this.enableNearbySearch = true,
    this.expandPickupLocation = true,
    this.expandDropoffLocation = false,
    this.recentSearches = const [],
    this.validationMessage,
  });

  final HomeSearchStatus status;
  final List<TripService> selectedServices;
  final LocationSearchItem? pickupLocation;
  final LocationSearchItem? dropoffLocation;
  final DateTime? departureDate;
  final TimeOfDay? departureTime;
  final bool enableNearbySearch;
  final bool expandPickupLocation;
  final bool expandDropoffLocation;
  final List<HomeRecentSearch> recentSearches;
  final String? validationMessage;

  bool get hasSelectedService => selectedServices.isNotEmpty;
  bool get hasLocations => pickupLocation != null && dropoffLocation != null;

  bool get hasValidDepartureDate {
    if (departureDate == null) {
      return false;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      departureDate!.year,
      departureDate!.month,
      departureDate!.day,
    );
    return !selected.isBefore(today);
  }

  bool get canSearch =>
      hasSelectedService && hasLocations && hasValidDepartureDate;

  String? get departureTimeText {
    final value = departureTime;
    if (value == null) {
      return null;
    }
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  HomeSearchState copyWith({
    HomeSearchStatus? status,
    List<TripService>? selectedServices,
    Object? pickupLocation = _unset,
    Object? dropoffLocation = _unset,
    Object? departureDate = _unset,
    Object? departureTime = _unset,
    bool? enableNearbySearch,
    bool? expandPickupLocation,
    bool? expandDropoffLocation,
    List<HomeRecentSearch>? recentSearches,
    String? validationMessage,
  }) {
    return HomeSearchState(
      status: status ?? this.status,
      selectedServices: selectedServices ?? this.selectedServices,
      pickupLocation: pickupLocation == _unset
          ? this.pickupLocation
          : pickupLocation as LocationSearchItem?,
      dropoffLocation: dropoffLocation == _unset
          ? this.dropoffLocation
          : dropoffLocation as LocationSearchItem?,
      departureDate: departureDate == _unset
          ? this.departureDate
          : departureDate as DateTime?,
      departureTime: departureTime == _unset
          ? this.departureTime
          : departureTime as TimeOfDay?,
      enableNearbySearch: enableNearbySearch ?? this.enableNearbySearch,
      expandPickupLocation: expandPickupLocation ?? this.expandPickupLocation,
      expandDropoffLocation:
          expandDropoffLocation ?? this.expandDropoffLocation,
      recentSearches: recentSearches ?? this.recentSearches,
      validationMessage: validationMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedServices,
    pickupLocation,
    dropoffLocation,
    departureDate,
    departureTime,
    enableNearbySearch,
    expandPickupLocation,
    expandDropoffLocation,
    recentSearches,
    validationMessage,
  ];
}
