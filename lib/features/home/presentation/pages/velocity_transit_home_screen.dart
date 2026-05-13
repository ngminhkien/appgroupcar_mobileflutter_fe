import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../trips/presentation/widgets/trip_card.dart';

class VelocityTransitHomeScreen extends StatefulWidget {
  const VelocityTransitHomeScreen({super.key});

  @override
  State<VelocityTransitHomeScreen> createState() =>
      _VelocityTransitHomeScreenState();
}

class _VelocityTransitHomeScreenState extends State<VelocityTransitHomeScreen> {
  final Set<String> _selectedServices = {'Xe khách'};
  String _fromLocation = '';
  String _toLocation = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<_FeaturedTrip> _featuredTrips = const [
    _FeaturedTrip(
      serviceType: 'Xe khách',
      from: 'Bến xe Miền Đông',
      to: 'Bến xe Đà Nẵng',
      time: '06:30 • 05/05',
      price: '320.000đ',
      seatInfo: 'Còn 12 chỗ',
    ),
    _FeaturedTrip(
      serviceType: 'Xe ghép',
      from: 'Sân bay Nội Bài',
      to: 'Bến xe Giáp Bát',
      time: '09:15 • 05/05',
      price: '140.000đ',
      seatInfo: 'Còn 5 chỗ',
    ),
    _FeaturedTrip(
      serviceType: 'Chở hàng',
      from: 'Kho Thủ Đức',
      to: 'Quận 1',
      time: '14:00 • 05/05',
      price: '220.000đ',
      seatInfo: 'Nhận trong ngày',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào,',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                'Bạn muốn đi đâu hôm nay?',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryContainer,
                ),
              ),
              SizedBox(height: 16.h),
              _buildSearchForm(context),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/search_results'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.onSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    'Tìm chuyến đi',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Chuyến nổi bật',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              ..._featuredTrips.map(
                (trip) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: TripCard(
                    serviceType: trip.serviceType,
                    from: trip.from,
                    to: trip.to,
                    time: trip.time,
                    price: trip.price,
                    seatInfo: trip.seatInfo,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }

  Widget _buildSearchForm(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.surfaceContainerLow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dịch vụ',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: [
              _buildServiceOption(
                label: 'Xe khách',
                subtitle: 'Tuyến cố định, giá tốt',
                icon: Icons.directions_bus_filled_outlined,
              ),
              _buildServiceOption(
                label: 'Xe ghép',
                subtitle: 'Đi chung, linh hoạt',
                icon: Icons.airport_shuttle_outlined,
              ),
              _buildServiceOption(
                label: 'Chở hàng',
                subtitle: 'Giao nhanh trong ngày',
                icon: Icons.local_shipping_outlined,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInputField(
            label: 'Từ đâu',
            value: _fromLocation,
            placeholder: 'Chọn điểm đi',
            icon: Icons.my_location,
            onTap: () => _openLocationSearch(isFrom: true),
          ),
          SizedBox(height: 12.h),
          _buildInputField(
            label: 'Đến đâu',
            value: _toLocation,
            placeholder: 'Chọn điểm đến',
            icon: Icons.location_on,
            onTap: () => _openLocationSearch(isFrom: false),
          ),
          SizedBox(height: 12.h),
          _buildInputField(
            label: 'Thời gian',
            value: _formatDateTime(),
            placeholder: 'Chọn ngày và giờ',
            icon: Icons.calendar_today,
            trailing: Icons.schedule,
            onTap: _pickDateTime,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceOption({
    required String label,
    required String subtitle,
    required IconData icon,
  }) {
    final bool isSelected = _selectedServices.contains(label);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleService(label, !isSelected),
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.secondaryContainer
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.secondary
                  : AppColors.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.secondary.withValues(alpha: 0.15)
                      : AppColors.surfaceContainerLowest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 18.sp,
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.primaryContainer,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10.w),
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                size: 18.sp,
                color: isSelected ? AppColors.secondary : AppColors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String value,
    required String placeholder,
    required IconData icon,
    required VoidCallback onTap,
    IconData? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.surfaceContainerLow),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: AppColors.primaryContainer),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      value.isEmpty ? placeholder : value,
                      style: TextStyle(
                        fontSize: 14.sp,
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
              Icon(
                trailing ?? Icons.chevron_right,
                size: 20.sp,
                color: AppColors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleService(String label, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedServices.add(label);
      } else {
        _selectedServices.remove(label);
      }
    });
  }

  Future<void> _openLocationSearch({required bool isFrom}) async {
    final result = await context.push<String>('/location_search');
    if (!mounted || result == null) {
      return;
    }
    setState(() {
      if (isFrom) {
        _fromLocation = result;
      } else {
        _toLocation = result;
      }
    });
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? now;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) {
      return;
    }
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.fromDateTime(now),
    );
    if (pickedTime == null || !mounted) {
      return;
    }
    setState(() {
      _selectedDate = pickedDate;
      _selectedTime = pickedTime;
    });
  }

  String _formatDateTime() {
    if (_selectedDate == null || _selectedTime == null) {
      return '';
    }
    final date = _selectedDate!;
    final time = _selectedTime!;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} • $hour:$minute';
  }
}

class _FeaturedTrip {
  final String serviceType;
  final String from;
  final String to;
  final String time;
  final String price;
  final String seatInfo;

  const _FeaturedTrip({
    required this.serviceType,
    required this.from,
    required this.to,
    required this.time,
    required this.price,
    required this.seatInfo,
  });
}
