import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/trip_search_item.dart';
import '../../domain/entities/trip_search_request.dart';
import '../../domain/entities/trip_service.dart';
import '../cubit/trip_search_cubit.dart';
import '../cubit/trip_search_state.dart';
import '../models/trip_detail_navigation_args.dart';
import '../models/trip_search_screen_args.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key, this.args});

  final TripSearchScreenArgs? args;

  @override
  Widget build(BuildContext context) {
    if (args == null) {
      return const _MissingRequestScreen();
    }
    return BlocProvider(
      create: (_) => sl<TripSearchCubit>()..search(args!.request),
      child: _SearchResultsView(args: args!),
    );
  }
}

class _SearchResultsView extends StatefulWidget {
  const _SearchResultsView({required this.args});

  final TripSearchScreenArgs args;

  @override
  State<_SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<_SearchResultsView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripSearchCubit, TripSearchState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          (current.errorMessage?.isNotEmpty ?? false),
      listener: (context, state) {
        final message =
            state.errorMessage?.replaceFirst('Exception: ', '') ??
            'Khong the tim chuyen di';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceContainerLow,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Column(
            children: [
              Text(
                '${widget.args.pickupDisplayName} -> ${widget.args.dropoffDisplayName}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${_formatRequestSchedule(widget.args.request)} - ${_serviceSummary(widget.args)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        body: BlocBuilder<TripSearchCubit, TripSearchState>(
          builder: (context, state) {
            switch (state.status) {
              case TripSearchStatus.loading:
                return const _TripLoadingList();
              case TripSearchStatus.error:
                return _TripError(
                  message: state.errorMessage,
                  onRetry: () => context.read<TripSearchCubit>().retry(),
                );
              case TripSearchStatus.empty:
                return const _TripEmpty();
              case TripSearchStatus.success:
                return _TripList(
                  controller: _scrollController,
                  items: state.items,
                  isPaging: state.isPaging,
                  onViewDetail: (item) => _openTripDetail(context, item),
                );
              case TripSearchStatus.initial:
                return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  void _openTripDetail(BuildContext context, TripSearchItem item) {
    final detailApi = item.reference.detailApi.trim();
    if (detailApi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Khong co duong dan chi tiet cho chuyen nay'),
        ),
      );
      return;
    }
    context.push(
      '/search_results/detail',
      extra: TripDetailNavigationArgs(
        tripId: item.tripId,
        serviceCode: item.reference.serviceCode,
        detailApi: detailApi,
      ),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final threshold = _scrollController.position.maxScrollExtent - 180.h;
    if (_scrollController.position.pixels >= threshold) {
      context.read<TripSearchCubit>().loadMore();
    }
  }
}

class _TripList extends StatelessWidget {
  const _TripList({
    required this.controller,
    required this.items,
    required this.isPaging,
    required this.onViewDetail,
  });

  final ScrollController controller;
  final List<TripSearchItem> items;
  final bool isPaging;
  final ValueChanged<TripSearchItem> onViewDetail;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: controller,
      padding: EdgeInsets.all(20.w),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Center(
              child: SizedBox(
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        return _TripResultCard(
          item: items[index],
          onViewDetail: () => onViewDetail(items[index]),
        );
      },
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemCount: items.length + (isPaging ? 1 : 0),
    );
  }
}

class _TripResultCard extends StatelessWidget {
  const _TripResultCard({required this.item, required this.onViewDetail});

  final TripSearchItem item;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    final pickupName = item.routePoints.isNotEmpty
        ? item.routePoints.first.locationName
        : '-';
    final dropoffName = item.routePoints.isNotEmpty
        ? item.routePoints.last.locationName
        : '-';
    final usedNearbyPickup = item.match?.usedNearbyForPickup ?? false;
    final usedNearbyDropoff = item.match?.usedNearbyForDropoff ?? false;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  _serviceIcon(item.reference.serviceCode),
                  color: AppColors.secondary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.providerName.isNotEmpty
                          ? item.providerName
                          : 'Nha xe dang cap nhat',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.tripTypeName.isNotEmpty
                          ? item.tripTypeName
                          : 'Chuyen thuong',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                _formatMoney(item.price),
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              children: [
                _RouteRow(
                  icon: Icons.trip_origin,
                  label: 'Diem don',
                  value: pickupName,
                ),
                SizedBox(height: 6.h),
                _RouteRow(
                  icon: Icons.place_outlined,
                  label: 'Diem den',
                  value: dropoffName,
                ),
                SizedBox(height: 6.h),
                _RouteRow(
                  icon: Icons.schedule,
                  label: 'Gio khoi hanh',
                  value: _formatDateTime(item.departureTime),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _FlagChip(
                text: usedNearbyPickup
                    ? 'Mo rong diem don'
                    : 'Dung diem don chinh xac',
                highlight: usedNearbyPickup,
              ),
              _FlagChip(
                text: usedNearbyDropoff
                    ? 'Mo rong diem den'
                    : 'Dung diem den chinh xac',
                highlight: usedNearbyDropoff,
              ),
              _FlagChip(
                text: 'Service: ${item.reference.serviceCode}',
                highlight: false,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.onSecondary,
              ),
              child: const Text('Xem chi tiet'),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _serviceIcon(String serviceCode) {
    switch (serviceCode.toUpperCase()) {
      case 'BUS':
        return Icons.directions_bus_filled_outlined;
      case 'SHAREDRIDE':
        return Icons.airport_shuttle_outlined;
      case 'TRUCK':
        return Icons.local_shipping_outlined;
      default:
        return Icons.alt_route;
    }
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.onSurfaceVariant),
        SizedBox(width: 8.w),
        SizedBox(
          width: 84.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _FlagChip extends StatelessWidget {
  const _FlagChip({required this.text, required this.highlight});

  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final background = highlight
        ? AppColors.secondaryContainer
        : AppColors.surfaceContainerLow;
    final textColor = highlight
        ? AppColors.secondary
        : AppColors.onSurfaceVariant;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TripLoadingList extends StatelessWidget {
  const _TripLoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(20.w),
      itemBuilder: (_, __) => Container(
        height: 220.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14.r),
        ),
      ),
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemCount: 4,
    );
  }
}

class _TripEmpty extends StatelessWidget {
  const _TripEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 36.sp, color: AppColors.outline),
            SizedBox(height: 12.h),
            Text(
              'Khong tim thay chuyen phu hop',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripError extends StatelessWidget {
  const _TripError({required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final text =
        message?.replaceFirst('Exception: ', '') ??
        'Khong the tai ket qua tim kiem';
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 14.h),
            ElevatedButton(onPressed: onRetry, child: const Text('Thu lai')),
          ],
        ),
      ),
    );
  }
}

class _MissingRequestScreen extends StatelessWidget {
  const _MissingRequestScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Ket qua tim kiem',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Text(
            'Khong co du lieu tim kiem. Vui long quay lai man hinh truoc.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}

String _serviceSummary(TripSearchScreenArgs args) {
  return args.request.services.map((service) => service.displayName).join(', ');
}

String _formatMoney(double value) {
  final raw = value.round().toString();
  final chars = raw.split('').reversed.toList();
  final buffer = StringBuffer();
  for (var index = 0; index < chars.length; index++) {
    if (index > 0 && index % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(chars[index]);
  }
  final number = buffer.toString().split('').reversed.join();
  return '$number d';
}

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return '-';
  }
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute - $day/$month';
}

String _formatRequestSchedule(TripSearchRequest request) {
  final date = request.departureDate;
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  final time = request.departureTime?.trim();
  if (time == null || time.isEmpty) {
    return '$day/$month/$year';
  }
  return '$time - $day/$month/$year';
}
