import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/enums/route_stop_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../di/injection.dart';
import '../../../location/domain/entities/location_search_item.dart';
import '../../../location/presentation/models/location_search_screen_args.dart';
import '../../../offers/presentation/cubit/offers_cubit.dart';
import '../../../offers/presentation/cubit/offers_state.dart';
import '../../../vehicle/domain/entities/vehicle.dart';
import '../../../vehicle/presentation/cubit/vehicle_cubit.dart';
import '../../../vehicle/presentation/cubit/vehicle_state.dart';

class CreateTripScreen extends StatelessWidget {
  const CreateTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<VehicleCubit>()..loadMyVehicles()),
        BlocProvider(create: (_) => sl<OffersCubit>()..reset()),
      ],
      child: const _CreateTripView(),
    );
  }
}

class _CreateTripView extends StatefulWidget {
  const _CreateTripView();

  @override
  State<_CreateTripView> createState() => _CreateTripViewState();
}

class _CreateTripViewState extends State<_CreateTripView> {
  int _currentStep = 0;

  // Step 1 data: Route setup
  final List<LocationSearchItem> _routeLocations = [];
  final List<RouteStopType> _routeStopTypes = [];

  // Step 2 data: Basic details
  Vehicle? _selectedVehicle;
  DateTime? _departureDateTime;
  final _durationController = TextEditingController();
  final _basePriceController = TextEditingController();

  // Step 3 data: Cargo info
  final _maxWeightController = TextEditingController();
  final _maxVolumeController = TextEditingController();
  bool _acceptFragile = false;

