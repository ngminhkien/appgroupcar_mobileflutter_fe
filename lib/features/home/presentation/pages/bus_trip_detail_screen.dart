import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/route_stop_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection.dart';
import '../../../tickets/presentation/cubit/bus_booking_action_cubit.dart';
import '../../../tickets/presentation/cubit/bus_booking_action_state.dart';
import '../../domain/entities/bus_showtime_detail.dart';
import '../cubit/bus_trip_detail_cubit.dart';
import '../cubit/bus_trip_detail_state.dart';
import '../models/bus_seat_selection_args.dart';
import '../models/trip_detail_navigation_args.dart';

class BusTripDetailScreen extends StatelessWidget {
  const BusTripDetailScreen({super.key, required this.args});

  final TripDetailNavigationArgs args;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<BusTripDetailCubit>()..initialize(args)),
        BlocProvider(create: (_) => sl<BusBookingActionCubit>()),
      ],
      child: const _BusTripDetailView(),
    );
  }
}

class _BusTripDetailView extends StatelessWidget {
  const _BusTripDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<BusBookingActionCubit, BusBookingActionState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, bookingState) {
        if (bookingState.status == BusBookingActionStatus.failure) {
          final message =
              bookingState.errorMessage?.replaceFirst('Exception: ', '') ??
              'Dat ve that bai';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          return;
        }

        if (bookingState.status == BusBookingActionStatus.success &&
            bookingState.booking != null) {
          final seatText = bookingState.booking!.seatNumbers.join(', ');
          final message = seatText.isEmpty
              ? 'Dat ve thanh cong'
              : 'Dat ve thanh cong cho ghe: $seatText';
          context.read<BusTripDetailCubit>().clearSelectedSeats();
          context.read<BusBookingActionCubit>().reset();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          context.go('/my_tickets');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceContainerLow,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Dat ve xe bus',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: BlocBuilder<BusTripDetailCubit, BusTripDetailState>(
          builder: (context, state) {
            switch (state.status) {
              case BusTripDetailStatus.loading:
                return const _DetailLoadingView();
              case BusTripDetailStatus.failure:
                return _DetailErrorView(
                  message: state.errorMessage,
                  onRetry: () =>
                      context.read<BusTripDetailCubit>().retryDetail(),
                );
              case BusTripDetailStatus.unsupported:
                return _UnsupportedServiceView(
                  serviceCode: state.serviceCode,
                  message: state.errorMessage,
                );
              case BusTripDetailStatus.success:
                if (state.detail == null) {
                  return _DetailErrorView(
                    message: 'Khong co thong tin chuyen bus',
                    onRetry: () =>
                        context.read<BusTripDetailCubit>().retryDetail(),
                  );
                }
                return _DetailSuccessView(state: state, detail: state.detail!);
              case BusTripDetailStatus.initial:
                return const SizedBox.shrink();
            }
          }
        ),
      ),
    );
  }
}

class _DetailSuccessView extends StatelessWidget {
  const _DetailSuccessView({required this.state, required this.detail});

  final BusTripDetailState state;
  final BusShowtimeDetail detail;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TripSummaryCard(detail: detail),
          SizedBox(height: 12.h),
          _RouteSection(route: detail.route),
          SizedBox(height: 12.h),
          _VehicleSection(vehicle: detail.vehicle),
          SizedBox(height: 12.h),
          _DriverSection(driver: detail.driver),
          SizedBox(height: 12.h),
          _BookingActionCard(state: state, detail: detail),
        ],
      ),
    );
  }
}

class _TripSummaryCard extends StatelessWidget {
  const _TripSummaryCard({required this.detail});

  final BusShowtimeDetail detail;

