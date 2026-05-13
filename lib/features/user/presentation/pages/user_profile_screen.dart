import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../di/injection.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../bloc/user_profile_cubit.dart';
import '../bloc/user_profile_state.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UserProfileCubit>()..loadProfile(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Ca nhan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<UserProfileCubit, UserProfileState>(
          builder: (context, state) {
            switch (state.status) {
              case UserProfileStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case UserProfileStatus.failure:
                return _buildErrorState(context, state.errorMessage);
              case UserProfileStatus.success:
                if (state.profile == null) {
                  return _buildErrorState(context, 'Khong co du lieu');
                }
                return _buildProfileContent(context, state);
              case UserProfileStatus.initial:
                return const SizedBox.shrink();
            }
          },
        ),
        bottomNavigationBar: const AppBottomNavBar(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? message) {
    final text =
        message?.replaceFirst('Exception: ', '') ??
        'Khong the tai thong tin ca nhan';
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
              child: const Text('Thu lai'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfileState state) {
    final profile = state.profile!;
    final displayName = profile.fullName.isNotEmpty
        ? profile.fullName
        : (profile.email.isNotEmpty ? profile.email : 'Nguoi dung');
    final phone = profile.phoneNumber?.isNotEmpty == true
        ? profile.phoneNumber!
        : 'Chua cap nhat';
    final roles = profile.roles.isNotEmpty
        ? profile.roles.join(', ')
        : 'Chua ro';

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
          _buildInfoTile(label: 'Email', value: profile.email),
          SizedBox(height: 12.h),
          _buildInfoTile(label: 'So dien thoai', value: phone),
          SizedBox(height: 12.h),
          _buildInfoTile(label: 'Vai tro', value: roles),
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
                        'Dang xuat that bai';
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  },
            icon: const Icon(Icons.logout),
            label: Text(state.isLoggingOut ? 'Dang xuat...' : 'Dang xuat'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({required String label, required String value}) {
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
