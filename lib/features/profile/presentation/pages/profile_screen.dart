import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role =
        context.select((AuthCubit cubit) => cubit.state.role)?.toUpperCase() ??
        'USER';
    final isDriver = role == 'DRIVER';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Cá nhân',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
          children: [
            _ProfileHeader(role: role),
            SizedBox(height: 20.h),
            _ProfileMenuSection(
              children: [
                _ProfileMenuItem(
                  icon: Icons.badge_outlined,
                  title: 'Thông tin của tôi',
                  subtitle: 'Xem họ tên, email, số điện thoại và vai trò',
                  onTap: () => context.push('/profile/me'),
                ),
                _ProfileMenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Ví',
                  subtitle: 'Quản lý số dư và lịch sử giao dịch',
                  onTap: () => context.push('/profile/wallet'),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            _ProfileMenuSection(
              children: [
                _ProfileMenuItem(
                  icon: isDriver
                      ? Icons.verified_user_outlined
                      : Icons.drive_eta_outlined,
                  title: isDriver ? 'Hồ sơ tài xế' : 'Đăng ký trở thành tài xế',
                  subtitle: isDriver
                      ? 'Xem trạng thái và giấy phép lái xe'
                      : 'Gửi hồ sơ để được duyệt quyền tạo chuyến',
                  trailingText: isDriver ? 'Đã duyệt' : null,
                  onTap: () => context.push('/profile/driver/apply'),
                ),
                if (isDriver)
                  _ProfileMenuItem(
                    icon: Icons.directions_car_outlined,
                    title: 'Phương tiện của tôi',
                    subtitle: 'Quản lý xe, ảnh xe và giấy đăng ký',
                    onTap: () => context.push('/profile/driver/vehicles'),
                  ),
                if (isDriver)
                  _ProfileMenuItem(
                    icon: Icons.add_road_outlined,
                    title: 'Tạo chuyến đi',
                    subtitle: 'Tạo offer chuyến đi cho khách hàng',
                    onTap: () => context.push('/create_trip'),
                  ),
              ],
            ),
            SizedBox(height: 14.h),
            _ProfileMenuSection(
              children: [
                _ProfileMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Cài đặt',
                  subtitle: 'Tùy chỉnh ứng dụng và bảo mật',
                  onTap: () => context.push('/profile/settings'),
                ),
                _ProfileMenuItem(
                  icon: Icons.logout,
                  title: 'Đăng xuất',
                  subtitle: 'Thoát khỏi tài khoản hiện tại',
                  onTap: () async {
                    try {
                      await context.read<AuthCubit>().logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }
                      final message = error.toString().replaceFirst(
                        'Exception: ',
                        '',
                      );
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(message)));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final displayRole = switch (role) {
      'DRIVER' => 'USER + DRIVER',
      'COMPANY' => 'USER + COMPANY',
      _ => 'USER',
    };
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: AppColors.secondaryContainer,
            child: Icon(Icons.person, size: 28.sp, color: AppColors.secondary),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tài khoản của tôi',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Vai trò hiện tại: $displayRole',
                  style: TextStyle(
                    fontSize: 13.sp,
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

class _ProfileMenuSection extends StatelessWidget {
  const _ProfileMenuSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingText,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: AppColors.primaryContainer, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingText != null) ...[
              SizedBox(width: 8.w),
              Text(
                trailingText!,
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right, color: AppColors.outline, size: 22.sp),
          ],
        ),
      ),
    );
  }
}

