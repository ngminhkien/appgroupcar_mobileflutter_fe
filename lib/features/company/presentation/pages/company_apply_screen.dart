import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/company_login_result.dart';
import '../../domain/entities/company_status.dart';
import '../../domain/entities/company_type.dart';
import '../cubit/company_apply_cubit.dart';
import '../cubit/company_apply_state.dart';

class CompanyApplyScreen extends StatelessWidget {
  const CompanyApplyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CompanyApplyCubit>(),
      child: const _CompanyApplyView(),
    );
  }
}

class _CompanyApplyView extends StatefulWidget {
  const _CompanyApplyView();

  @override
  State<_CompanyApplyView> createState() => _CompanyApplyViewState();
}

class _CompanyApplyViewState extends State<_CompanyApplyView> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  final _companyNameController = TextEditingController();
  final _companyCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _provinceCodeController = TextEditingController();
  final _districtCodeController = TextEditingController();
  final _businessLicenseNoController = TextEditingController();
  final _taxCodeController = TextEditingController();
  final _licenseIssuedByController = TextEditingController();

  CompanyType _companyType = CompanyType.bus;
  DateTime? _licenseIssuedDate;
  bool _isUpdateMode = false;
  String? _updateCompanyId;

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _provinceCodeController.dispose();
    _districtCodeController.dispose();
    _businessLicenseNoController.dispose();
    _taxCodeController.dispose();
    _licenseIssuedByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompanyApplyCubit, CompanyApplyState>(
      listenWhen: (previous, current) =>
          previous.status != current.status || previous.action != current.action,
      listener: (context, state) {
        if (state.status == CompanyApplyStatus.failure) {
          final message =
              state.errorMessage?.replaceFirst('Exception: ', '') ??
              'Khong the xu ly yeu cau';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          return;
        }

        if (state.status == CompanyApplyStatus.success) {
          final message = state.successMessage ?? 'Xu ly thanh cong';
          if (state.action == CompanyApplyAction.create) {
            _showCreateSuccessAndBackToLogin(message);
            return;
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          if (state.action == CompanyApplyAction.checkStatus &&
              state.checkResult != null) {
            _applyCheckResult(state.checkResult!);
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
          title: const Text('Dang ky cho doanh nghiep'),
        ),
        body: BlocBuilder<CompanyApplyCubit, CompanyApplyState>(
          builder: (context, state) {
            final isSubmitting = state.isSubmitting;
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TopLookupCard(
                      isChecking: state.isChecking,
                      onLookupPressed: _openLookupDialog,
                    ),
                    if (state.checkResult != null) ...[
                      SizedBox(height: 14.h),
                      _CompanyStatusCard(
                        result: state.checkResult!,
                        onUseForUpdate: state.checkResult!.canUseForUpdate
                            ? () => _applyCheckResult(state.checkResult!)
                            : null,
                      ),
                    ],
                    SizedBox(height: 16.h),
                    if (_isUpdateMode) ...[
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.edit_note_outlined),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Dang o che do cap nhat ho so. Ban co the dieu chinh thong tin va gui lai.',
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),
                    ],
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
                            _LogoPicker(
                              logoPath: state.logoPath,
                              isLoading: isSubmitting,
                              onPick: _pickLogo,
                              onClear: () =>
                                  context.read<CompanyApplyCubit>().changeLogo(null),
                            ),
                            SizedBox(height: 18.h),
                            TextFormField(
                              controller: _companyNameController,
                              enabled: !isSubmitting,
                              textInputAction: TextInputAction.next,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: _validateRequired,
                              decoration: const InputDecoration(
                                labelText: 'Ten cong ty *',
                                hintText: 'Cong ty ABC',
                                prefixIcon: Icon(Icons.business_outlined),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            TextFormField(
                              controller: _companyCodeController,
                              enabled: !isSubmitting && !_isUpdateMode,
                              textInputAction: TextInputAction.next,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: _isUpdateMode ? null : _validateRequired,
                              decoration: InputDecoration(
                                labelText: 'Ma cong ty ${_isUpdateMode ? '(khong doi)' : '*'}',
                                hintText: 'ABC001',
                                prefixIcon: const Icon(Icons.confirmation_number_outlined),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            DropdownButtonFormField<CompanyType>(
                              initialValue: _companyType,
                              items: CompanyType.values
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type.label),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (!isSubmitting && !_isUpdateMode)
                                  ? (value) {
                                      if (value == null) {
                                        return;
                                      }
                                      setState(() => _companyType = value);
                                    }
                                  : null,
                              decoration: InputDecoration(
                                labelText: _isUpdateMode
                                    ? 'Loai cong ty (chi xem)'
                                    : 'Loai cong ty *',
                                prefixIcon: const Icon(Icons.local_taxi_outlined),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            TextFormField(
                              controller: _phoneController,
                              enabled: !isSubmitting,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: _validatePhone,
                              decoration: const InputDecoration(
                                labelText: 'So dien thoai *',
                                hintText: '0901234567',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            TextFormField(
                              controller: _emailController,
                              enabled: !isSubmitting && !_isUpdateMode,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: _validateOptionalEmail,
                              decoration: InputDecoration(
                                labelText: _isUpdateMode
                                    ? 'Email (chi xem)'
                                    : 'Email (tuy chon)',
                                hintText: 'company@example.com',
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            TextFormField(
                              controller: _addressController,
                              enabled: !isSubmitting,
                              textInputAction: TextInputAction.next,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: _validateRequired,
                              decoration: const InputDecoration(
                                labelText: 'Dia chi *',
                                hintText: '123 Nguyen Trai',
                                prefixIcon: Icon(Icons.location_on_outlined),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            TextFormField(
                              controller: _provinceCodeController,
                              enabled: !isSubmitting,
                              textInputAction: TextInputAction.next,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: _validateRequired,
                              decoration: const InputDecoration(
                                labelText: 'ProvinceCode *',
                                hintText: '79',
                                prefixIcon: Icon(Icons.map_outlined),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            TextFormField(
                              controller: _districtCodeController,
                              enabled: !isSubmitting,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'DistrictCode (tuy chon)',
                                hintText: '760',
                                prefixIcon: Icon(Icons.pin_drop_outlined),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            TextFormField(
                              controller: _businessLicenseNoController,
                              enabled: !isSubmitting,
                              textInputAction: TextInputAction.next,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: _validateRequired,
                              decoration: const InputDecoration(
                                labelText: 'So giay phep kinh doanh *',
                                hintText: '0312345678',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            TextFormField(
                              controller: _taxCodeController,
                              enabled: !isSubmitting && !_isUpdateMode,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: _isUpdateMode
                                    ? 'Ma so thue (chi xem)'
                                    : 'Ma so thue (tuy chon)',
                                hintText: '0312345678',
                                prefixIcon: const Icon(Icons.receipt_long_outlined),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            InkWell(
                              onTap: (!isSubmitting && !_isUpdateMode)
                                  ? _pickLicenseIssuedDate
                                  : null,
                              borderRadius: BorderRadius.circular(12.r),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: _isUpdateMode
                                      ? 'Ngay cap GP (chi xem)'
                                      : 'Ngay cap GP (tuy chon)',
                                  prefixIcon: const Icon(Icons.calendar_month_outlined),
                                ),
                                child: Text(
                                  _licenseIssuedDate == null
                                      ? 'Chua chon'
                                      : _formatDate(_licenseIssuedDate!),
                                ),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            TextFormField(
                              controller: _licenseIssuedByController,
                              enabled: !isSubmitting && !_isUpdateMode,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                labelText: _isUpdateMode
                                    ? 'Noi cap GP (chi xem)'
                                    : 'Noi cap GP (tuy chon)',
                                hintText: 'So Ke hoach va Dau tu',
                                prefixIcon: const Icon(Icons.apartment_outlined),
                              ),
                            ),
                            SizedBox(height: 22.h),
                            if (!_isUpdateMode)
                              ElevatedButton(
                                onPressed:
                                    isSubmitting ? null : () => _onCreatePressed(state),
                                child: isSubmitting
                                    ? SizedBox(
                                        width: 18.w,
                                        height: 18.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.onPrimary,
                                        ),
                                      )
                                    : const Text('Gui don dang ky'),
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: isSubmitting
                                          ? null
                                          : _switchBackToCreateMode,
                                      child: const Text('Huy cap nhat'),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      onPressed: isSubmitting
                                          ? null
                                          : () => _onUpdatePressed(state),
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
                                          : const Text('Cap nhat ho so'),
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
        ),
      ),
    );
  }

  Future<void> _openLookupDialog() async {
    final result = await showDialog<_CompanyLookupPayload>(
      context: context,
      builder: (context) => const _CompanyLookupDialog(),
    );
    if (!mounted || result == null) {
      return;
    }
    _emailController.text = result.email;
    _businessLicenseNoController.text = result.businessLicenseNo;
    context.read<CompanyApplyCubit>().checkStatus(
      email: result.email,
      businessLicenseNo: result.businessLicenseNo,
    );
  }

  void _applyCheckResult(CompanyLoginResult result) {
    if (!result.canUseForUpdate) {
      _switchBackToCreateMode();
      return;
    }
    final pending = result.pendingUpdateData;
    if (pending == null) {
      setState(() {
        _isUpdateMode = true;
        _updateCompanyId = result.companyId;
      });
      return;
    }
    setState(() {
      _isUpdateMode = true;
      _updateCompanyId = result.companyId;
      _companyNameController.text = pending.companyName;
      _phoneController.text = pending.phone;
      _addressController.text = pending.address;
      _provinceCodeController.text = pending.provinceCode;
      _districtCodeController.text = pending.districtCode ?? '';
      _businessLicenseNoController.text = pending.businessLicenseNo;
    });
  }

  void _switchBackToCreateMode() {
    setState(() {
      _isUpdateMode = false;
      _updateCompanyId = null;
    });
  }

  void _showCreateSuccessAndBackToLogin(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Gui don thanh cong'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Ve dang nhap'),
            ),
          ],
        );
      },
    ).then((_) {
      if (!mounted) {
        return;
      }
      context.go('/login');
    });
  }

  Future<void> _pickLogo() async {
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
          const SnackBar(content: Text('Anh logo khong dung dinh dang')),
        );
        return;
      }
      context.read<CompanyApplyCubit>().changeLogo(image.path);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khong the mo thu vien anh')),
      );
    }
  }

  Future<void> _pickLicenseIssuedDate() async {
    final now = DateTime.now();
    final initialDate = _licenseIssuedDate ?? DateTime(now.year - 1);
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1980),
      lastDate: DateTime(now.year + 1),
      initialDate: initialDate,
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() => _licenseIssuedDate = selected);
  }

  void _onCreatePressed(CompanyApplyState state) {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    if (!_isValidImagePath(state.logoPath)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anh logo khong dung dinh dang')),
      );
      return;
    }
    context.read<CompanyApplyCubit>().createCompany(
      companyName: _companyNameController.text.trim(),
      companyCode: _companyCodeController.text.trim(),
      logoPath: state.logoPath,
      phone: _phoneController.text.trim(),
      email: _toNullable(_emailController.text),
      address: _addressController.text.trim(),
      provinceCode: _provinceCodeController.text.trim(),
      districtCode: _toNullable(_districtCodeController.text),
      businessLicenseNo: _businessLicenseNoController.text.trim(),
      taxCode: _toNullable(_taxCodeController.text),
      licenseIssuedDate: _licenseIssuedDate,
      licenseIssuedBy: _toNullable(_licenseIssuedByController.text),
      companyType: _companyType,
    );
  }

  void _onUpdatePressed(CompanyApplyState state) {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    final companyId = _updateCompanyId;
    if (companyId == null || companyId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Can kiem tra don truoc khi cap nhat ho so'),
        ),
      );
      return;
    }
    if (!_isValidImagePath(state.logoPath)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anh logo khong dung dinh dang')),
      );
      return;
    }
    context.read<CompanyApplyCubit>().updateCompany(
      id: companyId,
      companyName: _toNullable(_companyNameController.text),
      logoPath: state.logoPath,
      phone: _toNullable(_phoneController.text),
      address: _toNullable(_addressController.text),
      provinceCode: _toNullable(_provinceCodeController.text),
      districtCode: _toNullable(_districtCodeController.text),
      businessLicenseNo: _toNullable(_businessLicenseNoController.text),
    );
  }

  String? _validateRequired(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Truong nay la bat buoc';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Vui long nhap so dien thoai';
    }
    final regex = RegExp(r'^[0-9]{9,11}$');
    if (!regex.hasMatch(text)) {
      return 'So dien thoai khong hop le';
    }
    return null;
  }

  String? _validateOptionalEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!regex.hasMatch(text)) {
      return 'Email khong hop le';
    }
    return null;
  }

  String? _toNullable(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
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

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class _TopLookupCard extends StatelessWidget {
  const _TopLookupCard({
    required this.isChecking,
    required this.onLookupPressed,
  });

  final bool isChecking;
  final VoidCallback onLookupPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Da tung nop don?',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6.h),
          Text(
            'Ban co the kiem tra trang thai duyet va su dung du lieu de cap nhat ho so.',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 12.h),
          OutlinedButton.icon(
            onPressed: isChecking ? null : onLookupPressed,
            icon: isChecking
                ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search_outlined),
            label: const Text('Kiem tra don dang ky'),
          ),
        ],
      ),
    );
  }
}

