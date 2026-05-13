import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/vehicle.dart';
import '../cubit/vehicle_cubit.dart';
import '../cubit/vehicle_state.dart';

class VehicleCreateScreen extends StatelessWidget {
  const VehicleCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VehicleCubit>(),
      child: const _VehicleCreateView(),
    );
  }
}

class _VehicleCreateView extends StatelessWidget {
  const _VehicleCreateView();

  @override
  Widget build(BuildContext context) {
    return _VehicleSubmissionListener(
      successFallback: 'Thêm mới xe thành công',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Thêm xe',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: VehicleForm(
          submitLabel: 'Thêm xe',
          description: 'Nhập thông tin xe và tải lên ảnh xe, giấy đăng ký.',
          onSubmit: (submission) {
            context.read<VehicleCubit>().createVehicle(
              plateNumber: submission.plateNumber!,
              brand: submission.brand!,
              seatCapacity: submission.seatCapacity!,
              vehicleType: submission.vehicleType!,
              urlImagePath: submission.urlImagePath!,
              registrationDocumentUrlPath:
                  submission.registrationDocumentUrlPath!,
            );
          },
        ),
      ),
    );
  }
}

class VehicleEditScreen extends StatelessWidget {
  const VehicleEditScreen({super.key, required this.id, this.initialVehicle});

  final String id;
  final Vehicle? initialVehicle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<VehicleCubit>();
        if (initialVehicle == null) {
          cubit.loadMyVehicles();
        }
        return cubit;
      },
      child: _VehicleEditView(id: id, initialVehicle: initialVehicle),
    );
  }
}

class _VehicleEditView extends StatelessWidget {
  const _VehicleEditView({required this.id, this.initialVehicle});

  final String id;
  final Vehicle? initialVehicle;

  @override
  Widget build(BuildContext context) {
    return _VehicleSubmissionListener(
      successFallback: 'Cập nhật xe thành công',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Cập nhật xe',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: initialVehicle == null
            ? BlocBuilder<VehicleCubit, VehicleState>(
                builder: (context, state) {
                  if (state.status == VehicleStatus.loading ||
                      state.status == VehicleStatus.initial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == VehicleStatus.failure) {
                    final message =
                        state.errorMessage?.replaceFirst('Exception: ', '') ??
                        'Không thể tải thông tin xe';
                    return _CenteredMessage(
                      message: message,
                      onRetry: () =>
                          context.read<VehicleCubit>().loadMyVehicles(),
                    );
                  }
                  final vehicle = _findVehicle(state.vehicles, id);
                  if (vehicle == null) {
                    return const _CenteredMessage(
                      message: 'Không tìm thấy xe cần cập nhật',
                    );
                  }
                  return _EditForm(vehicle: vehicle);
                },
              )
            : _EditForm(vehicle: initialVehicle!),
      ),
    );
  }

  Vehicle? _findVehicle(List<Vehicle> vehicles, String id) {
    for (final vehicle in vehicles) {
      if (vehicle.id == id) {
        return vehicle;
      }
    }
    return null;
  }
}

class _EditForm extends StatelessWidget {
  const _EditForm({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return VehicleForm(
      submitLabel: 'Cập nhật',
      description:
          'Điều chỉnh thông tin xe. Nếu cập nhật ảnh hoặc giấy tờ, xe sẽ cần được duyệt lại.',
      initialVehicle: vehicle,
      isEditing: true,
      onSubmit: (submission) {
        context.read<VehicleCubit>().updateVehicle(
          id: vehicle.id,
          plateNumber: submission.plateNumber,
          brand: submission.brand,
          seatCapacity: submission.seatCapacity,
          vehicleType: submission.vehicleType,
          urlImagePath: submission.urlImagePath,
          registrationDocumentUrlPath: submission.registrationDocumentUrlPath,
        );
      },
    );
  }
}

class _VehicleSubmissionListener extends StatelessWidget {
  const _VehicleSubmissionListener({
    required this.child,
    required this.successFallback,
  });

  final Widget child;
  final String successFallback;

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehicleCubit, VehicleState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == VehicleStatus.failure) {
          final message =
              state.errorMessage?.replaceFirst('Exception: ', '') ??
              'Không thể lưu thông tin xe';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
        if (state.status == VehicleStatus.success &&
            state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage ?? successFallback)),
          );
          if (context.canPop()) {
            context.pop(true);
          } else {
            context.go('/profile/driver/vehicles');
          }
        }
      },
      child: child,
    );
  }
}

