import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../di/injection.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/staff_upcoming_showtime.dart';
import '../cubit/staff_showtime_list_cubit.dart';
import '../cubit/staff_showtime_list_state.dart';
import '../models/staff_seat_checkin_detail_args.dart';

class StaffShowtimeCheckinScreen extends StatelessWidget {
  const StaffShowtimeCheckinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StaffShowtimeListCubit>()..initialize(),
      child: const _StaffShowtimeCheckinView(),
    );
  }
}

class _StaffShowtimeCheckinView extends StatelessWidget {
  const _StaffShowtimeCheckinView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffShowtimeListCubit, StaffShowtimeListState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          (current.errorMessage?.isNotEmpty ?? false),
      listener: (context, state) {
        final message =
            state.errorMessage?.replaceFirst('Exception: ', '') ??
            'Không thể tải danh sách chuyến';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        context.read<StaffShowtimeListCubit>().clearErrorMessage();
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceContainerLow,
        appBar: AppBar(
          title: const Text(
            'Van hanh ghe',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              tooltip: 'Hồ sơ',
              onPressed: () => context.push('/profile'),
              icon: const Icon(Icons.person_outline),
            ),
            IconButton(
              tooltip: 'Đăng xuất',
              onPressed: () async {
                await context.read<AuthCubit>().logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: BlocBuilder<StaffShowtimeListCubit, StaffShowtimeListState>(
          builder: (context, state) {
            if (state.status == StaffShowtimeListStatus.loading &&
                state.items.isEmpty) {
              return const _LoadingList();
            }
            if (state.status == StaffShowtimeListStatus.failure &&
                state.items.isEmpty) {
              return _FailureView(
                message: state.errorMessage,
                onRetry: () => context.read<StaffShowtimeListCubit>().refresh(),
              );
            }
            return RefreshIndicator(
              onRefresh: () => context.read<StaffShowtimeListCubit>().refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
                children: [
                  _SummaryCard(
                    state: state,
                    onPickDate: () => _pickDate(context, state.fromDate),
                  ),
                  SizedBox(height: 12.h),
                  if (state.status == StaffShowtimeListStatus.loading)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: const LinearProgressIndicator(minHeight: 2),
                    ),
                  if (state.items.isEmpty)
                    const _EmptyView()
                  else
                    ...List.generate(state.items.length, (index) {
                      final showtime = state.items[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: _ShowtimeCard(
                          item: showtime,
                          onTap: () {
                            context.push(
                              '/staff/check-in/detail',
                              extra: StaffSeatCheckinDetailArgs(
                                showtime: showtime,
                              ),
                            );
                          },
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: const AppBottomNavBar(),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime currentDate) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: todayDate,
      lastDate: todayDate.add(const Duration(days: 60)),
    );
    if (selectedDate == null || !context.mounted) {
      return;
    }
    context.read<StaffShowtimeListCubit>().setFromDate(selectedDate);
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.state, required this.onPickDate});

  final StaffShowtimeListState state;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final activeCount = state.items
        .where((item) => item.showtimeStatus == StaffBusShowtimeStatus.active)
        .length;
    final delayedCount = state.items
        .where((item) => item.showtimeStatus == StaffBusShowtimeStatus.delayed)
        .length;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3EE), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
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
                      'Lich chay de van hanh',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Từ ngày ${_formatDate(state.fromDate)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: onPickDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: const Text('Đổi ngày'),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _SummaryChip(
                icon: Icons.directions_bus_outlined,
                label: 'Tổng chuyến: ${state.items.length}',
              ),
              _SummaryChip(
                icon: Icons.play_circle_outline,
                label: 'Dang chay: $activeCount',
                highlighted: true,
              ),
              _SummaryChip(
                icon: Icons.schedule_outlined,
                label: 'Tre gio: $delayedCount',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
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
          Icon(icon, size: 14.sp, color: foreground),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShowtimeCard extends StatelessWidget {
  const _ShowtimeCard({required this.item, required this.onTap});

  final StaffUpcomingShowtime item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusStyle = _showtimeStatusStyle(item.showtimeStatus);
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: statusStyle.background,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    statusStyle.label,
                    style: TextStyle(
                      color: statusStyle.foreground,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.outline,
                  size: 20.sp,
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              item.routeName.trim().isEmpty
                  ? 'Tuyến chưa cập nhật'
                  : item.routeName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '${_formatDateTime(item.departureDateTime)} - ${item.plateNumber.trim().isEmpty ? 'Đang cập nhật biển số' : item.plateNumber.trim()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _MiniInfoChip(
                  icon: Icons.person_outline,
                  label: item.driverName.trim().isEmpty
                      ? 'Tài xế chưa cập nhật'
                      : item.driverName.trim(),
                ),
                _MiniInfoChip(
                  icon: Icons.event_seat_outlined,
                  label: '${item.seatCount} ghế',
                ),
                _MiniInfoChip(
                  icon: Icons.sell_outlined,
                  label: _formatMoney(item.price),
                  highlighted: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniInfoChip extends StatelessWidget {
  const _MiniInfoChip({
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
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: foreground),
          SizedBox(width: 5.w),
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

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
      itemBuilder: (_, __) => Container(
        height: 146.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemCount: 4,
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final text =
        message?.replaceFirst('Exception: ', '') ??
        'Không thể tải danh sách chuyến';
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 40.sp, color: AppColors.error),
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

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 26.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 40.sp,
            color: AppColors.outline,
          ),
          SizedBox(height: 8.h),
          Text(
            'Không có chuyến nào từ ngày đã chọn',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Hãy đổi ngày hoặc kéo xuống để tải lại.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
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

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return 'Đang cập nhật giờ';
  }
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute - $day/$month';
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
  return '$number đ';
}
