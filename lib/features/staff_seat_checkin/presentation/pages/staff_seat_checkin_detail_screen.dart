import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/staff_manual_checkin_info.dart';
import '../../domain/entities/staff_seat_map.dart';
import '../../domain/entities/staff_upcoming_showtime.dart';
import '../../domain/usecases/get_staff_manual_checkin_info_usecase.dart';
import '../../domain/usecases/get_staff_showtime_seat_map_usecase.dart';
import '../../domain/usecases/update_staff_seat_status_usecase.dart';
import '../cubit/staff_manual_checkin_cubit.dart';
import '../cubit/staff_manual_checkin_state.dart';
import '../cubit/staff_seat_checkin_detail_cubit.dart';
import '../cubit/staff_seat_checkin_detail_state.dart';
import '../models/staff_seat_checkin_detail_args.dart';

class StaffSeatCheckinDetailScreen extends StatelessWidget {
  const StaffSeatCheckinDetailScreen({super.key, required this.args});

  final StaffSeatCheckinDetailArgs args;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => StaffSeatCheckinDetailCubit(
            sl<GetStaffShowtimeSeatMapUseCase>(),
            sl<UpdateStaffSeatStatusUseCase>(),
            initialState: StaffSeatCheckinDetailState(showtime: args.showtime),
          )..initialize(),
        ),
        BlocProvider(
          create: (_) =>
              StaffManualCheckinCubit(sl<GetStaffManualCheckinInfoUseCase>()),
        ),
      ],
      child: const _StaffSeatCheckinDetailView(),
    );
  }
}

class _StaffSeatCheckinDetailView extends StatefulWidget {
  const _StaffSeatCheckinDetailView();

  @override
  State<_StaffSeatCheckinDetailView> createState() =>
      _StaffSeatCheckinDetailViewState();
}

