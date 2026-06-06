import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';

class DriverDashboardScreen extends StatelessWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_DashboardItem> items = [
      _DashboardItem(
        title: 'Tạo chuyến',
        icon: Icons.add_circle_outline,
        color: AppColors.primary,
        route: '/create_trip',
      ),
      _DashboardItem(
        title: 'Xem yêu cầu khách hàng',
        icon: Icons.people_outline,
        color: AppColors.secondary,
        route:
            '/driver/placeholder?title=Yêu cầu của khách&message=Chức năng xem danh sách yêu cầu của khách hàng đang được phát triển.',
      ),
      _DashboardItem(
        title: 'Duyệt khách',
        icon: Icons.assignment_turned_in_outlined,
        color: Colors.green,
        route:
            '/driver/placeholder?title=Duyệt khách&message=Chức năng duyệt hành khách đặt chỗ đang được phát triển.',
      ),
      _DashboardItem(
        title: 'Chuyến của tôi',
        icon: Icons.history,
        color: Colors.orange,
        route: '/my_trips',
      ),
      _DashboardItem(
        title: 'Đánh giá khách hàng',
        icon: Icons.star_outline,
        color: Colors.purple,
        route:
            '/driver/placeholder?title=Đánh giá khách hàng&message=Chức năng đánh giá khách hàng đang được phát triển.',
      ),
      _DashboardItem(
        title: 'Thống kê',
        icon: Icons.bar_chart_outlined,
        color: Colors.teal,
        route:
            '/driver/placeholder?title=Thống kê thu nhập&message=Chức năng thống kê thu nhập, số chuyến xe đang được phát triển.',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Tài xế',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderPanel(),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(20.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 1.15,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildGridCard(context, item);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }

  Widget _buildHeaderPanel() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trung tâm Tài xế',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Quản lý xe, lộ trình, duyệt hành khách và xem báo cáo thu nhập của bạn.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, _DashboardItem item) {
    return InkWell(
      onTap: () => context.push(item.route),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundColor: item.color.withValues(alpha: 0.12),
              child: Icon(item.icon, color: item.color, size: 24.sp),
            ),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  const _DashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}
