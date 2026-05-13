import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../theme/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final role =
        context.select((AuthCubit cubit) => cubit.state.role)?.toUpperCase() ??
        'USER';
    final items = role == 'DRIVER' ? _driverItems : _userItems;
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _resolveIndex(items, location);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppColors.secondary,
      unselectedItemColor: AppColors.outline,
      type: BottomNavigationBarType.fixed,
      onTap: (index) => context.go(items[index].route),
      items: items
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.label,
            ),
          )
          .toList(),
    );
  }

  int _resolveIndex(List<_NavItem> items, String location) {
    final index = items.indexWhere(
      (item) => location == item.route || location.startsWith('${item.route}/'),
    );
    return index == -1 ? 0 : index;
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

const List<_NavItem> _userItems = [
  _NavItem(label: 'Trang chủ', icon: Icons.home, route: '/home'),
  _NavItem(
    label: 'Vé của tôi',
    icon: Icons.confirmation_number_outlined,
    route: '/my_tickets',
  ),
  _NavItem(
    label: 'Hỗ trợ',
    icon: Icons.support_agent_outlined,
    route: '/support',
  ),
  _NavItem(label: 'Cá nhân', icon: Icons.person, route: '/profile'),
];

const List<_NavItem> _driverItems = [
  _NavItem(label: 'Trang chủ', icon: Icons.home, route: '/home'),
  _NavItem(label: 'Chuyến đi', icon: Icons.history, route: '/my_trips'),
  _NavItem(
    label: 'Tạo chuyến',
    icon: Icons.add_circle_outline,
    route: '/create_trip',
  ),
  _NavItem(
    label: 'Hỗ trợ',
    icon: Icons.support_agent_outlined,
    route: '/support',
  ),
  _NavItem(label: 'Cá nhân', icon: Icons.person, route: '/profile'),
];