class _StaffSeatCheckinDetailViewState
    extends State<_StaffSeatCheckinDetailView> {
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController(text: 'Khach mua truc tiep')
      ..addListener(_onReasonChanged);
  }

  @override
  void dispose() {
    _reasonController
      ..removeListener(_onReasonChanged)
      ..dispose();
    super.dispose();
  }

  void _onReasonChanged() {
    context.read<StaffSeatCheckinDetailCubit>().setReason(
      _reasonController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final showtime = context.select(
      (StaffSeatCheckinDetailCubit cubit) => cubit.state.showtime,
    );
    return BlocListener<
      StaffSeatCheckinDetailCubit,
      StaffSeatCheckinDetailState
    >(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus ||
          previous.seatMapErrorMessage != current.seatMapErrorMessage,
      listener: (context, state) {
        if (state.actionStatus == StaffSeatCheckinActionStatus.failure) {
          final message =
              state.actionErrorMessage?.replaceFirst('Exception: ', '') ??
              'Cập nhật ghế thất bại';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          context.read<StaffSeatCheckinDetailCubit>().resetActionStatus();
          return;
        }

        if (state.actionStatus == StaffSeatCheckinActionStatus.success) {
          final changedSeats =
              state.latestUpdates
                  .map((item) => item.seatNumber.trim())
                  .where((item) => item.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort();
          final message = changedSeats.isEmpty
              ? 'Đã cập nhật trạng thái ghế thành công'
              : 'Đã đặt chỗ offline ghế: ${changedSeats.join(', ')}';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          context.read<StaffSeatCheckinDetailCubit>().resetActionStatus();
          return;
        }

        if (state.seatMapErrorMessage != null &&
            state.seatMapErrorMessage!.trim().isNotEmpty &&
            state.seatMapStatus == StaffSeatMapStatus.success) {
          final message = state.seatMapErrorMessage!.replaceFirst(
            'Exception: ',
            '',
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          context
              .read<StaffSeatCheckinDetailCubit>()
              .clearSeatMapErrorMessage();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceContainerLow,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Vận hành ghế',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              Text(
                _formatDateTime(showtime.departureDateTime),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () =>
                  context.read<StaffSeatCheckinDetailCubit>().refreshSeatMap(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body:
            BlocBuilder<
              StaffSeatCheckinDetailCubit,
              StaffSeatCheckinDetailState
            >(
              builder: (context, state) {
                switch (state.seatMapStatus) {
                  case StaffSeatMapStatus.loading:
                    return const _SeatLoadingView();
                  case StaffSeatMapStatus.failure:
                    return _SeatErrorView(
                      message: state.seatMapErrorMessage,
                      onRetry: () => context
                          .read<StaffSeatCheckinDetailCubit>()
                          .refreshSeatMap(),
                    );
                  case StaffSeatMapStatus.success:
                    final seatMap = state.seatMap;
                    if (seatMap == null) {
                      return _SeatErrorView(
                        message: 'Không có dữ liệu sơ đồ ghế',
                        onRetry: () => context
                            .read<StaffSeatCheckinDetailCubit>()
                            .refreshSeatMap(),
                      );
                    }
                    return _SeatSuccessView(
                      state: state,
                      reasonController: _reasonController,
                    );
                  case StaffSeatMapStatus.initial:
                    return const SizedBox.shrink();
                }
              },
            ),
        bottomNavigationBar:
            BlocBuilder<
              StaffSeatCheckinDetailCubit,
              StaffSeatCheckinDetailState
            >(
              builder: (context, state) {
                if (state.seatMapStatus != StaffSeatMapStatus.success) {
                  return const SizedBox.shrink();
                }
                return _BottomActionBar(
                  state: state,
                  onClear: () => context
                      .read<StaffSeatCheckinDetailCubit>()
                      .clearSelectedSeats(),
                  onSubmit: () => context
                      .read<StaffSeatCheckinDetailCubit>()
                      .submitOfflineBooking(),
                );
              },
            ),
      ),
    );
  }
}

class _SeatSuccessView extends StatelessWidget {
  const _SeatSuccessView({required this.state, required this.reasonController});

  final StaffSeatCheckinDetailState state;
  final TextEditingController reasonController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShowtimeHeaderCard(showtime: state.showtime),
          SizedBox(height: 10.h),
          const _SeatLegend(),
          SizedBox(height: 10.h),
          _SeatLayoutPanel(
            seatMap: state.seatMap!,
            selectedSeats: state.selectedSeats,
            onToggleSeat: (seatNumber) => context
                .read<StaffSeatCheckinDetailCubit>()
                .toggleSeatSelection(seatNumber),
          ),
          SizedBox(height: 12.h),
          _ReasonCard(
            selectedCount: state.selectedSeats.length,
            reasonController: reasonController,
          ),
          SizedBox(height: 12.h),
          _ManualCheckinLookupCard(showtimeId: state.showtime.id),
          if (state.latestUpdatedAt != null ||
              state.latestUpdates.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _UpdateResultCard(state: state),
          ],
        ],
      ),
    );
  }
}

class _ShowtimeHeaderCard extends StatelessWidget {
  const _ShowtimeHeaderCard({required this.showtime});

  final StaffUpcomingShowtime showtime;

