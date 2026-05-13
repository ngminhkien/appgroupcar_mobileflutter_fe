import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Lấy lại mật khẩu'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nhập email để nhận liên kết đặt lại mật khẩu.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 16.h),
              const TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Nhập email của bạn',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Gửi liên kết'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
