import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../di/injection.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../user/presentation/bloc/user_profile_cubit.dart';
import '../../../user/presentation/bloc/user_profile_state.dart';

class MyInformationScreen extends StatelessWidget {
  const MyInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UserProfileCubit>()..loadProfile(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Thông tin của tôi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<UserProfileCubit, UserProfileState>(
          builder: (context, state) {
            switch (state.status) {
              case UserProfileStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case UserProfileStatus.failure:
                return _ErrorState(message: state.errorMessage);
              case UserProfileStatus.success:
                final profile = state.profile;
                if (profile == null) {
                  return const _ErrorState(message: 'Không có dữ liệu');
                }
                return _InformationContent(state: state);
              case UserProfileStatus.initial:
                return const SizedBox.shrink();
            }
          },
        ),
        bottomNavigationBar: const AppBottomNavBar(),
      ),
    );
  }
}

class _InformationContent extends StatelessWidget {
  const _InformationContent({required this.state});

  final UserProfileState state;

  @override
  Widget build(BuildContext context) {
    final profile = state.profile!;
    final displayName = profile.fullName.isNotEmpty
        ? profile.fullName
        : (profile.email.isNotEmpty ? profile.email : 'Người dùng');
    final phone = profile.phoneNumber?.isNotEmpty == true
        ? profile.phoneNumber!
        : 'Chưa cập nhật';
    final roles = profile.roles.isNotEmpty
        ? profile.roles.join(', ')
        : 'Chưa rõ';

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32.r,
                  backgroundColor: AppColors.secondaryContainer,
                  child: Icon(
                    Icons.person,
                    color: AppColors.secondary,
                    size: 32.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        profile.email,
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          _InfoTile(label: 'Mã người dùng', value: profile.id),
          SizedBox(height: 12.h),
          _InfoTile(label: 'Email', value: profile.email),
          SizedBox(height: 12.h),
          _InfoTile(label: 'Số điện thoại', value: phone),
          SizedBox(height: 12.h),
          _InfoTile(label: 'Vai trò', value: roles),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: state.isLoggingOut
                ? null
                : () async {
                    final cubit = context.read<UserProfileCubit>();
                    final success = await cubit.logout();
                    if (!context.mounted) {
                      return;
                    }
                    if (success) {
                      context.read<AuthCubit>().setUnauthenticated();
                      context.go('/login');
                      return;
                    }
                    final message =
                        cubit.state.errorMessage?.replaceFirst(
                          'Exception: ',
                          '',
                        ) ??
                        'Đăng xuất thất bại';
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  },
            icon: const Icon(Icons.logout),
            label: Text(state.isLoggingOut ? 'Đang đăng xuất...' : 'Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text =
        message?.replaceFirst('Exception: ', '') ??
        'Không thể tải thông tin cá nhân';
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
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
              onPressed: () => context.read<UserProfileCubit>().loadProfile(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.surfaceContainerLow),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 13.sp,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
