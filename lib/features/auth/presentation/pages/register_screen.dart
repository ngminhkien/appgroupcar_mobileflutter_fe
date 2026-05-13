import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection.dart';
import '../bloc/register_bloc.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RegisterBloc>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == RegisterStatus.failure) {
          final message =
              state.errorMessage?.replaceFirst('Exception: ', '') ??
              'Đăng ký thất bại';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }

        if (state.status == RegisterStatus.success) {
          final message = state.successMessage ?? 'Đăng ký thành công';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          Future<void>.delayed(const Duration(milliseconds: 650), () {
            if (context.mounted) {
              context.go('/login');
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Đăng ký tài khoản'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tạo tài khoản khách hàng',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryContainer,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Sau khi đăng ký, bạn có thể đăng nhập để mua vé, quản lý hồ sơ và gửi yêu cầu trở thành tài xế hoặc doanh nghiệp trong phần Cá nhân.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 20.h),
                const _CustomerRegisterForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomerRegisterForm extends StatefulWidget {
  const _CustomerRegisterForm();

  @override
  State<_CustomerRegisterForm> createState() => _CustomerRegisterFormState();
}

class _CustomerRegisterFormState extends State<_CustomerRegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        final isLoading = state.status == RegisterStatus.loading;
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AvatarPicker(
                  avatarPath: state.avatarPath,
                  isLoading: isLoading,
                  onPick: _pickAvatar,
                  onClear: () => context.read<RegisterBloc>().add(
                    const RegisterAvatarChanged(),
                  ),
                ),
                SizedBox(height: 18.h),
                TextFormField(
                  controller: _fullNameController,
                  enabled: !isLoading,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _validateFullName,
                  decoration: const InputDecoration(
                    labelText: 'Họ tên',
                    hintText: 'Nguyễn Văn A',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                SizedBox(height: 14.h),
                TextFormField(
                  controller: _emailController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _validateEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'user@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                SizedBox(height: 14.h),
                TextFormField(
                  controller: _phoneController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _validatePhoneNumber,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    hintText: '0123456789',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                SizedBox(height: 14.h),
                TextFormField(
                  controller: _passwordController,
                  enabled: !isLoading,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    hintText: 'Tối thiểu 6 ký tự',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: isLoading
                          ? null
                          : () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                    ),
                  ),
                  onFieldSubmitted: (_) {
                    if (!isLoading) {
                      _onRegisterPressed(state.avatarPath);
                    }
                  },
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () => _onRegisterPressed(state.avatarPath),
                  child: isLoading
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Text('Đăng ký'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAvatar() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (!mounted || image == null) {
        return;
      }
      if (!_isValidImagePath(image.path)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ảnh đại diện không đúng định dạng')),
        );
        return;
      }
      context.read<RegisterBloc>().add(
        RegisterAvatarChanged(avatarPath: image.path),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở thư viện ảnh')),
      );
    }
  }

  void _onRegisterPressed(String? avatarPath) {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    if (!_isValidImagePath(avatarPath)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ảnh đại diện không đúng định dạng')),
      );
      return;
    }
    context.read<RegisterBloc>().add(
      RegisterSubmitted(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
        avatarPath: avatarPath,
      ),
    );
  }

  String? _validateFullName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Vui lòng nhập họ tên';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Vui lòng nhập email';
    }
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!regex.hasMatch(text)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final regex = RegExp(r'^[0-9]{9,11}$');
    if (!regex.hasMatch(text)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final text = value ?? '';
    if (text.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  bool _isValidImagePath(String? path) {
    if (path == null || path.isEmpty) {
      return true;
    }
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.heic');
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.avatarPath,
    required this.isLoading,
    required this.onPick,
    required this.onClear,
  });

  final String? avatarPath;
  final bool isLoading;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final avatarName = avatarPath == null ? null : _fileName(avatarPath!);
    return InkWell(
      onTap: isLoading ? null : onPick,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: AppColors.secondaryContainer,
              child: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    avatarName ?? 'Ảnh đại diện',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    avatarName == null ? 'Tùy chọn' : 'Đã chọn từ Photos',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (avatarName == null)
              const Icon(
                Icons.photo_library_outlined,
                color: AppColors.onSurfaceVariant,
              )
            else
              IconButton(
                onPressed: isLoading ? null : onClear,
                icon: const Icon(Icons.close),
                tooltip: 'Bỏ ảnh',
              ),
          ],
        ),
      ),
    );
  }

  String _fileName(String path) {
    final parts = path.split(RegExp(r'[\\/]'));
    return parts.isEmpty ? path : parts.last;
  }
}
