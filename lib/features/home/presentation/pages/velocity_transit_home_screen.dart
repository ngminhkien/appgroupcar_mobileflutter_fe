import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../di/injection.dart';
import '../../../location/domain/entities/location_search_item.dart';
import '../../../location/presentation/models/location_search_screen_args.dart';
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
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 22.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tim chuyen',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Chon dich vu, hanh trinh va lich khoi hanh de tim ket qua phu hop.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _SearchForm(
                      state: state,
                      onToggleService: (service) => context
                          .read<HomeSearchCubit>()
                          .toggleService(service),
                      onTapPickup: () =>
                          _openLocationSearch(context, isPickup: true),
                      onTapDropoff: () =>
                          _openLocationSearch(context, isPickup: false),
                      onSwap: () => context
                          .read<HomeSearchCubit>()
                          .swapPickupAndDropoff(),
                      onPickDate: () => _pickDepartureDate(context, state),
                      onPickTime: () => _pickDepartureTime(context, state),
                      onClearTime: () =>
                          context.read<HomeSearchCubit>().clearDepartureTime(),
                      onApplyRecent: (index) {
                        final recent = state.recentSearches[index];
                        context.read<HomeSearchCubit>().applyRecentSearch(
                          recent,
                        );
                      },
                      onToggleNearby: (value) => context
                          .read<HomeSearchCubit>()
                          .setEnableNearbySearch(value),
                      onToggleExpandPickup: (value) => context
                          .read<HomeSearchCubit>()
                          .setExpandPickupLocation(value),
                      onToggleExpandDropoff: (value) => context
                          .read<HomeSearchCubit>()
                          .setExpandDropoffLocation(value),
                    ),
                    SizedBox(height: 14.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: state.canSearch
                            ? () => _onSearch(context, state)
                            : null,
                        icon: const Icon(Icons.search),
                        label: const Text('Tim chuyen di'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(50.h),
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
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

  Future<void> _openLocationSearch(
    BuildContext context, {
    required bool isPickup,
  }) async {
    final selected = await context.push<LocationSearchItem>(
      '/location_search',
      extra: LocationSearchScreenArgs(
        title: isPickup ? 'Chon diem don' : 'Chon diem den',
        hintText: 'Nhap ten dia diem',
        availableForRoute: false,
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
}

class _SearchForm extends StatelessWidget {
  const _SearchForm({
    required this.state,
    required this.onToggleService,
    required this.onTapPickup,
    required this.onTapDropoff,
    required this.onSwap,
    required this.onPickDate,
    required this.onPickTime,
    required this.onClearTime,
    required this.onApplyRecent,
    required this.onToggleNearby,
    required this.onToggleExpandPickup,
    required this.onToggleExpandDropoff,
  });

  final HomeSearchState state;
  final ValueChanged<TripService> onToggleService;
  final VoidCallback onTapPickup;
  final VoidCallback onTapDropoff;
  final VoidCallback onSwap;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final VoidCallback onClearTime;
  final ValueChanged<int> onApplyRecent;
  final ValueChanged<bool> onToggleNearby;
  final ValueChanged<bool> onToggleExpandPickup;
  final ValueChanged<bool> onToggleExpandDropoff;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Dich vu'),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: TripService.values.map((service) {
              return ChoiceChip(
                label: Text(service.displayName),
                selected: state.selectedServices.contains(service),
                onSelected: (_) => onToggleService(service),
              );
            }).toList(),
          ),
          SizedBox(height: 12.h),
          _SectionTitle(title: 'Hanh trinh'),
          SizedBox(height: 8.h),
          _LocationField(
            icon: Icons.my_location_outlined,
            label: 'Diem don',
            value: state.pickupLocation?.displayName ?? '',
            placeholder: 'Chon diem don',
            onTap: onTapPickup,
          ),
          SizedBox(height: 8.h),
          _LocationField(
            icon: Icons.location_on_outlined,
            label: 'Diem den',
            value: state.dropoffLocation?.displayName ?? '',
            placeholder: 'Chon diem den',
            onTap: onTapDropoff,
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onSwap,
              icon: const Icon(Icons.swap_vert),
              label: const Text('Dao chieu'),
            ),
          ),
          if (state.recentSearches.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              'Gan day',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: List.generate(
                state.recentSearches.length > 3
                    ? 3
                    : state.recentSearches.length,
                (index) {
                  final item = state.recentSearches[index];
                  return ActionChip(
                    onPressed: () => onApplyRecent(index),
                    label: Text(
                      '${item.pickupDisplayName} -> ${item.dropoffDisplayName}',
                      style: TextStyle(fontSize: 11.sp),
                    ),
                  );
                },
              ),
            ),
          ],
          SizedBox(height: 12.h),
          _SectionTitle(title: 'Lich khoi hanh'),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _ScheduleTile(
                  label: 'Ngay di',
                  icon: Icons.calendar_today_outlined,
                  value: _formatDate(state.departureDate),
                  placeholder: 'Chon ngay',
                  onTap: onPickDate,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _ScheduleTile(
                  label: 'Gio di',
                  icon: Icons.schedule_outlined,
                  value: _formatTime(state.departureTime),
                  placeholder: 'Khong bat buoc',
                  onTap: onPickTime,
                  onClear: state.departureTime == null ? null : onClearTime,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _SectionTitle(title: 'Bo loc'),
          SizedBox(height: 8.h),
          SwitchListTile(
            value: state.enableNearbySearch,
            dense: true,
            contentPadding: EdgeInsets.zero,
            onChanged: onToggleNearby,
            title: const Text('Mo rong tim diem lan can'),
          ),
          CheckboxListTile(
            value: state.expandPickupLocation,
            dense: true,
            contentPadding: EdgeInsets.zero,
            onChanged: state.enableNearbySearch
                ? (value) => onToggleExpandPickup(value ?? false)
                : null,
            title: const Text('Mo rong cho diem don'),
          ),
          CheckboxListTile(
            value: state.expandDropoffLocation,
            dense: true,
            contentPadding: EdgeInsets.zero,
            onChanged: state.enableNearbySearch
                ? (value) => onToggleExpandDropoff(value ?? false)
                : null,
            title: const Text('Mo rong cho diem den'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '';
    }
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.icon,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: AppColors.primaryContainer),
            SizedBox(width: 8.w),
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
                  SizedBox(height: 2.h),
                  Text(
                    value.isEmpty ? placeholder : value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: value.isEmpty
                          ? AppColors.onSurfaceVariant
                          : AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final IconData icon;
  final String value;
  final String placeholder;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: AppColors.primaryContainer),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value.isEmpty ? placeholder : value,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: value.isEmpty
                          ? AppColors.onSurfaceVariant
                          : AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null && value.isNotEmpty)
              InkWell(
                onTap: onClear,
                borderRadius: BorderRadius.circular(999.r),
                child: Icon(
                  Icons.close_rounded,
                  size: 15.sp,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
