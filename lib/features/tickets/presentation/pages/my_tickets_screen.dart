import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/bus_booking.dart';
import '../cubit/my_tickets_cubit.dart';
import '../cubit/my_tickets_state.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MyTicketsCubit>()..loadBookings(),
      child: const _MyTicketsView(),
    );
  }
}

class _MyTicketsView extends StatelessWidget {
  const _MyTicketsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Ve cua toi', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          BlocBuilder<MyTicketsCubit, MyTicketsState>(
            builder: (context, state) {
              if (state.status == MyTicketsStatus.loading) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<MyTicketsCubit>().loadBookings(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<MyTicketsCubit, MyTicketsState>(
        builder: (context, state) {
          switch (state.status) {
            case MyTicketsStatus.loading:
              return const _TicketsLoadingView();
            case MyTicketsStatus.failure:
              return _TicketsErrorView(
                message: state.errorMessage,
                onRetry: () => context.read<MyTicketsCubit>().loadBookings(),
              );
            case MyTicketsStatus.success:
              if (state.bookings.isEmpty) {
                return const _TicketsEmptyView();
              }
              return RefreshIndicator(
                onRefresh: () => context.read<MyTicketsCubit>().loadBookings(
                  isRefresh: true,
                ),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
                  itemBuilder: (context, index) {
                    final booking = state.bookings[index];
                    return _TicketCard(
                      booking: booking,
                      onTap: () => context.push('/my_tickets/${booking.bookingId}'),
                    );
                  },
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemCount: state.bookings.length,
                ),
              );
            case MyTicketsStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.booking, required this.onTap});

  final BusBooking booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final seatText = booking.seatNumbers.isEmpty
        ? 'Dang cap nhat'
        : booking.seatNumbers.join(', ');
    final codeText = _ticketCodeSummary(booking);
    final statusStyle = _statusStyle(booking.bookingStatus);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Container(
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
                          'Ma ve: $codeText',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Booking: ${_shortId(booking.bookingId)}',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusStyle.background,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      booking.statusLabel,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: statusStyle.foreground,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              _TicketInfoRow(label: 'Ghe', value: seatText),
              SizedBox(height: 6.h),
              _TicketInfoRow(
                label: 'Tong tien',
                value: _formatMoney(booking.totalPrice),
                valueColor: AppColors.primaryContainer,
                isStrong: true,
              ),
              SizedBox(height: 6.h),
              _TicketInfoRow(
                label: 'Showtime',
                value: _shortId(booking.showtimeId),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 14.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Xem chi tiet ve',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketInfoRow extends StatelessWidget {
  const _TicketInfoRow({
    required this.label,
    required this.value,
    this.valueColor = AppColors.onSurface,
    this.isStrong = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 84.w,
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
              color: valueColor,
              fontSize: 12.sp,
              fontWeight: isStrong ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _TicketsLoadingView extends StatelessWidget {
  const _TicketsLoadingView();

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
      itemCount: 4,
    );
  }
}

class _TicketsEmptyView extends StatelessWidget {
  const _TicketsEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 40.sp,
              color: AppColors.outline,
            ),
            SizedBox(height: 12.h),
            Text(
              'Ban chua co ve bus nao',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketsErrorView extends StatelessWidget {
  const _TicketsErrorView({required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final text =
        message?.replaceFirst('Exception: ', '') ??
        'Khong the tai danh sach ve cua ban';
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
