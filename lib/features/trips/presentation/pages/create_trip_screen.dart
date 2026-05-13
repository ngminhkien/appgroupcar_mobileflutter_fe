import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';

class CreateTripScreen extends StatelessWidget {
  const CreateTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        title: const Text(
          'Tạo chuyến đi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(24.w),
        children: [
          _buildHintCard(
            title: 'Thiết lập chuyến mới',
            subtitle:
                'Chọn loại dịch vụ, thời gian, lộ trình và số chỗ để bắt đầu.',
          ),
          SizedBox(height: 16.h),
          _buildPlaceholderField('Loại dịch vụ', 'Chọn dịch vụ'),
          SizedBox(height: 12.h),
          _buildPlaceholderField('Điểm đi', 'Chọn địa điểm'),
          SizedBox(height: 12.h),
          _buildPlaceholderField('Điểm đến', 'Chọn địa điểm'),
          SizedBox(height: 12.h),
          _buildPlaceholderField('Thời gian khởi hành', 'Chọn ngày và giờ'),
          SizedBox(height: 12.h),
          _buildPlaceholderField('Số chỗ trống', 'Nhập số chỗ'),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.onSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Tạo chuyến (demo)',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }

  Widget _buildHintCard({required String title, required String subtitle}) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.surfaceContainerLow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderField(String label, String placeholder) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.surfaceContainerLow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            placeholder,
            style: TextStyle(fontSize: 14.sp, color: AppColors.outline),
          ),
        ],
      ),
    );
  }
}
