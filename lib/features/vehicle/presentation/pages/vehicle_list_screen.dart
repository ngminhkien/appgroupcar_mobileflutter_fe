import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/vehicle.dart';
import '../cubit/vehicle_cubit.dart';
import '../cubit/vehicle_state.dart';

class VehicleListScreen extends StatelessWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VehicleCubit>()..loadMyVehicles(),
      child: const _VehicleListView(),
    );
  }
}

class _VehicleListView extends StatelessWidget {
  const _VehicleListView();

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
          'Phương tiện của tôi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => _openCreateVehicle(context),
            icon: const Icon(Icons.add),
            tooltip: 'Thêm xe',
          ),
        ],
      ),
      body: BlocBuilder<VehicleCubit, VehicleState>(
        builder: (context, state) {
          switch (state.status) {
            case VehicleStatus.loading:
            case VehicleStatus.submitting:
              return const _VehicleLoadingList();
            case VehicleStatus.failure:
              return _VehicleError(message: state.errorMessage);
            case VehicleStatus.empty:
              return _VehicleEmpty(onCreate: () => _openCreateVehicle(context));
            case VehicleStatus.success:
              if (state.vehicles.isEmpty) {
                return _VehicleEmpty(
                  onCreate: () => _openCreateVehicle(context),
                );
              }
              return RefreshIndicator(
                onRefresh: () => context.read<VehicleCubit>().loadMyVehicles(),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
                  itemBuilder: (context, index) {
                    final vehicle = state.vehicles[index];
                    return _VehicleCard(
                      vehicle: vehicle,
                      onEdit: () => _openEditVehicle(context, vehicle),
                    );
                  },
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemCount: state.vehicles.length,
                ),
              );
            case VehicleStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }

  Future<void> _openCreateVehicle(BuildContext context) async {
    final shouldReload = await context.push<bool>(
      '/profile/driver/vehicles/create',
    );
    if (shouldReload == true && context.mounted) {
      context.read<VehicleCubit>().loadMyVehicles();
    }
  }

  Future<void> _openEditVehicle(BuildContext context, Vehicle vehicle) async {
    final shouldReload = await context.push<bool>(
      '/profile/driver/vehicles/${vehicle.id}/edit',
      extra: vehicle,
    );
    if (shouldReload == true && context.mounted) {
      context.read<VehicleCubit>().loadMyVehicles();
    }
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle, required this.onEdit});

  final Vehicle vehicle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _VehicleImage(url: vehicle.urlImage),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.plateNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _VehicleStatusChip(vehicle: vehicle),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    vehicle.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: [
                      _VehicleMeta(
                        icon: Icons.event_seat_outlined,
                        label: '${vehicle.seatCapacity} chỗ',
                      ),
                      _VehicleMeta(
                        icon: Icons.directions_car_outlined,
                        label: vehicle.vehicleTypeLabel,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Cập nhật xe',
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleImage extends StatelessWidget {
  const _VehicleImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _normalizeImageUrl(url);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: 82.w,
        height: 72.h,
        color: AppColors.surfaceContainerLow,
        child: imageUrl == null
            ? Icon(
                Icons.directions_car_outlined,
                size: 32.sp,
                color: AppColors.onSurfaceVariant,
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.directions_car_outlined,
                  size: 32.sp,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
      ),
    );
  }

  String? _normalizeImageUrl(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(text);
    if (uri != null && uri.hasScheme) {
      return text;
    }
    return Uri.parse(ApiConstants.baseUrl).resolve(text).toString();
  }
}

class _VehicleStatusChip extends StatelessWidget {
  const _VehicleStatusChip({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final color = vehicle.isActive
        ? Colors.green
        : vehicle.isRejected
        ? AppColors.error
        : vehicle.isInactive
        ? AppColors.outline
        : AppColors.secondary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        vehicle.statusLabel,
        style: TextStyle(
          color: color,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _VehicleMeta extends StatelessWidget {
  const _VehicleMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.onSurfaceVariant),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleLoadingList extends StatelessWidget {
  const _VehicleLoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
      itemBuilder: (_, __) => Container(
        height: 104.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Center(
          child: SizedBox(
            width: 22.w,
            height: 22.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemCount: 4,
    );
  }
}

class _VehicleEmpty extends StatelessWidget {
  const _VehicleEmpty({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36.r,
              backgroundColor: AppColors.secondaryContainer,
              child: Icon(
                Icons.directions_car_filled_outlined,
                color: AppColors.secondary,
                size: 34.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Chưa có xe nào',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Thêm phương tiện để gửi thông tin xe và giấy đăng ký cho admin duyệt.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 18.h),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Thêm xe'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleError extends StatelessWidget {
  const _VehicleError({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text =
        message?.replaceFirst('Exception: ', '') ??
        'Không thể tải danh sách xe';
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => context.read<VehicleCubit>().loadMyVehicles(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