class _CompanyStatusCard extends StatelessWidget {
  const _CompanyStatusCard({
    required this.result,
    required this.onUseForUpdate,
  });

  final CompanyLoginResult result;
  final VoidCallback? onUseForUpdate;

  @override
  Widget build(BuildContext context) {
    final status = result.status;
    final color = _statusColor(status);
    final primaryMessage = result.message.trim().isNotEmpty
        ? result.message
        : _statusHint(status);
    final details = result.description?.trim();
    final hasDetails =
        details != null && details.isNotEmpty && details != primaryMessage;
    final hasCompanyId = result.companyId.trim().isNotEmpty;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(_statusIcon(status), color: color),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  status.label,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            primaryMessage,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
          if (hasDetails) ...[
            SizedBox(height: 8.h),
            Text(
              'Chi tiet: $details',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ],
          if (hasCompanyId) ...[
            SizedBox(height: 10.h),
            Text(
              'CompanyId: ${result.companyId}',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
          SizedBox(height: 10.h),
          if (onUseForUpdate != null)
            OutlinedButton.icon(
              onPressed: onUseForUpdate,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Dung du lieu nay de cap nhat'),
            ),
        ],
      ),
    );
  }

  IconData _statusIcon(CompanyStatus status) {
    switch (status) {
      case CompanyStatus.approved:
        return Icons.verified_outlined;
      case CompanyStatus.rejected:
        return Icons.cancel_outlined;
      case CompanyStatus.suspended:
        return Icons.pause_circle_outlined;
      case CompanyStatus.pending:
        return Icons.pending_actions_outlined;
      case CompanyStatus.unknown:
        return Icons.help_outline;
    }
  }

