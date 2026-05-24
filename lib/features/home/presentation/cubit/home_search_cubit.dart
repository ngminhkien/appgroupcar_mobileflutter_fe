import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../location/domain/entities/location_search_item.dart';
import '../../data/datasources/home_search_local_data_source.dart';
import '../../domain/entities/home_recent_search.dart';
import '../../domain/entities/trip_search_request.dart';
import '../../domain/entities/trip_service.dart';
import 'home_search_state.dart';

class HomeSearchCubit extends Cubit<HomeSearchState> {
  HomeSearchCubit(this._localDataSource) : super(const HomeSearchState());

  final HomeSearchLocalDataSource _localDataSource;

  Future<void> loadInitialData() async {
    emit(
      state.copyWith(status: HomeSearchStatus.loading, validationMessage: null),
    );

    final services = _localDataSource.getLastServices();
    final nearbyFlags = _localDataSource.getNearbyFlags();
    final now = DateTime.now();
    final defaultDepartureDate = DateTime(now.year, now.month, now.day);
    final departureDate =
        _normalizeDepartureDate(
          _localDataSource.getLastDepartureDate() ?? defaultDepartureDate,
        ) ??
        defaultDepartureDate;
    final departureTime = _parseTimeOfDay(
      _localDataSource.getLastDepartureTime(),
    );

    emit(
      state.copyWith(
        status: HomeSearchStatus.ready,
        selectedServices: services.isEmpty
            ? const [TripService.bus, TripService.sharedRide, TripService.truck]
            : services,
        pickupLocation: _localDataSource.getLastPickupLocation(),
        dropoffLocation: _localDataSource.getLastDropoffLocation(),
        departureDate: departureDate,
        departureTime: departureTime,
        enableNearbySearch: nearbyFlags.enableNearbySearch,
        expandPickupLocation: nearbyFlags.expandPickupLocation,
        expandDropoffLocation: nearbyFlags.expandDropoffLocation,
        recentSearches: _localDataSource.getRecentSearches(),
        validationMessage: null,
      ),
    );
  }

  void toggleService(TripService service) {
    final updated = [...state.selectedServices];
    if (updated.contains(service)) {
      updated.remove(service);
    } else {
      updated.add(service);
    }
    emit(
      state.copyWith(
        status: HomeSearchStatus.ready,
        selectedServices: updated,
        validationMessage: null,
      ),
    );
    unawaited(_localDataSource.saveLastServices(updated));
  }

  void setPickupLocation(LocationSearchItem item) {
    emit(
      state.copyWith(
        status: HomeSearchStatus.ready,
        pickupLocation: item,
        validationMessage: null,
      ),
    );
    unawaited(_localDataSource.saveLastPickupLocation(item));
  }

  void setDropoffLocation(LocationSearchItem item) {
    emit(
      state.copyWith(
        status: HomeSearchStatus.ready,
        dropoffLocation: item,
        validationMessage: null,
      ),
    );
    unawaited(_localDataSource.saveLastDropoffLocation(item));
  }

  void swapPickupAndDropoff() {
    final pickup = state.pickupLocation;
    final dropoff = state.dropoffLocation;
    emit(
      state.copyWith(
        status: HomeSearchStatus.ready,
        pickupLocation: dropoff,
        dropoffLocation: pickup,
        validationMessage: null,
      ),
    );
    unawaited(_localDataSource.saveLastPickupLocation(dropoff));
    unawaited(_localDataSource.saveLastDropoffLocation(pickup));
  }

  void applyRecentSearch(HomeRecentSearch item) {
    final pickup = LocationSearchItem(
      id: item.pickupLocationId,
      code: '',
      name: item.pickupDisplayName,
      locationType: 99,
      locationTypeName: 'Other',
      locationTypeLabel: 'Other',
      displayName: item.pickupDisplayName,
    );
    final dropoff = LocationSearchItem(
      id: item.dropoffLocationId,
      code: '',
      name: item.dropoffDisplayName,
      locationType: 99,
      locationTypeName: 'Other',
      locationTypeLabel: 'Other',
      displayName: item.dropoffDisplayName,
    );

    emit(
      state.copyWith(
        status: HomeSearchStatus.ready,
        pickupLocation: pickup,
        dropoffLocation: dropoff,
        validationMessage: null,
      ),
    );
    unawaited(_localDataSource.saveLastPickupLocation(pickup));
    unawaited(_localDataSource.saveLastDropoffLocation(dropoff));
  }

