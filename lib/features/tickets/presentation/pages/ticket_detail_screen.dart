import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/enums/route_stop_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/bus_booking.dart';
import '../../domain/entities/bus_booking_detail.dart';
import '../cubit/ticket_detail_cubit.dart';
import '../cubit/ticket_detail_state.dart';

class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TicketDetailCubit>()..loadDetail(bookingId),
      child: const _TicketDetailView(),
    );
  }
}

class _TicketDetailView extends StatelessWidget {
  const _TicketDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        title: const Text(
          'Chi tiet ve',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          BlocBuilder<TicketDetailCubit, TicketDetailState>(
            builder: (context, state) {
              if (state.status == TicketDetailStatus.loading) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<TicketDetailCubit>().refresh(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TicketDetailCubit, TicketDetailState>(
        builder: (context, state) {
          switch (state.status) {
            case TicketDetailStatus.loading:
              return const _TicketDetailLoadingView();
            case TicketDetailStatus.failure:
              return _TicketDetailErrorView(
                message: state.errorMessage,
                onRetry: () => context.read<TicketDetailCubit>().refresh(),
              );
            case TicketDetailStatus.success:
              if (state.detail == null) {
                return _TicketDetailErrorView(
                  message: 'Khong co thong tin ve',
                  onRetry: () => context.read<TicketDetailCubit>().refresh(),
                );
              }
              return _TicketDetailSuccessView(detail: state.detail!);
            case TicketDetailStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class _TicketDetailSuccessView extends StatelessWidget {
  const _TicketDetailSuccessView({required this.detail});

  final BusBookingDetail detail;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TicketHeaderCard(detail: detail),
          SizedBox(height: 12.h),
          _SeatTicketSection(detail: detail),
          SizedBox(height: 12.h),
          _ShowtimeSection(detail: detail),
        ],
      ),
    );
  }
}

class _TicketHeaderCard extends StatelessWidget {
  const _TicketHeaderCard({required this.detail});

  final BusBookingDetail detail;

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(detail.bookingStatus);
    final ticketCode = _ticketCodeSummary(detail.booking);
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ma ve: $ticketCode',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Booking: ${_shortId(detail.bookingId)}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusStyle.background,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  detail.statusLabel,
                  style: TextStyle(
                    color: statusStyle.foreground,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _InfoRow(label: 'Tong tien', value: _formatMoney(detail.totalPrice)),
          _InfoRow(
            label: 'Showtime',
            value: detail.showtimeId.trim().isEmpty
                ? 'Dang cap nhat'
                : _shortId(detail.showtimeId),
          ),
          _InfoRow(
            label: 'Han thanh toan',
            value: detail.expireAt == null
                ? 'Khong gioi han'
                : _formatDateTime(detail.expireAt!),
          ),
        ],
      ),
    );
  }
}

class _SeatTicketSection extends StatelessWidget {
  const _SeatTicketSection({required this.detail});

  final BusBookingDetail detail;

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
            'Thong tin ghe',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 10.h),
          if (detail.seats.isEmpty)
            Text(
              'Khong co du lieu ghe',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 12.sp,
              ),
            )
          else
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: detail.seats
                  .map(
                    (seat) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ghe ${seat.seatNumber}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            seat.ticketCode.trim().isEmpty
                                ? 'Dang cap nhat ma ve'
                                : seat.ticketCode,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _ShowtimeSection extends StatelessWidget {
  const _ShowtimeSection({required this.detail});

  final BusBookingDetail detail;

  @override
  Widget build(BuildContext context) {
    final showtime = detail.showtime;
    if (showtime == null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Text(
          'Chua co thong tin chuyen bus',
          style: TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 12.sp,
          ),
        ),
      );
    }

    final route = showtime.route;
    final vehicle = showtime.vehicle;
    final driver = showtime.driver;
    final departure = showtime.departureDateTime;

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
            'Thong tin chuyen bus',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 10.h),
          _InfoRow(
            label: 'Nha xe',
            value: _fallback(showtime.companyName),
          ),
          _InfoRow(
            label: 'Lo trinh',
            value: route == null ? 'Dang cap nhat' : _fallback(route.name),
          ),
          _InfoRow(
            label: 'Gio khoi hanh',
            value: departure == null ? 'Dang cap nhat' : _formatDateTime(departure),
          ),
          _InfoRow(
            label: 'Gia/ghe',
            value: _formatMoney(showtime.price),
          ),
          _InfoRow(
            label: 'So ghe xe',
            value: showtime.seatCount <= 0 ? 'Dang cap nhat' : '${showtime.seatCount}',
          ),
          if (vehicle != null) ...[
            SizedBox(height: 8.h),
            _InfoRow(label: 'Bien so', value: _fallback(vehicle.plateNumber)),
            _InfoRow(
              label: 'Loai xe',
              value: vehicle.seatLayoutName.trim().isEmpty
                  ? '${vehicle.seatCapacity} ghe'
                  : '${vehicle.seatLayoutName} (${vehicle.seatCapacity} ghe)',
            ),
          ],
          if (driver != null) ...[
            SizedBox(height: 8.h),
            _InfoRow(label: 'Tai xe', value: _fallback(driver.fullName)),
            _InfoRow(label: 'Hang bang', value: _fallback(driver.licenseClass)),
          ],
          if (route != null && route.routePoints.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              'Route points',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            ...route.routePoints
                .map(
                  (point) => Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(9.w),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${point.sequence}. ${_fallback(point.locationName)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'StopType: ${RouteStopType.fromValue(point.stopType).displayLabel}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                ,
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92.w,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 11.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketDetailLoadingView extends StatelessWidget {
  const _TicketDetailLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
      itemBuilder: (_, __) => Container(
        height: 150.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14.r),
        ),
      ),
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemCount: 3,
    );
  }
}

class _TicketDetailErrorView extends StatelessWidget {
  const _TicketDetailErrorView({required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final text =
        message?.replaceFirst('Exception: ', '') ??
        'Khong the tai chi tiet ve';
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
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

class _StatusStyle {
  const _StatusStyle({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}

_StatusStyle _statusStyle(BusBookingStatus status) {
  switch (status) {
    case BusBookingStatus.cash:
      return const _StatusStyle(
        background: Color(0xFFFFF1E8),
        foreground: AppColors.secondary,
      );
    case BusBookingStatus.paid:
      return const _StatusStyle(
        background: Color(0xFFE9F8EF),
        foreground: Color(0xFF1D7A3E),
      );
    case BusBookingStatus.unknown:
      return const _StatusStyle(
        background: Color(0xFFF0F2F5),
        foreground: AppColors.onSurfaceVariant,
      );
  }
}

String _ticketCodeSummary(BusBooking booking) {
  final codes = booking.seats
      .map((seat) => seat.ticketCode.trim())
      .where((code) => code.isNotEmpty)
      .toSet()
      .toList();
  if (codes.isEmpty) {
    return 'Dang cap nhat';
  }
  if (codes.length == 1) {
    return codes.first;
  }
  if (codes.length == 2) {
    return '${codes[0]}, ${codes[1]}';
  }
  return '${codes[0]}, ${codes[1]} +${codes.length - 2}';
}

String _shortId(String value) {
  final normalized = value.trim();
  if (normalized.length <= 10) {
    return normalized;
  }
  return '${normalized.substring(0, 6)}...${normalized.substring(normalized.length - 4)}';
}

String _fallback(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    return 'Dang cap nhat';
  }
  return normalized;
}

String _formatDateTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute - $day/$month/$year';
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
