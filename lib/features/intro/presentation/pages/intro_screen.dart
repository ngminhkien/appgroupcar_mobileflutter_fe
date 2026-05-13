import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _logoController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  String _nextRoute = '/login';

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );
    _logoController.forward();
    _prepareNavigation();
  }

  Future<void> _prepareNavigation() async {
    final authCubit = sl<AuthCubit>();
    final refreshed = await authCubit.refreshSession();
    if (!mounted) {
      return;
    }
    _nextRoute = refreshed ? '/home' : '/login';
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      context.go(_nextRoute);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background,
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                'assets/images/logoGroupCar.png',
                width: 0.7.sw,
                height: 0.7.sw,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