  void setDepartureDate(DateTime value) {
    final normalized = _normalizeDepartureDate(value);
    if (normalized == null) {
      emit(
        state.copyWith(
          status: HomeSearchStatus.invalid,
          validationMessage: 'Ngay khoi hanh khong duoc nho hon hom nay',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: HomeSearchStatus.ready,
        departureDate: normalized,
        validationMessage: null,
      ),
    );
    unawaited(_localDataSource.saveLastDepartureDate(normalized));
  }

  void setDepartureTime(TimeOfDay? value) {
    emit(
      state.copyWith(
        status: HomeSearchStatus.ready,
        departureTime: value,
        validationMessage: null,
      ),
    );
    unawaited(_localDataSource.saveLastDepartureTime(_formatTimeOfDay(value)));
  }

  void clearDepartureTime() {
    setDepartureTime(null);
  }

  void setEnableNearbySearch(bool value) {
    final expandPickup = value ? state.expandPickupLocation : false;
    final expandDropoff = value ? state.expandDropoffLocation : false;
    emit(
      state.copyWith(
        status: HomeSearchStatus.ready,
        enableNearbySearch: value,
        expandPickupLocation: expandPickup,
        expandDropoffLocation: expandDropoff,
        validationMessage: null,
      ),
    );
    unawaited(
      _localDataSource.saveNearbyFlags(
        enableNearbySearch: value,
        expandPickupLocation: expandPickup,
        expandDropoffLocation: expandDropoff,
      ),
    );
  }

  void setExpandPickupLocation(bool value) {
    if (!state.enableNearbySearch) {
      return;
    }
    emit(
      state.copyWith(
        status: HomeSearchStatus.ready,
        expandPickupLocation: value,
        validationMessage: null,
      ),
    );
    unawaited(
      _localDataSource.saveNearbyFlags(
        enableNearbySearch: state.enableNearbySearch,
        expandPickupLocation: value,
        expandDropoffLocation: state.expandDropoffLocation,
      ),
    );
  }

  void setExpandDropoffLocation(bool value) {
    if (!state.enableNearbySearch) {
      return;
    }
    emit(
      state.copyWith(
        status: HomeSearchStatus.ready,
        expandDropoffLocation: value,
        validationMessage: null,
      ),
    );
    unawaited(
      _localDataSource.saveNearbyFlags(
        enableNearbySearch: state.enableNearbySearch,
        expandPickupLocation: state.expandPickupLocation,
        expandDropoffLocation: value,
      ),
    );
  }

  TripSearchRequest? buildSearchRequest() {
    final validationMessage = _validate();
    if (validationMessage != null) {
      emit(
        state.copyWith(
          status: HomeSearchStatus.invalid,
          validationMessage: validationMessage,
        ),
      );
      return null;
    }

    final request = TripSearchRequest(
      services: state.selectedServices,
      pickupLocationId: state.pickupLocation!.id,
      dropoffLocationId: state.dropoffLocation!.id,
      departureDate: state.departureDate!,
      departureTime: state.departureTimeText,
      enableNearbySearch: state.enableNearbySearch,
      expandPickupLocation: state.expandPickupLocation,
      expandDropoffLocation: state.expandDropoffLocation,
      pageNumber: 1,
      pageSize: 10,
    );

    emit(
      state.copyWith(status: HomeSearchStatus.ready, validationMessage: null),
    );

    unawaited(_localDataSource.saveLastServices(state.selectedServices));
    unawaited(_localDataSource.saveLastDepartureDate(state.departureDate!));
    unawaited(_localDataSource.saveLastDepartureTime(state.departureTimeText));
    unawaited(
      _localDataSource.saveNearbyFlags(
        enableNearbySearch: state.enableNearbySearch,
        expandPickupLocation: state.expandPickupLocation,
        expandDropoffLocation: state.expandDropoffLocation,
      ),
    );
    unawaited(
      _localDataSource.saveRecentSearch(
        pickup: state.pickupLocation!,
        dropoff: state.dropoffLocation!,
      ),
    );

    return request;
  }

  void clearValidationMessage() {
    if (state.validationMessage == null) {
      return;
    }
    emit(
      state.copyWith(status: HomeSearchStatus.ready, validationMessage: null),
    );
  }

  String? _validate() {
    if (state.selectedServices.isEmpty) {
      return 'Vui long chon it nhat 1 dich vu';
    }
    if (state.pickupLocation == null || state.dropoffLocation == null) {
      return 'Vui long chon day du diem don va diem den';
    }
    final departureDate = state.departureDate;
    if (departureDate == null) {
      return 'Vui long chon ngay khoi hanh';
    }
    final normalizedDate = DateTime(
      departureDate.year,
      departureDate.month,
      departureDate.day,
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (normalizedDate.isBefore(today)) {
      return 'Ngay khoi hanh khong duoc nho hon hom nay';
    }

    final departureTime = state.departureTime;
    if (departureTime != null && _isSameDate(normalizedDate, today)) {
      final selectedDateTime = DateTime(
        normalizedDate.year,
        normalizedDate.month,
        normalizedDate.day,
        departureTime.hour,
        departureTime.minute,
      );
      if (selectedDateTime.isBefore(now)) {
        return 'Gio khoi hanh khong duoc nho hon thoi gian hien tai';
      }
    }
    return null;
  }

  DateTime? _normalizeDepartureDate(DateTime value) {
    final normalized = DateTime(value.year, value.month, value.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (normalized.isBefore(today)) {
      return null;
    }
    return normalized;
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  TimeOfDay? _parseTimeOfDay(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    final parts = text.split(':');
    if (parts.length < 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  String? _formatTimeOfDay(TimeOfDay? value) {
    if (value == null) {
      return null;
    }
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
