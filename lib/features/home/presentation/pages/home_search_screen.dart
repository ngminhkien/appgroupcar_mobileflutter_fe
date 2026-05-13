import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class HomeSearchScreen extends StatelessWidget {
  const HomeSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Tìm chuyến',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.surfaceContainerLow),
              ),
              child: Column(
                children: [
                  _buildSearchField(
                    icon: Icons.my_location,
                    hint: 'Điểm đón',
                    value: 'New York, NY',
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 2,
                        height: 24.h,
                        color: AppColors.outlineVariant,
                      ),
                    ),
                  ),
                  _buildSearchField(
                    icon: Icons.location_on,
                    hint: 'Điểm đến',
                    value: '',
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          icon: Icons.calendar_today,
                          label: 'Date',
                          value: 'Today',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildDateField(
                          icon: Icons.monitor_weight_outlined,
                          label: 'Số ghế',
                          value: '4 chỗ',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Loại xe',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildVehicleChip('Xe 4 chỗ', Icons.directions_car, true),
                  _buildVehicleChip('Xe 7 chỗ', Icons.local_shipping, false),
                  _buildVehicleChip('Xe đường dài', Icons.rv_hookup, false),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: ElevatedButton(
            onPressed: () => context.push('/search_results'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              'Tìm tài xế phù hợp',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField({
    required IconData icon,
    required String hint,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryContainer, size: 24.sp),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hint,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value.isEmpty ? 'Chọn địa điểm' : value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: value.isEmpty
                      ? FontWeight.normal
                      : FontWeight.bold,
                  color: value.isEmpty
                      ? AppColors.outline
                      : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.primaryContainer),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleChip(String label, IconData icon, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryContainer
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryContainer
              : AppColors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
