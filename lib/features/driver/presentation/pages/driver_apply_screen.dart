import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/driver_profile.dart';
import '../cubit/driver_apply_cubit.dart';
import '../cubit/driver_apply_state.dart';

class DriverApplyScreen extends StatelessWidget {
  const DriverApplyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DriverApplyCubit>()..checkExistingDriver(),
      child: const _DriverApplyView(),
    );
  }
}

class _DriverApplyView extends StatefulWidget {
  const _DriverApplyView();

  @override
  State<_DriverApplyView> createState() => _DriverApplyViewState();
}

class _DriverApplyViewState extends State<_DriverApplyView> {
  bool _isEditing = false;

  void _startEditing() {
    context.read<DriverApplyCubit>().changeLicenseDocument(null);
    setState(() => _isEditing = true);
  }

  void _stopEditing() {
    context.read<DriverApplyCubit>().changeLicenseDocument(null);
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DriverApplyCubit, DriverApplyState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == DriverApplyStatus.failure) {
          final message =
              state.errorMessage?.replaceFirst('Exception: ', '') ??
              'Không thể gửi hồ sơ tài xế';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
        if (state.status == DriverApplyStatus.success) {
          final message =
              state.successMessage ?? 'Đã gửi hồ sơ tài xế, vui lòng chờ duyệt';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          if (_isEditing && mounted) {
            setState(() => _isEditing = false);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Hồ sơ tài xế',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<DriverApplyCubit, DriverApplyState>(
          builder: (context, state) {
            if (state.status == DriverApplyStatus.checking) {
              return const Center(child: CircularProgressIndicator());
            }

            final driver = state.existingDriver;
            if (driver != null) {
              if (_isEditing) {
                return _DriverForm(
                  title: 'Cập nhật thông tin tài xế',
                  description: 'Điều chỉnh thông tin và gửi yêu cầu cập nhật.',
                  submitLabel: 'Cập nhật',
                  initialDriver: driver,
                  onCancel: _stopEditing,
                  onSubmit:
                      ({
                        required name,
                        required identityNumber,
                        required licenseNumber,
                        required licenseClass,
                        String? licenseDocumentImgPath,
                      }) {
                        context.read<DriverApplyCubit>().updateDriver(
                          name: name,
                          identityNumber: identityNumber,
                          licenseNumber: licenseNumber,
                          licenseClass: licenseClass,
                          verificationStatus: 1,
                          licenseDocumentImgPath: licenseDocumentImgPath,
                        );
                      },
                );
              }
              return _DriverStatusView(driver: driver, onEdit: _startEditing);
            }

            if (state.status == DriverApplyStatus.failure &&
                !state.hasCheckedExistingDriver) {
              return _DriverLookupError(message: state.errorMessage);
            }

            return _DriverForm(
              title: 'Đăng ký trở thành tài xế',
              description:
                  'Gửi hồ sơ để admin duyệt. Khi hồ sơ được duyệt, tài khoản của bạn sẽ có thêm quyền tạo chuyến đi.',
              submitLabel: 'Tạo tài xế',
              onSubmit:
                  ({
                    required name,
                    required identityNumber,
                    required licenseNumber,
                    required licenseClass,
                    String? licenseDocumentImgPath,
                  }) {
                    context.read<DriverApplyCubit>().submit(
                      name: name,
                      identityNumber: identityNumber,
                      licenseNumber: licenseNumber,
                      licenseClass: licenseClass,
                      licenseDocumentImgPath: licenseDocumentImgPath,
                    );
                  },
            );
          },
        ),
        bottomNavigationBar: const AppBottomNavBar(),
      ),
    );
  }
}

typedef DriverFormSubmit =
    void Function({
      required String name,
      required String identityNumber,
      required String licenseNumber,
      required String licenseClass,
      String? licenseDocumentImgPath,
    });

class _DriverForm extends StatefulWidget {
  const _DriverForm({
    required this.title,
    required this.description,
    required this.submitLabel,
    required this.onSubmit,
    this.initialDriver,
    this.onCancel,
  });

  final String title;
  final String description;
  final String submitLabel;
  final DriverFormSubmit onSubmit;
  final DriverProfile? initialDriver;
  final VoidCallback? onCancel;

  @override
  State<_DriverForm> createState() => _DriverFormState();
}