  @override
  Widget build(BuildContext context) {
    final statusStyle = _showtimeStatusStyle(showtime.showtimeStatus);
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
              Expanded(
                child: Text(
                  showtime.routeName.trim().isEmpty
                      ? 'Tuyến chưa cập nhật'
                      : showtime.routeName.trim(),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusStyle.background,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  statusStyle.label,
                  style: TextStyle(
                    color: statusStyle.foreground,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _InfoChip(
                icon: Icons.schedule_outlined,
                label: _formatDateTime(showtime.departureDateTime),
              ),
              _InfoChip(
                icon: Icons.directions_bus_outlined,
                label: showtime.plateNumber.trim().isEmpty
                    ? 'Đang cập nhật biển số'
                    : showtime.plateNumber.trim(),
              ),
              _InfoChip(
                icon: Icons.person_outline,
                label: showtime.driverName.trim().isEmpty
                    ? 'Tài xế chưa cập nhật'
                    : showtime.driverName.trim(),
              ),
              _InfoChip(
                icon: Icons.event_seat_outlined,
                label: '${showtime.seatCount} ghế',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReasonCard extends StatelessWidget {
  const _ReasonCard({
    required this.selectedCount,
    required this.reasonController,
  });

  final int selectedCount;
  final TextEditingController reasonController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đặt chỗ offline',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Flow này dùng cho khách mua vé trực tiếp tại xe/quầy. Mặc định gửi newStatus = 1.',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: reasonController,
            maxLength: 120,
            decoration: const InputDecoration(
              labelText: 'Lý do',
              hintText: 'Ví dụ: Khach mua truc tiep',
              prefixIcon: Icon(Icons.edit_note_outlined),
              counterText: '',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            selectedCount <= 0
                ? 'Chọn ghế AVAILABLE để đặt chỗ offline.'
                : 'Đang chọn $selectedCount ghế trống để đặt chỗ offline.',
            style: TextStyle(
              fontSize: 11.sp,
              color: selectedCount <= 0
                  ? AppColors.onSurfaceVariant
                  : AppColors.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualCheckinLookupCard extends StatefulWidget {
  const _ManualCheckinLookupCard({required this.showtimeId});

  final String showtimeId;

  @override
  State<_ManualCheckinLookupCard> createState() =>
      _ManualCheckinLookupCardState();
}

class _ManualCheckinLookupCardState extends State<_ManualCheckinLookupCard> {
  late final TextEditingController _seatNumberController;

  @override
  void initState() {
    super.initState();
    _seatNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _seatNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tra cứu check-in thủ công',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Nhập mã ghế để lấy booking/ticket và trạng thái check-in.',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _seatNumberController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Mã ghế',
                    hintText: 'Ví dụ: A01',
                    prefixIcon: Icon(Icons.event_seat_outlined),
                  ),
                  onSubmitted: (_) => _lookup(),
                ),
              ),
              SizedBox(width: 8.w),
              BlocBuilder<StaffManualCheckinCubit, StaffManualCheckinState>(
                builder: (context, state) {
                  final isLoading =
                      state.status == StaffManualCheckinStatus.loading;
                  return ElevatedButton(
                    onPressed: isLoading ? null : _lookup,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(88.w, 48.h),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Tra cứu'),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 10.h),
          BlocBuilder<StaffManualCheckinCubit, StaffManualCheckinState>(
            builder: (context, state) {
              if (state.status == StaffManualCheckinStatus.initial) {
                return Text(
                  'Chưa tra cứu ghế nào.',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                );
              }

              if (state.status == StaffManualCheckinStatus.loading) {
                return const LinearProgressIndicator(minHeight: 2);
              }

              if (state.status == StaffManualCheckinStatus.failure) {
                final message =
                    state.errorMessage?.replaceFirst('Exception: ', '') ??
                    'Không thể tra cứu check-in';
                return Text(
                  message,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                );
              }

              final info = state.data;
              if (info == null) {
                return Text(
                  'Không có dữ liệu check-in.',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                );
              }
              return _ManualCheckinInfoView(info: info);
            },
          ),
        ],
      ),
    );
  }

  void _lookup() {
    final raw = _seatNumberController.text.trim().toUpperCase();
    _seatNumberController.value = _seatNumberController.value.copyWith(
      text: raw,
      selection: TextSelection.collapsed(offset: raw.length),
      composing: TextRange.empty,
    );
    context.read<StaffManualCheckinCubit>().lookup(
      showtimeId: widget.showtimeId,
      seatNumber: raw,
    );
  }
}

class _ManualCheckinInfoView extends StatelessWidget {
  const _ManualCheckinInfoView({required this.info});

  final StaffManualCheckinInfo info;

  @override
  Widget build(BuildContext context) {
    final checkinLabel = info.isCheckedIn ? 'Đã check-in' : 'Chưa check-in';
    final checkinBackground = info.isCheckedIn
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFFF3C6);
    final checkinForeground = info.isCheckedIn
        ? const Color(0xFF166534)
        : const Color(0xFF92400E);
    final bookingStyle = _bookingStatusStyle(info.bookingStatus);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _StatusPill(
                label: checkinLabel,
                background: checkinBackground,
                foreground: checkinForeground,
              ),
              _StatusPill(
                label: bookingStyle.label,
                background: bookingStyle.background,
                foreground: bookingStyle.foreground,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _InfoLine(label: 'Ghế', value: info.seatNumber.trim()),
          _InfoLine(label: 'Mã vé', value: info.ticketCode.trim()),
          _InfoLine(label: 'Booking ID', value: info.bookingId.trim()),
          _InfoLine(
            label: 'Khách hàng',
            value: info.customerFullName.trim().isEmpty
                ? 'Đang cập nhật'
                : info.customerFullName.trim(),
          ),
          _InfoLine(
            label: 'SĐT',
            value: info.customerPhone.trim().isEmpty
                ? 'Đang cập nhật'
                : info.customerPhone.trim(),
          ),
          _InfoLine(
            label: 'Email',
            value: info.customerEmail.trim().isEmpty
                ? 'Đang cập nhật'
                : info.customerEmail.trim(),
          ),
          _InfoLine(
            label: 'Thời gian check-in',
            value: info.checkedInAt == null
                ? 'Chưa check-in'
                : _formatDateTime(info.checkedInAt),
          ),
          if (!info.isCheckedIn)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                'API hiện tại chỉ trả thông tin tra cứu. Nếu cần xác nhận check-in, cần thêm endpoint cập nhật check-in riêng.',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
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
              value.isEmpty ? 'Đang cập nhật' : value,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BookingStatusStyle {
  const _BookingStatusStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}

_BookingStatusStyle _bookingStatusStyle(int status) {
  switch (status) {
    case 1:
      return const _BookingStatusStyle(
        label: 'Pending',
        background: Color(0xFFFFF3C6),
        foreground: Color(0xFF92400E),
      );
    case 2:
      return const _BookingStatusStyle(
        label: 'Confirmed',
        background: Color(0xFFDBEAFE),
        foreground: Color(0xFF1E40AF),
      );
    case 3:
      return const _BookingStatusStyle(
        label: 'Cancelled',
        background: Color(0xFFFEE2E2),
        foreground: Color(0xFF991B1B),
      );
    default:
      return const _BookingStatusStyle(
        label: 'Unknown',
        background: Color(0xFFE5E7EB),
        foreground: Color(0xFF374151),
      );
  }
}

class _UpdateResultCard extends StatelessWidget {
  const _UpdateResultCard({required this.state});

  final StaffSeatCheckinDetailState state;

  @override
  Widget build(BuildContext context) {
    final visibleItems = state.latestUpdates.take(5).toList();
    final updatedTime = state.latestUpdatedAt;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                size: 16.sp,
                color: AppColors.primaryContainer,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'Kết quả cập nhật gần nhất',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (updatedTime != null) ...[
            SizedBox(height: 4.h),
            Text(
              'Thời gian: ${_formatDateTime(updatedTime)}',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
          SizedBox(height: 8.h),
          if (visibleItems.isEmpty)
            Text(
              'Không có chi tiết trả về từ API, nhưng yêu cầu đã được chấp nhận.',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.onSurfaceVariant,
              ),
            )
          else
            ...visibleItems.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.seatNumber.trim().isEmpty
                            ? 'Ghế không xác định'
                            : item.seatNumber.trim(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${item.oldStatus} -> ${item.newStatus}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.state,
    required this.onClear,
    required this.onSubmit,
  });

  final StaffSeatCheckinDetailState state;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 10.h),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.selectedSeats.isEmpty
                  ? 'Chưa chọn ghế'
                  : 'Đã chọn ${state.selectedSeats.length} ghế',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              state.selectedSeats.isEmpty
                  ? 'Chỉ ghế AVAILABLE mới có thể đặt chỗ offline.'
                  : state.selectedSeats.join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: state.selectedSeats.isEmpty ? null : onClear,
                    child: const Text('Bỏ chọn'),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: state.canSubmit ? onSubmit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.onSecondary,
                    ),
                    child: state.isSubmitting
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Xác nhận đặt chỗ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SeatLegend extends StatelessWidget {
  const _SeatLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: const [
        _LegendItem(
          color: Color(0xFFFFF3EE),
          borderColor: AppColors.secondary,
          label: 'AVAILABLE (đặt chỗ)',
        ),
        _LegendItem(
          color: AppColors.secondary,
          borderColor: AppColors.secondary,
          label: 'Đang chọn',
          textColor: AppColors.onSecondary,
        ),
        _LegendItem(
          color: Color(0xFFE6F4EA),
          borderColor: Color(0xFF1F8F4C),
          label: 'BOOKED',
        ),
        _LegendItem(
          color: Color(0xFFD4DAE3),
          borderColor: Color(0xFF9CA8B8),
          label: 'DISABLED',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.borderColor,
    required this.label,
    this.textColor = AppColors.onSurface,
  });

  final Color color;
  final Color borderColor;
  final String label;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18.w,
          height: 18.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5.r),
            border: Border.all(color: borderColor),
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SeatLayoutPanel extends StatelessWidget {
  const _SeatLayoutPanel({
    required this.seatMap,
    required this.selectedSeats,
    required this.onToggleSeat,
  });

  final StaffSeatMap seatMap;
  final List<String> selectedSeats;
  final ValueChanged<String> onToggleSeat;

  @override
  Widget build(BuildContext context) {
    final resolvedLayout = _SeatLayoutResolver.resolve(seatMap);
    if (resolvedLayout.items.isEmpty) {
      return const _MissingSection(
        message: 'Không đọc được sơ đồ ghế. Vui lòng thử làm mới.',
      );
    }

    final selectedSet = selectedSeats.map(_normalizeSeatKey).toSet();
    final decks = resolvedLayout.items.map((item) => item.deck).toSet().toList()
      ..sort();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!resolvedLayout.usesLayoutJson)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Text(
                'Đang hiển thị ghế theo thứ tự mặc định.',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11.sp,
                ),
              ),
            ),
          ...List.generate(decks.length, (index) {
            final deck = decks[index];
            final deckItems =
                resolvedLayout.items.where((item) => item.deck == deck).toList()
                  ..sort((a, b) {
                    if (a.row != b.row) {
                      return a.row.compareTo(b.row);
                    }
                    if (a.column != b.column) {
                      return a.column.compareTo(b.column);
                    }
                    return a.seatNumber.compareTo(b.seatNumber);
                  });

            final rows = <int, List<_ResolvedSeatItem>>{};
            for (final item in deckItems) {
              rows.putIfAbsent(item.row, () => <_ResolvedSeatItem>[]).add(item);
            }
            final rowKeys = rows.keys.toList()..sort();

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == decks.length - 1 ? 0 : 12.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (decks.length > 1)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        'Tầng ${deck + 1}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ...List.generate(rowKeys.length, (rowIndex) {
                    final row = rowKeys[rowIndex];
                    final rowItems = rows[row]!
                      ..sort((a, b) => a.column.compareTo(b.column));
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: rowIndex == rowKeys.length - 1 ? 0 : 7.h,
                      ),
                      child: _SeatRow(
                        rowItems: rowItems,
                        selectedSeatKeys: selectedSet,
                        onToggleSeat: onToggleSeat,
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SeatRow extends StatelessWidget {
  const _SeatRow({
    required this.rowItems,
    required this.selectedSeatKeys,
    required this.onToggleSeat,
  });

  final List<_ResolvedSeatItem> rowItems;
  final Set<String> selectedSeatKeys;
  final ValueChanged<String> onToggleSeat;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    var previousColumn = -1;
    for (final seat in rowItems) {
      if (previousColumn >= 0 && seat.column - previousColumn > 1) {
        final gap = min(seat.column - previousColumn - 1, 3);
        children.add(SizedBox(width: (gap * 16).w));
      }
      previousColumn = seat.column;
      final key = _normalizeSeatKey(seat.seatNumber);
      final isSelected = selectedSeatKeys.contains(key);
      final selectable =
          seat.status.availability == StaffSeatAvailability.available;
      children.add(
        _SeatBox(
          seatNumber: seat.seatNumber,
          status: seat.status.availability,
          isSelected: isSelected,
          onTap: selectable ? () => onToggleSeat(seat.seatNumber) : null,
        ),
      );
      children.add(SizedBox(width: 7.w));
    }
    if (children.isNotEmpty) {
      children.removeLast();
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: children),
    );
  }
}

class _SeatBox extends StatelessWidget {
  const _SeatBox({
    required this.seatNumber,
    required this.status,
    required this.isSelected,
    this.onTap,
  });

  final String seatNumber;
  final StaffSeatAvailability status;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = _seatVisualStyle(status, isSelected: isSelected);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 38.w,
        height: 36.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: style.border),
        ),
        child: Text(
          seatNumber,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: style.foreground,
          ),
        ),
      ),
    );
  }
}

class _SeatLoadingView extends StatelessWidget {
  const _SeatLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemBuilder: (_, __) => Container(
        height: 150.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14.r),
        ),
      ),
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemCount: 3,
    );
  }
}

