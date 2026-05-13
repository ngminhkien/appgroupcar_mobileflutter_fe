import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.surfaceContainerLow,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Chuyến của tôi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.primaryContainer,
            labelColor: AppColors.primaryContainer,
            unselectedLabelColor: AppColors.outline,
            tabs: [
              Tab(text: 'Đang chạy'),
              Tab(text: 'Đã qua'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTripList(isActive: true),
            _buildTripList(isActive: false),
          ],
        ),
        bottomNavigationBar: const AppBottomNavBar(),
      ),
    );
  }

  Widget _buildTripList({required bool isActive}) {
    return ListView.builder(
      padding: EdgeInsets.all(24.w),
      itemCount: isActive ? 2 : 5,
      itemBuilder: (context, index) {
        return _buildTripCard(isActive: isActive);
      },
    );
  }

  Widget _buildTripCard({required bool isActive}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Oct 24, 2023',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12.sp,
                ),
              ),
              Text(
                isActive ? 'Đang di chuyển' : 'Hoàn thành',
                style: TextStyle(
                  color: isActive ? AppColors.secondary : AppColors.outline,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Column(
                children: [
                  Icon(
                    Icons.circle,
                    size: 12.sp,
                    color: AppColors.primaryContainer,
                  ),
                  Container(
                    width: 2,
                    height: 30.h,
                    color: AppColors.outlineVariant,
                  ),
                  Icon(
                    Icons.location_on,
                    size: 16.sp,
                    color: isActive
                        ? AppColors.error
                        : AppColors.primaryContainer,
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New York, NY',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Los Angeles, CA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$450',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                  color: AppColors.primaryContainer,
                ),
              ),
            ],
          ),
          if (isActive) ...[
            SizedBox(height: 16.h),
            const Divider(),
            SizedBox(height: 8.h),
            Row(
              children: [
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: AppColors.surfaceContainer,
                  child: const Icon(
                    Icons.person,
                    size: 16,
                    color: AppColors.outline,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Tài xế: John D.',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('Theo dõi')),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