  final _basicFormKey = GlobalKey<FormState>();
  final _cargoFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _durationController.dispose();
    _basePriceController.dispose();
    _maxWeightController.dispose();
    _maxVolumeController.dispose();
    super.dispose();
  }

  bool _isTruck(Vehicle vehicle) {
    return vehicle.vehicleType == 4 ||
        vehicle.vehicleTypeLabel.toLowerCase().contains('tải');
  }

  int get _totalSteps =>
      (_selectedVehicle != null && _isTruck(_selectedVehicle!)) ? 3 : 2;

  void _addRoutePoint(LocationSearchItem item) {
    setState(() {
      _routeLocations.add(item);
      // Auto assign stop type based on position
      if (_routeLocations.length == 1) {
        _routeStopTypes.add(RouteStopType.start);
      } else {
        // Change the previous last to pickup/transit, and set new last to end
        if (_routeStopTypes.isNotEmpty) {
          _routeStopTypes[_routeStopTypes.length - 1] = RouteStopType.pickup;
        }
        _routeStopTypes.add(RouteStopType.end);
      }
    });
  }

  void _removeRoutePoint(int index) {
    setState(() {
      _routeLocations.removeAt(index);
      _routeStopTypes.removeAt(index);

      // Readjust first and last stop types
      if (_routeStopTypes.isNotEmpty) {
        _routeStopTypes[0] = RouteStopType.start;
        _routeStopTypes[_routeStopTypes.length - 1] = RouteStopType.end;
      }
    });
  }

  void _movePointUp(int index) {
    if (index <= 0) return;
    setState(() {
      final loc = _routeLocations.removeAt(index);
      final type = _routeStopTypes.removeAt(index);
      _routeLocations.insert(index - 1, loc);
      _routeStopTypes.insert(index - 1, type);

      // Re-enforce start and end types
      _routeStopTypes[0] = RouteStopType.start;
      _routeStopTypes[_routeStopTypes.length - 1] = RouteStopType.end;
    });
  }

  void _movePointDown(int index) {
    if (index >= _routeLocations.length - 1) return;
    setState(() {
      final loc = _routeLocations.removeAt(index);
      final type = _routeStopTypes.removeAt(index);
      _routeLocations.insert(index + 1, loc);
      _routeStopTypes.insert(index + 1, type);

      // Re-enforce start and end types
      _routeStopTypes[0] = RouteStopType.start;
      _routeStopTypes[_routeStopTypes.length - 1] = RouteStopType.end;
    });
  }

  bool _validateRoute() {
    if (_routeLocations.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lộ trình cần ít nhất 2 điểm dừng (Điểm đầu & Điểm cuối).',
          ),
        ),
      );
      return false;
    }
    if (_routeStopTypes.first != RouteStopType.start) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Điểm bắt đầu lộ trình phải thuộc loại Start.'),
        ),
      );
      return false;
    }
    if (_routeStopTypes.last != RouteStopType.end) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Điểm kết thúc lộ trình phải thuộc loại End.'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !context.mounted) return;

    setState(() {
      _departureDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  void _submitTrip(BuildContext context) async {
    if (_selectedVehicle == null || _departureDateTime == null) return;

    final List<Map<String, dynamic>> routePointsJson = [];
    for (int i = 0; i < _routeLocations.length; i++) {
      routePointsJson.add({
        'locationId': _routeLocations[i].id,
        'stopType': _routeStopTypes[i].value,
      });
    }

    final estimatedDuration =
        int.tryParse(_durationController.text.trim()) ?? 60;
    final basePrice = double.tryParse(_basePriceController.text.trim()) ?? 0.0;
    final formattedTime = _departureDateTime!.toIso8601String();

    final offersCubit = context.read<OffersCubit>();
    bool success = false;

    if (_isTruck(_selectedVehicle!)) {
      final maxWeight =
          double.tryParse(_maxWeightController.text.trim()) ?? 0.0;
      final maxVolume =
          double.tryParse(_maxVolumeController.text.trim()) ?? 0.0;
      final cargo = {
        'maxWeight': maxWeight,
        'maxVolume': maxVolume,
        'acceptFragile': _acceptFragile,
      };

      success = await offersCubit.createShipment(
        vehicleId: _selectedVehicle!.id,
        departureTime: formattedTime,
        estimatedDurationMinutes: estimatedDuration,
        basePrice: basePrice,
        offerRoutePoints: routePointsJson,
        cargo: cargo,
      );
    } else {
      success = await offersCubit.createSharedRide(
        vehicleId: _selectedVehicle!.id,
        departureTime: formattedTime,
        estimatedDurationMinutes: estimatedDuration,
        basePrice: basePrice,
        offerRoutePoints: routePointsJson,
      );
    }

    if (success && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Thành công'),
            ],
          ),
          content: const Text(
            'Tạo chuyến đi mới thành công! Chuyến đi đã được đưa lên hệ thống.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                context.go('/driver'); // Navigate to Driver Dashboard
              },
              child: const Text('Đồng ý'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OffersCubit, OffersState>(
      listener: (context, state) {
        if (state.status == OffersStatus.failure &&
            state.errorMessage != null) {
          final text = state.errorMessage!.contains('500')
              ? 'Lỗi hệ thống. Vui lòng thử lại sau.'
              : state.errorMessage!.replaceFirst('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(text), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Tạo chuyến đi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildStepIndicator(),
              Expanded(
                child: BlocBuilder<OffersCubit, OffersState>(
                  builder: (context, state) {
                    if (state.status == OffersStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _buildStepContent(context);
                  },
                ),
              ),
              _buildNavigationButtons(context),
            ],
          ),
        ),
        bottomNavigationBar: const AppBottomNavBar(),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
      color: AppColors.surfaceContainerLowest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_totalSteps, (index) {
          final isCompleted = _currentStep > index;
          final isActive = _currentStep == index;
          final stepNum = index + 1;

          String stepTitle = '';
          if (index == 0) stepTitle = 'Lộ trình';
          if (index == 1) stepTitle = 'Thông tin';
          if (index == 2) stepTitle = 'Hàng hóa';

          return Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12.r,
                  backgroundColor: isCompleted
                      ? Colors.green
                      : isActive
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                  child: isCompleted
                      ? Icon(Icons.check, size: 12.sp, color: Colors.white)
                      : Text(
                          stepNum.toString(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                SizedBox(width: 8.w),
                Text(
                  stepTitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                if (index < _totalSteps - 1)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      height: 1,
                      color: AppColors.outlineVariant,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    if (_currentStep == 0) {
      return _buildRouteStep(context);
    } else if (_currentStep == 1) {
      return _buildBasicInfoStep(context);
    } else {
      return _buildCargoInfoStep(context);
    }
  }

  Widget _buildRouteStep(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thiết lập lộ trình di chuyển',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.h),
              Text(
                'Hãy tìm và thêm các trạm dừng. Điểm đầu tiên sẽ là Start (1), điểm cuối cùng là End (5). Các điểm ở giữa có thể tùy chỉnh.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        if (_routeLocations.isEmpty)
          Container(
            height: 180.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.outlineVariant,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              'Chưa có điểm dừng nào. Hãy nhấp nút bên dưới để thêm.',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 13.sp,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _routeLocations.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final loc = _routeLocations[index];
              final type = _routeStopTypes[index];
              return _buildRoutePointCard(index, loc, type);
            },
          ),
        SizedBox(height: 16.h),
        ElevatedButton.icon(
          onPressed: () async {
            final result = await context.push<LocationSearchItem>(
              '/location_search',
              extra: const LocationSearchScreenArgs(
                title: 'Tìm điểm dừng',
                hintText: 'Nhập tên trạm dừng, điểm đón...',
                availableForRoute: true,
              ),
            );
            if (result != null) {
              _addRoutePoint(result);
            }
          },
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('Thêm điểm dừng'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoutePointCard(
    int index,
    LocationSearchItem loc,
    RouteStopType type,
  ) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  (index + 1).toString(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  loc.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => _removeRoutePoint(index),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            loc.displayName,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Stop Type dropdown
              DropdownButton<RouteStopType>(
                value: type,
                onChanged: (newType) {
                  if (newType != null) {
                    setState(() {
                      _routeStopTypes[index] = newType;
                    });
                  }
                },
                items: RouteStopType.values
                    .where((t) => t != RouteStopType.unknown)
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.displayLabel),
                      ),
                    )
                    .toList(),
              ),
              // Reorder buttons
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: index == 0 ? null : () => _movePointUp(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward),
                    onPressed: index == _routeLocations.length - 1
                        ? null
                        : () => _movePointDown(index),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep(BuildContext context) {
    return Form(
      key: _basicFormKey,
      child: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          // Selected vehicle
          BlocBuilder<VehicleCubit, VehicleState>(
            builder: (context, state) {
              final approvedVehicles = state.vehicles
                  .where((vehicle) => vehicle.status == 2)
                  .toList();

              if (state.status == VehicleStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (approvedVehicles.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Text(
                    'Bạn chưa có xe được phê duyệt để chạy chuyến. Vui lòng đăng ký xe trong mục Cá nhân.',
                    style: TextStyle(color: AppColors.error),
                  ),
                );
              }

              return DropdownButtonFormField<Vehicle>(
                initialValue: _selectedVehicle,
                hint: const Text('Chọn xe'),
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Chọn phương tiện',
                  prefixIcon: Icon(Icons.directions_car),
                ),
                items: approvedVehicles.map((vehicle) {
                  return DropdownMenuItem<Vehicle>(
                    value: vehicle,
                    child: Text(
                      '${vehicle.brand} - ${vehicle.plateNumber} (${vehicle.vehicleTypeLabel})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (vehicle) {
                  setState(() {
                    _selectedVehicle = vehicle;
                  });
                },
                validator: (v) => v == null ? 'Vui lòng chọn xe' : null,
              );
            },
          ),
          SizedBox(height: 16.h),

          // Date time picker
          _buildFormTile(
            label: 'Thời gian khởi hành',
            valueText: _departureDateTime != null
                ? _formatDateTime(_departureDateTime!)
                : 'Chọn ngày giờ khởi hành',
            icon: Icons.access_time_outlined,
            onTap: () => _selectDateTime(context),
          ),
          SizedBox(height: 16.h),

          // Estimated duration (minutes)
          TextFormField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Vui lòng nhập thời gian di chuyển';
              }
              if (int.tryParse(v) == null) {
                return 'Thời gian phải là số nguyên';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Thời gian di chuyển ước tính (phút)',
              hintText: 'Ví dụ: 120',
              prefixIcon: Icon(Icons.timer_outlined),
            ),
          ),
          SizedBox(height: 16.h),

          // Base Price
          TextFormField(
            controller: _basePriceController,
            keyboardType: TextInputType.number,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Vui lòng nhập giá cước';
              }
              if (double.tryParse(v) == null) {
                return 'Giá cước không hợp lệ';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Giá cước cơ bản (VND)',
              hintText: 'Ví dụ: 200000',
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormTile({
    required String label,
    required String valueText,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: AppColors.primary),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    valueText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildCargoInfoStep(BuildContext context) {
    return Form(
      key: _cargoFormKey,
      child: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.local_shipping_outlined, color: AppColors.primary),
                SizedBox(width: 10.w),
                const Expanded(
                  child: Text(
                    'Vì bạn chọn Xe tải, vui lòng điền các thông tin vận tải hàng hóa dưới đây.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Max weight
          TextFormField(
            controller: _maxWeightController,
            keyboardType: TextInputType.number,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Vui lòng nhập khối lượng tối đa';
              }
              if (double.tryParse(v) == null) {
                return 'Khối lượng không hợp lệ';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Khối lượng tối đa (kg)',
              hintText: 'Ví dụ: 15.5',
              prefixIcon: Icon(Icons.scale_outlined),
            ),
          ),
          SizedBox(height: 16.h),

          // Max volume
          TextFormField(
            controller: _maxVolumeController,
            keyboardType: TextInputType.number,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Vui lòng nhập thể tích tối đa';
              }
              if (double.tryParse(v) == null) {
                return 'Thể tích không hợp lệ';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Thể tích tối đa (m³)',
              hintText: 'Ví dụ: 10',
              prefixIcon: Icon(Icons.view_in_ar_outlined),
            ),
          ),
          SizedBox(height: 16.h),

          // Fragile toggle
          SwitchListTile(
            title: const Text('Nhận chở hàng dễ vỡ'),
            subtitle: const Text(
              'Bật nếu bạn chấp nhận hàng dễ vỡ như thủy tinh, gốm sứ...',
            ),
            value: _acceptFragile,
            onChanged: (val) {
              setState(() {
                _acceptFragile = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      color: AppColors.surfaceContainerLowest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const Text('Quay lại'),
              ),
            )
          else
            const Spacer(),
          if (_currentStep > 0) SizedBox(width: 14.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (_currentStep == 0) {
                  if (_validateRoute()) {
                    setState(() {
                      _currentStep = 1;
                    });
                  }
                } else if (_currentStep == 1) {
                  if (_basicFormKey.currentState!.validate()) {
                    if (_departureDateTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng chọn ngày giờ khởi hành.'),
                        ),
                      );
                      return;
                    }

                    if (_isTruck(_selectedVehicle!)) {
                      setState(() {
                        _currentStep = 2;
                      });
                    } else {
                      _submitTrip(context);
                    }
                  }
                } else {
                  if (_cargoFormKey.currentState!.validate()) {
                    _submitTrip(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                _currentStep == _totalSteps - 1 ? 'Tạo chuyến' : 'Tiếp tục',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