class _DriverFormState extends State<_DriverForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _identityNumberController;
  late final TextEditingController _licenseNumberController;
  late final TextEditingController _licenseClassController;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialDriver?.name ?? '',
    );
    _identityNumberController = TextEditingController(
      text: widget.initialDriver?.identityNumber ?? '',
    );
    _licenseNumberController = TextEditingController(
      text: widget.initialDriver?.licenseNumber ?? '',
    );
    _licenseClassController = TextEditingController(
      text: widget.initialDriver?.licenseClass ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _DriverForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDriver?.id != oldWidget.initialDriver?.id) {
      _nameController.text = widget.initialDriver?.name ?? '';
      _identityNumberController.text =
          widget.initialDriver?.identityNumber ?? '';
      _licenseNumberController.text = widget.initialDriver?.licenseNumber ?? '';
      _licenseClassController.text = widget.initialDriver?.licenseClass ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _identityNumberController.dispose();
    _licenseNumberController.dispose();
    _licenseClassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverApplyCubit, DriverApplyState>(
      builder: (context, state) {
        final isSubmitting = state.status == DriverApplyStatus.submitting;
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryContainer,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
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
                        _DocumentPicker(
                          documentPath: state.licenseDocumentImgPath,
                          isLoading: isSubmitting,
                          onPick: _pickLicenseDocument,
                          onClear: () => context
                              .read<DriverApplyCubit>()
                              .changeLicenseDocument(null),
                        ),
                        SizedBox(height: 18.h),
                        TextFormField(
                          controller: _nameController,
                          enabled: !isSubmitting,
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _validateName,
                          decoration: const InputDecoration(
                            labelText: 'Tên nhà xe',
                            hintText: 'Nguyễn Văn B',
                            prefixIcon: Icon(Icons.storefront_outlined),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        TextFormField(
                          controller: _identityNumberController,
                          enabled: !isSubmitting,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _validateIdentityNumber,
                          decoration: const InputDecoration(
                            labelText: 'Số CMND/CCCD',
                            hintText: '123456789',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        TextFormField(
                          controller: _licenseNumberController,
                          enabled: !isSubmitting,
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _validateLicenseNumber,
                          decoration: const InputDecoration(
                            labelText: 'Số GPLX',
                            hintText: 'A1234567',
                            prefixIcon: Icon(Icons.credit_card_outlined),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        TextFormField(
                          controller: _licenseClassController,
                          enabled: !isSubmitting,
                          textInputAction: TextInputAction.done,
                          textCapitalization: TextCapitalization.characters,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _validateLicenseClass,
                          decoration: const InputDecoration(
                            labelText: 'Hạng GPLX',
                            hintText: 'B2',
                            prefixIcon: Icon(Icons.drive_eta_outlined),
                          ),
                          onFieldSubmitted: (_) {
                            if (!isSubmitting) {
                              _onSubmit(state.licenseDocumentImgPath);
                            }
                          },
                        ),
                        SizedBox(height: 20.h),
                        if (widget.onCancel == null)
                          ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => _onSubmit(state.licenseDocumentImgPath),
                            child: isSubmitting
                                ? SizedBox(
                                    width: 18.w,
                                    height: 18.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.onPrimary,
                                    ),
                                  )
                                : Text(widget.submitLabel),
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: isSubmitting
                                      ? null
                                      : widget.onCancel,
                                  child: const Text('Hủy'),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: isSubmitting
                                      ? null
                                      : () => _onSubmit(
                                          state.licenseDocumentImgPath,
                                        ),
                                  child: isSubmitting
                                      ? SizedBox(
                                          width: 18.w,
                                          height: 18.w,
                                          child:
                                              const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.onPrimary,
                                              ),
                                        )
                                      : Text(widget.submitLabel),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickLicenseDocument() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1400,
      );
      if (!mounted || image == null) {
        return;
      }
      if (!_isValidImagePath(image.path)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ảnh GPLX không đúng định dạng')),
        );
        return;
      }
      context.read<DriverApplyCubit>().changeLicenseDocument(image.path);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở thư viện ảnh')),
      );
    }
  }

  void _onSubmit(String? licenseDocumentImgPath) {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    if (!_isValidImagePath(licenseDocumentImgPath)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ảnh GPLX không đúng định dạng')),
      );
      return;
    }
    widget.onSubmit(
      name: _nameController.text.trim(),
      identityNumber: _identityNumberController.text.trim(),
      licenseNumber: _licenseNumberController.text.trim(),
      licenseClass: _licenseClassController.text.trim().toUpperCase(),
      licenseDocumentImgPath: licenseDocumentImgPath,
    );
  }

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Vui lòng nhập họ tên tài xế';
    }
    return null;
  }

  String? _validateIdentityNumber(String? value) {
    final text = value?.trim() ?? '';
    final regex = RegExp(r'^[0-9]{9,12}$');
    if (!regex.hasMatch(text)) {
      return 'Số CMND/CCCD không hợp lệ';
    }
    return null;
  }

  String? _validateLicenseNumber(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Vui lòng nhập số GPLX';
    }
    return null;
  }

  String? _validateLicenseClass(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Vui lòng nhập hạng GPLX';
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

class _DriverStatusView extends StatelessWidget {
  const _DriverStatusView({required this.driver, required this.onEdit});

  final DriverProfile driver;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundColor: AppColors.secondaryContainer,
                    child: Icon(
                      _statusIcon(driver),
                      color: AppColors.secondary,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.verificationStatusLabel,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _statusDescription(driver),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _DriverInfoTile(label: 'Tên nhà xe', value: driver.name),
            SizedBox(height: 10.h),
            _DriverInfoTile(
              label: 'Số CMND/CCCD',
              value: driver.identityNumber,
            ),
            SizedBox(height: 10.h),
            _DriverInfoTile(label: 'Số GPLX', value: driver.licenseNumber),
            SizedBox(height: 10.h),
            _DriverInfoTile(label: 'Hạng GPLX', value: driver.licenseClass),
            SizedBox(height: 10.h),
            _DriverInfoTile(
              label: 'Trạng thái',
              value: driver.verificationStatusLabel,
            ),
            if (driver.licenseDocumentUrl?.isNotEmpty == true) ...[
              SizedBox(height: 10.h),
              _DriverInfoTile(label: 'Ảnh GPLX', value: 'Đã tải lên'),
            ],
            SizedBox(height: 22.h),
            ElevatedButton.icon(
              onPressed: () => context.push('/profile/driver/vehicles'),
              icon: const Icon(Icons.directions_car_outlined),
              label: const Text('Quản lý xe'),
            ),
            SizedBox(height: 12.h),
            OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Cập nhật thông tin'),
            ),
            if (driver.isActive) ...[
              SizedBox(height: 12.h),
              ElevatedButton.icon(
                onPressed: () => context.push('/create_trip'),
                icon: const Icon(Icons.add_road_outlined),
                label: const Text('Tạo chuyến đi'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(DriverProfile driver) {
    if (driver.isActive) {
      return Icons.verified_user_outlined;
    }
    if (driver.isRejected) {
      return Icons.cancel_outlined;
    }
    if (driver.isInactive) {
      return Icons.pause_circle_outline;
    }
    return Icons.pending_actions_outlined;
  }

  String _statusDescription(DriverProfile driver) {
    if (driver.isActive) {
      return 'Hồ sơ đã được duyệt. Nếu token đã có role DRIVER, bạn có thể tạo chuyến đi.';
    }
    if (driver.isRejected) {
      return 'Hồ sơ bị từ chối. Vui lòng liên hệ hỗ trợ hoặc chờ chức năng cập nhật hồ sơ.';
    }
    if (driver.isInactive) {
      return 'Hồ sơ tài xế đang tạm ngưng, chưa thể tạo chuyến đi.';
    }
    return 'Hồ sơ đã được gửi và đang chờ admin duyệt.';
  }
}

class _DriverLookupError extends StatelessWidget {
  const _DriverLookupError({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text =
        message?.replaceFirst('Exception: ', '') ??
        'Không thể kiểm tra hồ sơ tài xế';
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
              onPressed: () =>
                  context.read<DriverApplyCubit>().checkExistingDriver(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentPicker extends StatelessWidget {
  const _DocumentPicker({
    required this.documentPath,
    required this.isLoading,
    required this.onPick,
    required this.onClear,
  });

  final String? documentPath;
  final bool isLoading;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final documentName = documentPath == null ? null : _fileName(documentPath!);
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
              child: const Icon(Icons.image_outlined, color: AppColors.primary),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documentName ?? 'Ảnh giấy phép lái xe',
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
                    documentName == null ? 'Tùy chọn' : 'Đã chọn từ Photos',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (documentName == null)
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

class _DriverInfoTile extends StatelessWidget {
  const _DriverInfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
