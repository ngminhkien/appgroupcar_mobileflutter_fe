import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../di/injection.dart';
import '../../../location/domain/entities/location_search_item.dart';
import '../../../location/presentation/models/location_search_screen_args.dart';
import '../../../trips/presentation/widgets/trip_card.dart';
import '../../domain/entities/trip_service.dart';
import '../cubit/home_search_cubit.dart';
import '../cubit/home_search_state.dart';
import '../models/trip_search_screen_args.dart';

class VelocityTransitHomeScreen extends StatelessWidget {
  const VelocityTransitHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeSearchCubit>()..loadInitialData(),
      child: const _VelocityTransitHomeView(),
    );
  }
}

class _VelocityTransitHomeView extends StatelessWidget {
  const _VelocityTransitHomeView();

  static const List<_FeaturedTrip> _featuredTrips = [
    _FeaturedTrip(
      serviceType: 'Xe khach',
      from: 'Ben xe Mien Dong',
      to: 'Ben xe Da Nang',
      time: '06:30 - 05/05',
      price: '320.000d',
      seatInfo: 'Con 12 cho',
    ),
    _FeaturedTrip(
      serviceType: 'Xe ghep',
      from: 'San bay Noi Bai',
      to: 'Ben xe Giap Bat',
      time: '09:15 - 05/05',
      price: '140.000d',
      seatInfo: 'Con 5 cho',
    ),
    _FeaturedTrip(
      serviceType: 'Cho hang',
      from: 'Kho Thu Duc',
      to: 'Quan 1',
      time: '14:00 - 05/05',
      price: '220.000d',
      seatInfo: 'Nhan trong ngay',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeSearchCubit, HomeSearchState>(
      listenWhen: (previous, current) =>
          previous.validationMessage != current.validationMessage,
      listener: (context, state) {
        final message = state.validationMessage;
        if (message == null || message.isEmpty) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        context.read<HomeSearchCubit>().clearValidationMessage();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<HomeSearchCubit, HomeSearchState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chao,',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Ban muon di dau hom nay?',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildSearchForm(context, state),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.canSearch
                            ? () => _onSearch(context, state)
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Text(
                          'Tim chuyen di',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Chuyen noi bat',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ..._featuredTrips.map(
                      (trip) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: TripCard(
                          serviceType: trip.serviceType,
                          from: trip.from,
                          to: trip.to,
                          time: trip.time,
                          price: trip.price,
                          seatInfo: trip.seatInfo,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: const AppBottomNavBar(),
      ),
    );
  }

  Widget _buildSearchForm(BuildContext context, HomeSearchState state) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.surfaceContainerLow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dich vu',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: TripService.values
                .map(
                  (service) => _buildServiceOption(
                    context,
                    service: service,
                    isSelected: state.selectedServices.contains(service),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 14.h),
          _buildInputField(
            label: 'Diem don',
            value: state.pickupLocation?.displayName ?? '',
            placeholder: 'Chon diem di',
            icon: Icons.my_location,
            onTap: () => _openLocationSearch(context, isPickup: true),
          ),
          SizedBox(height: 12.h),
          _buildInputField(
            label: 'Diem den',
            value: state.dropoffLocation?.displayName ?? '',
            placeholder: 'Chon diem den',
            icon: Icons.location_on,
            onTap: () => _openLocationSearch(context, isPickup: false),
          ),
          SizedBox(height: 12.h),
          _buildInputField(
            label: 'Ngay khoi hanh',
            value: _formatDate(state.departureDate),
            icon: Icons.calendar_today,
            placeholder: 'Chon ngay',
            onTap: () => _pickDepartureDate(context, state),
          ),
          SizedBox(height: 10.h),
          _buildInputField(
            label: 'Gio khoi hanh (tuy chon)',
            value: _formatTime(state.departureTime),
            icon: Icons.schedule,
            placeholder: 'Bo trong neu chi tim theo ngay',
            onTap: () => _pickDepartureTime(context, state),
          ),
          if (state.departureTime != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    context.read<HomeSearchCubit>().clearDepartureTime(),
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Bo gio'),
              ),
            ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.near_me_outlined,
                      size: 18.sp,
                      color: AppColors.primaryContainer,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Mo rong tim diem lan can',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Switch(
                      value: state.enableNearbySearch,
                      onChanged: (value) => context
                          .read<HomeSearchCubit>()
                          .setEnableNearbySearch(value),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                _buildExpandFlagOption(
                  context,
                  title: 'Mo rong cho diem don',
                  value: state.expandPickupLocation,
                  enabled: state.enableNearbySearch,
                  onChanged: (value) => context
                      .read<HomeSearchCubit>()
                      .setExpandPickupLocation(value),
                ),
                _buildExpandFlagOption(
                  context,
                  title: 'Mo rong cho diem den',
                  value: state.expandDropoffLocation,
                  enabled: state.enableNearbySearch,
                  onChanged: (value) => context
                      .read<HomeSearchCubit>()
                      .setExpandDropoffLocation(value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceOption(
    BuildContext context, {
    required TripService service,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.read<HomeSearchCubit>().toggleService(service),
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.secondaryContainer
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.secondary
                  : AppColors.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.secondary.withValues(alpha: 0.15)
                      : AppColors.surfaceContainerLowest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _serviceIcon(service),
                  size: 18.sp,
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.primaryContainer,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.displayName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    service.subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10.w),
              Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                size: 18.sp,
                color: isSelected ? AppColors.secondary : AppColors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandFlagOption(
    BuildContext context, {
    required String title,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: CheckboxListTile(
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: enabled ? (next) => onChanged(next ?? false) : null,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String value,
    required String placeholder,
    required IconData icon,
    required VoidCallback onTap,
    IconData? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryContainer, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      value.isEmpty ? placeholder : value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: value.isEmpty
                            ? FontWeight.w500
                            : FontWeight.w700,
                        color: value.isEmpty
                            ? AppColors.onSurfaceVariant
                            : AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                Icon(trailing, color: AppColors.outline, size: 18.sp),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLocationSearch(
    BuildContext context, {
    required bool isPickup,
  }) async {
    final selected = await context.push<LocationSearchItem>(
      '/location_search',
      extra: LocationSearchScreenArgs(
        title: isPickup ? 'Chon diem don' : 'Chon diem den',
        hintText: 'Nhap ten dia diem',
      ),
    );
    if (selected == null || !context.mounted) {
      return;
    }

    if (isPickup) {
      context.read<HomeSearchCubit>().setPickupLocation(selected);
      return;
    }
    context.read<HomeSearchCubit>().setDropoffLocation(selected);
  }

  Future<void> _pickDepartureDate(
    BuildContext context,
    HomeSearchState state,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = state.departureDate ?? today;

    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: today,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) {
      return;
    }
    context.read<HomeSearchCubit>().setDepartureDate(date);
  }

  Future<void> _pickDepartureTime(
    BuildContext context,
    HomeSearchState state,
  ) async {
    final current = state.departureTime ?? TimeOfDay.now();
    final time = await showTimePicker(context: context, initialTime: current);
    if (time == null || !context.mounted) {
      return;
    }
    context.read<HomeSearchCubit>().setDepartureTime(time);
  }

  void _onSearch(BuildContext context, HomeSearchState state) {
    final cubit = context.read<HomeSearchCubit>();
    final request = cubit.buildSearchRequest();
    if (request == null) {
      return;
    }
    context.push(
      '/search_results',
      extra: TripSearchScreenArgs(
        request: request,
        pickupDisplayName: state.pickupLocation?.displayName ?? '',
        dropoffDisplayName: state.dropoffLocation?.displayName ?? '',
      ),
    );
  }

  IconData _serviceIcon(TripService service) {
    switch (service) {
      case TripService.bus:
        return Icons.directions_bus_filled_outlined;
      case TripService.sharedRide:
        return Icons.airport_shuttle_outlined;
      case TripService.truck:
        return Icons.local_shipping_outlined;
    }
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '';
    }
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  String _formatTime(TimeOfDay? value) {
    if (value == null) {
      return '';
    }
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _FeaturedTrip {
  const _FeaturedTrip({
    required this.serviceType,
    required this.from,
    required this.to,
    required this.time,
    required this.price,
    required this.seatInfo,
  });

  final String serviceType;
  final String from;
  final String to;
  final String time;
  final String price;
  final String seatInfo;
}