class _SeatErrorView extends StatelessWidget {
  const _SeatErrorView({required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final text =
        message?.replaceFirst('Exception: ', '') ?? 'Không thể tải sơ đồ ghế';
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
            ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: AppColors.onSurface),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResolvedSeatLayout {
  const _ResolvedSeatLayout({
    required this.items,
    required this.usesLayoutJson,
  });

  final List<_ResolvedSeatItem> items;
  final bool usesLayoutJson;
}

class _ResolvedSeatItem {
  const _ResolvedSeatItem({
    required this.seatNumber,
    required this.status,
    required this.row,
    required this.column,
    required this.deck,
  });

  final String seatNumber;
  final StaffSeatStatus status;
  final int row;
  final int column;
  final int deck;
}

class _SeatLayoutResolver {
  static _ResolvedSeatLayout resolve(StaffSeatMap seatMap) {
    final statusMap = <String, StaffSeatStatus>{};
    for (final seat in seatMap.seats) {
      final key = _normalizeSeatKey(seat.seatNumber);
      if (key.isEmpty) {
        continue;
      }
      statusMap[key] = seat;
    }

    final layoutCandidates = _extractLayoutSeats(seatMap.seatLayout.layoutJson);
    final layoutBySeat = <String, _LayoutSeatCandidate>{};
    for (final candidate in layoutCandidates) {
      final key = _normalizeSeatKey(candidate.seatNumber);
      if (key.isEmpty) {
        continue;
      }
      final current = layoutBySeat[key];
      if (current == null || _isBetterCandidate(candidate, current)) {
        layoutBySeat[key] = candidate;
      }
    }

    final items = <_ResolvedSeatItem>[];
    final knownSeats = <String>{};

    for (final entry in layoutBySeat.entries) {
      final key = entry.key;
      final candidate = entry.value;
      final status =
          statusMap[key] ??
          StaffSeatStatus(seatNumber: candidate.seatNumber, status: 'Disabled');
      final parts = _parseSeatLabel(candidate.seatNumber);
      final row = candidate.row ?? parts.row ?? (items.length + 1);
      final column = candidate.column ?? parts.column ?? 1;
      final deck = candidate.deck ?? 0;
      items.add(
        _ResolvedSeatItem(
          seatNumber: status.seatNumber.trim().isEmpty
              ? candidate.seatNumber
              : status.seatNumber,
          status: status,
          row: row,
          column: column,
          deck: deck,
        ),
      );
      knownSeats.add(key);
    }

    final remaining =
        statusMap.entries
            .where((entry) => !knownSeats.contains(entry.key))
            .map((entry) => entry.value)
            .toList()
          ..sort((a, b) => _seatSort(a.seatNumber, b.seatNumber));

    for (var index = 0; index < remaining.length; index++) {
      final seat = remaining[index];
      final parts = _parseSeatLabel(seat.seatNumber);
      final fallbackRow = parts.row ?? (1000 + (index ~/ 4));
      final fallbackColumn = parts.column ?? ((index % 4) + 1);
      items.add(
        _ResolvedSeatItem(
          seatNumber: seat.seatNumber,
          status: seat,
          row: fallbackRow,
          column: fallbackColumn,
          deck: 0,
        ),
      );
    }

    items.sort((a, b) {
      if (a.deck != b.deck) {
        return a.deck.compareTo(b.deck);
      }
      if (a.row != b.row) {
        return a.row.compareTo(b.row);
      }
      if (a.column != b.column) {
        return a.column.compareTo(b.column);
      }
      return _seatSort(a.seatNumber, b.seatNumber);
    });

    return _ResolvedSeatLayout(
      items: items,
      usesLayoutJson: layoutBySeat.isNotEmpty,
    );
  }

  static List<_LayoutSeatCandidate> _extractLayoutSeats(
    Map<String, dynamic>? layoutJson,
  ) {
    if (layoutJson == null || layoutJson.isEmpty) {
      return const [];
    }
    final results = <_LayoutSeatCandidate>[];
    _walkNode(layoutJson, results: results, depth: 0);
    return results;
  }

  static void _walkNode(
    dynamic node, {
    required List<_LayoutSeatCandidate> results,
    required int depth,
    int? inheritedRow,
    int? inheritedColumn,
    int? inheritedDeck,
  }) {
    if (depth > 24) {
      return;
    }
    if (node is Map<String, dynamic>) {
      final row =
          _extractInt(node, const ['row', 'rowIndex', 'seatRow', 'r', 'y']) ??
          inheritedRow;
      final column =
          _extractInt(node, const [
            'column',
            'col',
            'columnIndex',
            'seatColumn',
            'c',
            'x',
          ]) ??
          inheritedColumn;
      final deck =
          _extractInt(node, const ['deck', 'floor', 'level']) ?? inheritedDeck;
      final seatNumber = _extractString(node, const [
        'seatNumber',
        'seatNo',
        'seat_no',
        'number',
        'code',
      ]);

      if (seatNumber != null && seatNumber.trim().isNotEmpty) {
        results.add(
          _LayoutSeatCandidate(
            seatNumber: seatNumber.trim(),
            row: row,
            column: column,
            deck: deck,
          ),
        );
      }

      for (final value in node.values) {
        _walkNode(
          value,
          results: results,
          depth: depth + 1,
          inheritedRow: row,
          inheritedColumn: column,
          inheritedDeck: deck,
        );
      }
      return;
    }

    if (node is List<dynamic>) {
      for (final value in node) {
        _walkNode(
          value,
          results: results,
          depth: depth + 1,
          inheritedRow: inheritedRow,
          inheritedColumn: inheritedColumn,
          inheritedDeck: inheritedDeck,
        );
      }
    }
  }
}

class _LayoutSeatCandidate {
  const _LayoutSeatCandidate({
    required this.seatNumber,
    required this.row,
    required this.column,
    required this.deck,
  });

  final String seatNumber;
  final int? row;
  final int? column;
  final int? deck;
}

class _SeatLabelParts {
  const _SeatLabelParts({this.row, this.column});

  final int? row;
  final int? column;
}

class _SeatVisualStyle {
  const _SeatVisualStyle({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;
}

_SeatVisualStyle _seatVisualStyle(
  StaffSeatAvailability status, {
  required bool isSelected,
}) {
  if (isSelected) {
    return const _SeatVisualStyle(
      background: AppColors.secondary,
      border: AppColors.secondary,
      foreground: AppColors.onSecondary,
    );
  }
  switch (status) {
    case StaffSeatAvailability.booked:
      return const _SeatVisualStyle(
        background: Color(0xFFE6F4EA),
        border: Color(0xFF1F8F4C),
        foreground: Color(0xFF14532D),
      );
    case StaffSeatAvailability.available:
      return const _SeatVisualStyle(
        background: Color(0xFFFFF3EE),
        border: AppColors.secondary,
        foreground: AppColors.onSurface,
      );
    case StaffSeatAvailability.disabled:
      return const _SeatVisualStyle(
        background: Color(0xFFD4DAE3),
        border: Color(0xFF9CA8B8),
        foreground: AppColors.onSurfaceVariant,
      );
    case StaffSeatAvailability.unknown:
      return const _SeatVisualStyle(
        background: AppColors.surfaceContainer,
        border: AppColors.outlineVariant,
        foreground: AppColors.onSurfaceVariant,
      );
  }
}

bool _isBetterCandidate(
  _LayoutSeatCandidate next,
  _LayoutSeatCandidate current,
) {
  final nextScore = (next.row != null ? 1 : 0) + (next.column != null ? 1 : 0);
  final currentScore =
      (current.row != null ? 1 : 0) + (current.column != null ? 1 : 0);
  if (nextScore != currentScore) {
    return nextScore > currentScore;
  }
  return (next.deck ?? 0) < (current.deck ?? 0);
}

int? _extractInt(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return null;
}

String? _extractString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
  }
  return null;
}

String _normalizeSeatKey(String value) {
  return value.trim().toUpperCase();
}

_SeatLabelParts _parseSeatLabel(String seatNumber) {
  final normalized = seatNumber.trim().toUpperCase();
  if (normalized.isEmpty) {
    return const _SeatLabelParts();
  }

  final alphaNumeric = RegExp(r'^([A-Z]+)(\d+)$');
  final alphaNumericMatch = alphaNumeric.firstMatch(normalized);
  if (alphaNumericMatch != null) {
    final letters = alphaNumericMatch.group(1) ?? '';
    final digits = alphaNumericMatch.group(2) ?? '';
    var row = 0;
    for (final codeUnit in letters.codeUnits) {
      row = row * 26 + (codeUnit - 64);
    }
    final column = int.tryParse(digits);
    return _SeatLabelParts(row: row > 0 ? row : null, column: column);
  }

  final numeric = RegExp(r'^(\d+)$');
  final numericMatch = numeric.firstMatch(normalized);
  if (numericMatch != null) {
    return _SeatLabelParts(column: int.tryParse(numericMatch.group(1) ?? ''));
  }

  return const _SeatLabelParts();
}

int _seatSort(String left, String right) {
  final leftParts = _parseSeatLabel(left);
  final rightParts = _parseSeatLabel(right);
  final leftRow = leftParts.row ?? (1 << 30);
  final rightRow = rightParts.row ?? (1 << 30);
  if (leftRow != rightRow) {
    return leftRow.compareTo(rightRow);
  }
  final leftColumn = leftParts.column ?? (1 << 30);
  final rightColumn = rightParts.column ?? (1 << 30);
  if (leftColumn != rightColumn) {
    return leftColumn.compareTo(rightColumn);
  }
  return left.compareTo(right);
}

class _ShowtimeStatusStyle {
  const _ShowtimeStatusStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}

_ShowtimeStatusStyle _showtimeStatusStyle(StaffBusShowtimeStatus status) {
  switch (status) {
    case StaffBusShowtimeStatus.scheduled:
      return const _ShowtimeStatusStyle(
        label: 'Scheduled',
        background: Color(0xFFE8F0FE),
        foreground: Color(0xFF1E40AF),
      );
    case StaffBusShowtimeStatus.active:
      return const _ShowtimeStatusStyle(
        label: 'Active',
        background: Color(0xFFDCFCE7),
        foreground: Color(0xFF166534),
      );
    case StaffBusShowtimeStatus.delayed:
      return const _ShowtimeStatusStyle(
        label: 'Delayed',
        background: Color(0xFFFFF3C6),
        foreground: Color(0xFF92400E),
      );
    case StaffBusShowtimeStatus.cancelled:
      return const _ShowtimeStatusStyle(
        label: 'Cancelled',
        background: Color(0xFFFEE2E2),
        foreground: Color(0xFF991B1B),
      );
    case StaffBusShowtimeStatus.hidden:
      return const _ShowtimeStatusStyle(
        label: 'Hidden',
        background: Color(0xFFE5E7EB),
        foreground: Color(0xFF374151),
      );
    case StaffBusShowtimeStatus.complete:
      return const _ShowtimeStatusStyle(
        label: 'Complete',
        background: Color(0xFFEDE9FE),
        foreground: Color(0xFF5B21B6),
      );
    case StaffBusShowtimeStatus.unknown:
      return const _ShowtimeStatusStyle(
        label: 'Unknown',
        background: Color(0xFFE5E7EB),
        foreground: Color(0xFF374151),
      );
  }
}

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return 'Đang cập nhật';
  }
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute - $day/$month/${value.year}';
}

class _MissingDetailArgsScreen extends StatelessWidget {
  const _MissingDetailArgsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Vận hành ghế'),
      ),
      body: const Center(
        child: Text('Không có dữ liệu chuyến để thực hiện vận hành ghế.'),
      ),
    );
  }
}

Widget buildStaffSeatCheckinDetailRouteView(Object? extra) {
  if (extra is StaffSeatCheckinDetailArgs) {
    return StaffSeatCheckinDetailScreen(args: extra);
  }
  return const _MissingDetailArgsScreen();
}