  @override
  Widget build(BuildContext context) {
    final departure = detail.departureDateTime;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.directions_bus_filled_outlined,
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
                      detail.companyName.trim().isEmpty
                          ? 'Nha xe dang cap nhat'
                          : detail.companyName.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      detail.route?.name.trim().isNotEmpty == true
                          ? detail.route!.name.trim()
                          : 'Lo trinh dang cap nhat',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _InfoChip(
                icon: Icons.schedule_outlined,
                label: departure == null
                    ? 'Dang cap nhat gio'
                    : _formatDateTime(departure),
              ),
              _InfoChip(
                icon: Icons.sell_outlined,
                label: 'Gia: ${_formatMoney(detail.price)}',
                highlighted: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteSection extends StatelessWidget {
  const _RouteSection({required this.route});

  final BusRouteDetail? route;

  @override
  Widget build(BuildContext context) {
    if (route == null) {
      return const _MissingSection(message: 'Chua co thong tin lo trinh');
    }
    final sortedPoints = route!.routePoints.toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));

    BusRoutePointDetail? pickupPoint;
    BusRoutePointDetail? dropoffPoint;
    for (final point in sortedPoints) {
      final type = RouteStopType.fromValue(point.stopType);
      if (pickupPoint == null &&
          (type == RouteStopType.start || type == RouteStopType.pickup)) {
        pickupPoint = point;
      }
      if (type == RouteStopType.end || type == RouteStopType.dropoff) {
        dropoffPoint = point;
      }
    }
    pickupPoint ??= sortedPoints.isNotEmpty ? sortedPoints.first : null;
    dropoffPoint ??= sortedPoints.isNotEmpty ? sortedPoints.last : null;

    return _InfoSectionCard(
      title: 'Hanh trinh',
      child: Column(
        children: [
          _LabelValueRow(
            label: 'Diem don',
            value: pickupPoint == null
                ? 'Dang cap nhat'
                : _fallback(pickupPoint.locationName),
          ),
          _LabelValueRow(
            label: 'Diem den',
            value: dropoffPoint == null
                ? 'Dang cap nhat'
                : _fallback(dropoffPoint.locationName),
          ),
          _LabelValueRow(
            label: 'Thoi gian di chuyen',
            value: route!.estimatedDurationMinutes == null
                ? 'Dang cap nhat'
                : _formatDuration(route!.estimatedDurationMinutes!),
          ),
          _RoutePointsDropdown(points: sortedPoints),
        ],
      ),
    );
  }
}

class _RoutePointsDropdown extends StatelessWidget {
  const _RoutePointsDropdown({required this.points});