  Color _statusColor(CompanyStatus status) {
    switch (status) {
      case CompanyStatus.approved:
        return Colors.green;
      case CompanyStatus.rejected:
        return Colors.red;
      case CompanyStatus.suspended:
        return Colors.orange;
      case CompanyStatus.pending:
        return Colors.blueGrey;
      case CompanyStatus.unknown:
        return AppColors.outline;
    }
  }

  String _statusHint(CompanyStatus status) {
    switch (status) {
      case CompanyStatus.approved:
        return 'Ho so cong ty da duoc duyet.';
      case CompanyStatus.rejected:
        return 'Ho so dang o trang thai tu choi. Ban nen cap nhat lai thong tin.';
      case CompanyStatus.suspended:
        return 'Ho so dang bi tam ngung.';
      case CompanyStatus.pending:
        return 'Ho so dang cho admin duyet.';
      case CompanyStatus.unknown:
        return 'Khong xac dinh duoc trang thai ho so.';
    }
  }
}

class _LogoPicker extends StatelessWidget {
  const _LogoPicker({
    required this.logoPath,
    required this.isLoading,
    required this.onPick,
    required this.onClear,
  });

  final String? logoPath;
  final bool isLoading;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final fileName = logoPath == null ? null : _extractFileName(logoPath!);
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
                    fileName ?? 'Logo cong ty (tuy chon)',
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
                    fileName == null ? 'Nhan de tai logo' : 'Da chon tu Photos',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (fileName == null)
              const Icon(
                Icons.photo_library_outlined,
                color: AppColors.onSurfaceVariant,
              )
            else
              IconButton(
                onPressed: isLoading ? null : onClear,
                icon: const Icon(Icons.close),
                tooltip: 'Bo anh',
              ),
          ],
        ),
      ),
    );
  }

  String _extractFileName(String path) {
    final parts = path.split(RegExp(r'[\\/]'));
    return parts.isEmpty ? path : parts.last;
  }
}

class _CompanyLookupPayload {
  const _CompanyLookupPayload({
    required this.email,
    required this.businessLicenseNo,
  });

  final String email;
  final String businessLicenseNo;
}

class _CompanyLookupDialog extends StatefulWidget {
  const _CompanyLookupDialog();

  @override
  State<_CompanyLookupDialog> createState() => _CompanyLookupDialogState();
}

class _CompanyLookupDialogState extends State<_CompanyLookupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _licenseController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Kiem tra don dang ky'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: _validateEmail,
              decoration: const InputDecoration(
                labelText: 'Email *',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _licenseController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: _validateRequired,
              decoration: const InputDecoration(
                labelText: 'So giay phep kinh doanh *',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Dong'),
        ),
        ElevatedButton(
          onPressed: _onSubmit,
          child: const Text('Kiem tra'),
        ),
      ],
    );
  }

  void _onSubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    Navigator.of(context).pop(
      _CompanyLookupPayload(
        email: _emailController.text.trim(),
        businessLicenseNo: _licenseController.text.trim(),
      ),
    );
  }

  String? _validateRequired(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Truong nay la bat buoc';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Vui long nhap email';
    }
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!regex.hasMatch(text)) {
      return 'Email khong hop le';
    }
    return null;
  }
}
