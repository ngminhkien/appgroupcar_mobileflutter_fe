import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/trip_detail_navigation_args.dart';

class TripDetailPlaceholderScreen extends StatelessWidget {
  const TripDetailPlaceholderScreen({super.key, required this.args});

  final TripDetailNavigationArgs args;

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
          'Chi tiet chuyen',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Service code: ${args.serviceCode}',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 10.h),
              Text(
                'Trip id: ${args.tripId}',
                style: TextStyle(fontSize: 13.sp),
              ),
              SizedBox(height: 10.h),
              Text(
                'Detail API: ${args.detailApi}',
                style: TextStyle(fontSize: 13.sp),
              ),
              SizedBox(height: 14.h),
              Text(
                'Man hinh nay dung de dieu huong theo serviceCode + detailApi. '
                'Ban co the gan tiep den flow chi tiet tuong ung o buoc tiep theo.',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