  final List<BusRoutePointDetail> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: EdgeInsets.only(top: 2.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
          childrenPadding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 10.h),
          title: Text(
            'Xem route points (${points.length})',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          subtitle: Text(
            'Nhan de mo danh sach diem dung',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          children: points
              .map(
                (point) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _RoutePointItem(point: point),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _RoutePointItem extends StatelessWidget {
  const _RoutePointItem({required this.point});

  final BusRoutePointDetail point;

  @override
  Widget build(BuildContext context) {
    final stopType = RouteStopType.fromValue(point.stopType);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              point.sequence.toString(),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.secondary,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fallback(point.locationName),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'StopType: ${stopType.displayLabel}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Pickup: ${point.pickupAllowed ? 'Yes' : 'No'} | Dropoff: ${point.dropoffAllowed ? 'Yes' : 'No'}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleSection extends StatelessWidget {
  const _VehicleSection({required this.vehicle});

  final BusVehicleDetail? vehicle;

  @override
  Widget build(BuildContext context) {
    if (vehicle == null) {
      return const _MissingSection(message: 'Chua co thong tin xe');
    }
    return _InfoSectionCard(
      title: 'Thong tin xe',
      child: Column(
        children: [
          _LabelValueRow(
            label: 'Bien so',
            value: _fallback(vehicle!.plateNumber),
          ),
          _LabelValueRow(
            label: 'Suc chua',
            value: vehicle!.seatCapacity <= 0
                ? 'Dang cap nhat'
                : '${vehicle!.seatCapacity} ghe',
          ),
        ],
      ),
    );
  }
}

class _DriverSection extends StatelessWidget {
  const _DriverSection({required this.driver});

  final BusDriverDetail? driver;

  @override
  Widget build(BuildContext context) {
    if (driver == null) {
      return const _MissingSection(message: 'Chua co thong tin tai xe');
    }
    return _InfoSectionCard(
      title: 'Thong tin tai xe',
      child: Column(
        children: [
          _LabelValueRow(label: 'Ho ten', value: _fallback(driver!.fullName)),
          _LabelValueRow(
            label: 'Hang bang',
            value: _fallback(driver!.licenseClass),
          ),
        ],
      ),
    );
  }
}

class _BookingActionCard extends StatelessWidget {
  const _BookingActionCard({required this.state, required this.detail});

  final BusTripDetailState state;
  final BusShowtimeDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dat ve',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6.h),
          Text(
            state.selectedSeats.isEmpty
                ? 'Ban chua chon ghe. Hay vao man hinh chon ghe de tiep tuc dat ve.'
                : 'Da chon ${state.selectedSeats.length} ghe: ${state.selectedSeats.join(', ')}',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12.sp,
            ),
          ),
          if (state.selectedSeats.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              'Tam tinh: ${_formatMoney(state.totalSelectedPrice)}',
              style: TextStyle(
                color: AppColors.primaryContainer,
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.selectedSeats.isEmpty
                      ? null
                      : () => context
                            .read<BusTripDetailCubit>()
                            .clearSelectedSeats(),
                  icon: const Icon(Icons.clear_all_outlined),
                  label: const Text('Bo chon'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openSeatSelection(context),
                  icon: const Icon(Icons.event_seat_outlined),
                  label: const Text('Chon ghe'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.onSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (state.selectedSeats.isNotEmpty) ...[
            SizedBox(height: 10.h),
            BlocBuilder<BusBookingActionCubit, BusBookingActionState>(
              builder: (context, bookingState) {
                final isSubmitting =
                    bookingState.status == BusBookingActionStatus.loading;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : () => _bookSelectedSeats(context),
                    child: isSubmitting
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Dat ve'),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openSeatSelection(BuildContext context) async {
    final result = await context.push<List<String>>(
      '/search_results/detail/seats',
      extra: BusSeatSelectionArgs(
        detail: detail,
        initialSelectedSeats: state.selectedSeats,
      ),
    );
    if (!context.mounted || result == null) {
      return;
    }
    context.read<BusTripDetailCubit>().setSelectedSeats(result);
  }

  void _bookSelectedSeats(BuildContext context) {
    if (state.selectedSeats.isEmpty) {
      return;
    }
    context.read<BusBookingActionCubit>().createBooking(
      showtimeId: detail.id,
      seatNumbers: state.selectedSeats,
      status: 1,
    );
  }
}

class _InfoSectionCard extends StatelessWidget {
  const _InfoSectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}

class _LabelValueRow extends StatelessWidget {
  const _LabelValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final background = highlighted
        ? AppColors.secondaryContainer
        : AppColors.surfaceContainerLow;
    final foreground = highlighted ? AppColors.secondary : AppColors.onSurface;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: foreground),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingSection extends StatelessWidget {
  const _MissingSection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        message,
        style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp),
      ),
    );
  }
}

class _DetailLoadingView extends StatelessWidget {
  const _DetailLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(18.w),
      itemBuilder: (_, __) => Container(
        height: 120.h,
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

class _DetailErrorView extends StatelessWidget {
  const _DetailErrorView({required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final text =
        message?.replaceFirst('Exception: ', '') ??
        'Khong the tai chi tiet chuyen bus';
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 26.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 36.sp, color: AppColors.error),
            SizedBox(height: 10.h),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 13.sp,
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

class _UnsupportedServiceView extends StatelessWidget {
  const _UnsupportedServiceView({required this.serviceCode, this.message});

  final String serviceCode;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 26.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Service $serviceCode',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8.h),
              Text(
                message?.replaceFirst('Exception: ', '') ??
                    'Luong chi tiet nay chua duoc ho tro tren mobile.',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _fallback(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return 'Dang cap nhat';
  }
  return trimmed;
}

String _formatDateTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute - $day/$month/$year';
}

String _formatDuration(int minutes) {
  if (minutes <= 0) {
    return 'Dang cap nhat';
  }
  final hours = minutes ~/ 60;
  final remains = minutes % 60;
  if (hours <= 0) {
    return '$remains phut';
  }
  if (remains <= 0) {
    return '$hours gio';
  }
  return '$hours gio $remains phut';
}

String _formatMoney(double value) {
  final number = value.round().toString();
  final chars = number.split('').reversed.toList();
  final buffer = StringBuffer();
  for (var index = 0; index < chars.length; index++) {
    if (index > 0 && index % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(chars[index]);
  }
  final formatted = buffer.toString().split('').reversed.join();
  return '$formatted d';
}
