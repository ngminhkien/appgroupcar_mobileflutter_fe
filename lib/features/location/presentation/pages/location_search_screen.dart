import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Tìm địa điểm...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            hintStyle: TextStyle(color: AppColors.outline, fontSize: 16.sp),
          ),
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => _searchController.clear(),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        children: [
          _buildLocationItem(
            Icons.my_location,
            'Vị trí hiện tại',
            'Đang dùng GPS',
            isCurrent: true,
          ),
          const Divider(height: 1, color: AppColors.surfaceContainer),
          _buildLocationItem(
            Icons.history,
            'Port of Los Angeles',
            'San Pedro, CA 90731',
          ),
          const Divider(height: 1, color: AppColors.surfaceContainer),
          _buildLocationItem(
            Icons.history,
            'JFK Cargo Terminal',
            'Queens, NY 11430',
          ),
          const Divider(height: 1, color: AppColors.surfaceContainer),
          _buildLocationItem(
            Icons.location_on,
            'Chicago Hare Logistics Center',
            'Chicago, IL 60666',
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem(
    IconData icon,
    String title,
    String subtitle, {
    bool isCurrent = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.secondaryContainer.withValues(alpha: 0.2)
              : AppColors.surfaceContainerLow,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isCurrent ? AppColors.secondary : AppColors.outline,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
          color: isCurrent ? AppColors.secondary : AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp),
      ),
      onTap: () {
        context.pop(title);
      },
    );
  }
}