typedef VehicleFormSubmit = void Function(VehicleFormSubmission submission);

class VehicleFormSubmission {
  const VehicleFormSubmission({
    this.plateNumber,
    this.brand,
    this.seatCapacity,
    this.vehicleType,
    this.urlImagePath,
    this.registrationDocumentUrlPath,
  });

  final String? plateNumber;
  final String? brand;
  final int? seatCapacity;
  final int? vehicleType;
  final String? urlImagePath;
  final String? registrationDocumentUrlPath;
}

class VehicleForm extends StatefulWidget {
  const VehicleForm({
    super.key,
    required this.submitLabel,
    required this.description,
    required this.onSubmit,
    this.initialVehicle,
    this.isEditing = false,
  });

  final String submitLabel;
  final String description;
  final VehicleFormSubmit onSubmit;
  final Vehicle? initialVehicle;
  final bool isEditing;

  @override
  State<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _plateNumberController;
  late final TextEditingController _brandController;
  late final TextEditingController _seatCapacityController;
  int? _vehicleType;
  String? _vehicleImagePath;
  String? _registrationDocumentPath;

  bool get _requiresFiles => !widget.isEditing;

  @override
  void initState() {
    super.initState();
    _plateNumberController = TextEditingController(
      text: widget.initialVehicle?.plateNumber ?? '',
    );
    _brandController = TextEditingController(
      text: widget.initialVehicle?.brand ?? '',
    );
    _seatCapacityController = TextEditingController(
      text: widget.initialVehicle?.seatCapacity.toString() ?? '',
    );
    final initialVehicleType = widget.initialVehicle?.vehicleType;
    _vehicleType = _isSupportedVehicleType(initialVehicleType)
        ? initialVehicleType
        : null;
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    _brandController.dispose();
    _seatCapacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleCubit, VehicleState>(
      builder: (context, state) {
        final isSubmitting = state.isSubmitting;
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.isEditing ? 'Cập nhật phương tiện' : 'Đăng ký xe mới',
                  style: TextStyle(
                    color: AppColors.primaryContainer,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  widget.description,
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 18.h),
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
                        _ImagePickerTile(
                          title: 'Ảnh xe',
                          emptyText: widget.isEditing
                              ? 'Giữ ảnh xe hiện tại nếu không chọn ảnh mới'
                              : 'Bắt buộc chọn ảnh xe',
                          imagePath: _vehicleImagePath,
                          isLoading: isSubmitting,
                          onPick: () => _pickImage(isVehicleImage: true),
                          onClear: () =>
                              setState(() => _vehicleImagePath = null),
                        ),
                        SizedBox(height: 12.h),
                        _ImagePickerTile(
                          title: 'Giấy đăng ký xe',
                          emptyText: widget.isEditing
                              ? 'Giữ giấy đăng ký hiện tại nếu không chọn ảnh mới'
                              : 'Bắt buộc chọn ảnh giấy đăng ký',
                          imagePath: _registrationDocumentPath,
                          isLoading: isSubmitting,
                          onPick: () => _pickImage(isVehicleImage: false),
                          onClear: () =>
                              setState(() => _registrationDocumentPath = null),
                        ),
                        SizedBox(height: 18.h),
                        TextFormField(
                          controller: _plateNumberController,
                          enabled: !isSubmitting,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _validatePlateNumber,
                          decoration: const InputDecoration(
                            labelText: 'Biển số xe',
                            hintText: '30A-12345',
                            prefixIcon: Icon(
                              Icons.confirmation_number_outlined,
                            ),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        TextFormField(
                          controller: _brandController,
                          enabled: !isSubmitting,
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _validateBrand,
                          decoration: const InputDecoration(
                            labelText: 'Hãng xe',
                            hintText: 'Toyota',
                            prefixIcon: Icon(Icons.directions_car_outlined),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        TextFormField(
                          controller: _seatCapacityController,
                          enabled: !isSubmitting,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _validateSeatCapacity,
                          decoration: const InputDecoration(
                            labelText: 'Số ghế',
                            hintText: '4',
                            prefixIcon: Icon(Icons.event_seat_outlined),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        DropdownButtonFormField<int>(
                          initialValue: _vehicleType,
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Xe 4 chỗ')),
                            DropdownMenuItem(value: 2, child: Text('Xe 7 chỗ')),
                            DropdownMenuItem(
                              value: 3,
                              child: Text('Xe đường dài'),
                            ),
                          ],
                          onChanged: isSubmitting
                              ? null
                              : (value) => setState(() => _vehicleType = value),
                          validator: _validateVehicleType,
                          decoration: const InputDecoration(
                            labelText: 'Loại xe',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        ElevatedButton(
                          onPressed: isSubmitting ? null : _onSubmit,
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

  Future<void> _pickImage({required bool isVehicleImage}) async {
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
          const SnackBar(content: Text('File ảnh không đúng định dạng')),
        );
        return;
      }
      setState(() {
        if (isVehicleImage) {
          _vehicleImagePath = image.path;
        } else {
          _registrationDocumentPath = image.path;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở thư viện ảnh')),
      );
    }
  }

  void _onSubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    if (!_validateRequiredImages()) {
      return;
    }

    final plateNumber = _plateNumberController.text.trim().toUpperCase();
    final brand = _brandController.text.trim();
    final seatCapacityText = _seatCapacityController.text.trim();
    final seatCapacity = int.tryParse(seatCapacityText);

    widget.onSubmit(
      VehicleFormSubmission(
        plateNumber: _optionalText(plateNumber),
        brand: _optionalText(brand),
        seatCapacity: seatCapacityText.isEmpty ? null : seatCapacity,
        vehicleType: _vehicleType,
        urlImagePath: _vehicleImagePath,
        registrationDocumentUrlPath: _registrationDocumentPath,
      ),
    );
  }

  String? _optionalText(String value) {
    if (widget.isEditing && value.isEmpty) {
      return null;
    }
    return value;
  }

  bool _validateRequiredImages() {
    if (_requiresFiles && !_isValidImagePath(_vehicleImagePath)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh xe hợp lệ')),
      );
      return false;
    }
    if (_requiresFiles && !_isValidImagePath(_registrationDocumentPath)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh giấy đăng ký hợp lệ')),
      );
      return false;
    }
    if (!_requiresFiles &&
        (!_isValidImagePath(_vehicleImagePath) ||
            !_isValidImagePath(_registrationDocumentPath))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File ảnh không đúng định dạng')),
      );
      return false;
    }
    return true;
  }

  String? _validatePlateNumber(String? value) {
    final text = value?.trim() ?? '';
    if (!widget.isEditing && text.isEmpty) {
      return 'Vui lòng nhập biển số xe';
    }
    if (text.length > 20) {
      return 'Biển số xe tối đa 20 ký tự';
    }
    return null;
  }

  String? _validateBrand(String? value) {
    final text = value?.trim() ?? '';
    if (!widget.isEditing && text.isEmpty) {
      return 'Vui lòng nhập hãng xe';
    }
    if (text.length > 50) {
      return 'Hãng xe tối đa 50 ký tự';
    }
    return null;
  }

  String? _validateSeatCapacity(String? value) {
    final text = value?.trim() ?? '';
    if (!widget.isEditing && text.isEmpty) {
      return 'Vui lòng nhập số ghế';
    }
    if (widget.isEditing && text.isEmpty) {
      return null;
    }
    final number = int.tryParse(text);
    if (number == null || number < 1 || number > 50) {
      return 'Số ghế phải từ 1 đến 50';
    }
    return null;
  }

  String? _validateVehicleType(int? value) {
    if (!widget.isEditing && value == null) {
      return 'Vui lòng chọn loại xe';
    }
    return null;
  }

  bool _isValidImagePath(String? path) {
    if (path == null || path.isEmpty) {
      return !_requiresFiles;
    }
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.heic');
  }

  bool _isSupportedVehicleType(int? value) {
    return value == 1 || value == 2 || value == 3;
  }
}

class _ImagePickerTile extends StatelessWidget {
  const _ImagePickerTile({
    required this.title,
    required this.emptyText,
    required this.imagePath,
    required this.isLoading,
    required this.onPick,
    required this.onClear,
  });

  final String title;
  final String emptyText;
  final String? imagePath;
  final bool isLoading;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final imageName = imagePath == null ? null : _fileName(imagePath!);
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
                    imageName ?? title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    imageName == null ? emptyText : 'Đã chọn từ Photos',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (imageName == null)
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

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
            ],
          ],
        ),
      ),
    );
  }
}
