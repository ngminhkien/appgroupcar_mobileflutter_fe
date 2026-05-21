import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/location_search_item.dart';
import '../cubit/location_search_cubit.dart';
import '../cubit/location_search_state.dart';
import '../models/location_search_screen_args.dart';

class LocationSearchScreen extends StatelessWidget {
  const LocationSearchScreen({
    super.key,
    this.args = const LocationSearchScreenArgs(),
  });

  final LocationSearchScreenArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocationSearchCubit>(),
      child: _LocationSearchView(args: args),
    );
  }
}

class _LocationSearchView extends StatefulWidget {
  const _LocationSearchView({required this.args});

  final LocationSearchScreenArgs args;

  @override
  State<_LocationSearchView> createState() => _LocationSearchViewState();
}

class _LocationSearchViewState extends State<_LocationSearchView> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.args.initialQuery ?? '',
    );
    _scrollController = ScrollController()..addListener(_onScroll);
    _searchController.addListener(_onQueryChanged);

    final initialQuery = _searchController.text.trim();
    if (initialQuery.isNotEmpty) {
      context.read<LocationSearchCubit>().onQueryChanged(initialQuery);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onQueryChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.args.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 8.h),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: widget.args.hintText,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      ),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(
                    color: AppColors.secondary,
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocConsumer<LocationSearchCubit, LocationSearchState>(
              listener: (context, state) {
                if (state.errorMessage?.isNotEmpty ?? false) {
                  final message =
                      state.errorMessage?.replaceFirst('Exception: ', '') ??
                      'Khong the tim dia diem';
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
                }
              },
              builder: (context, state) {
                switch (state.status) {
                  case LocationSearchStatus.idle:
                    return _buildIdle();
                  case LocationSearchStatus.loading:
                    return const _LoadingList();
                  case LocationSearchStatus.error:
                    return _buildError(context, message: state.errorMessage);
                  case LocationSearchStatus.empty:
                    return _buildEmpty();
                  case LocationSearchStatus.success:
                    return _buildResults(context, state);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdle() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Text(
          'Nhap it nhat 1 ky tu de tim diem di/den',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 34.sp,
              color: AppColors.outline,
            ),
            SizedBox(height: 10.h),
            Text(
              'Khong tim thay dia diem phu hop',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, {String? message}) {
    final text =
        message?.replaceFirst('Exception: ', '') ?? 'Co loi khi tim dia diem';
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 14.h),
            ElevatedButton(
              onPressed: () => context.read<LocationSearchCubit>().retry(),
              child: const Text('Thu lai'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, LocationSearchState state) {
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.only(bottom: 12.h),
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Center(
              child: SizedBox(
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final item = state.items[index];
        return _LocationResultItem(
          item: item,
          onTap: () => context.pop<LocationSearchItem>(item),
        );
      },
      separatorBuilder: (_, __) =>
          Divider(height: 1.h, color: AppColors.surfaceContainer),
      itemCount: state.items.length + (state.isPaging ? 1 : 0),
    );
  }

  void _onQueryChanged() {
    setState(() {});
    context.read<LocationSearchCubit>().onQueryChanged(_searchController.text);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final threshold = _scrollController.position.maxScrollExtent - 160.h;
    if (_scrollController.position.pixels >= threshold) {
      context.read<LocationSearchCubit>().loadMore();
    }
  }
}

class _LocationResultItem extends StatelessWidget {
  const _LocationResultItem({required this.item, required this.onTap});

  final LocationSearchItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      leading: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.location_on_outlined,
          color: AppColors.primaryContainer,
          size: 18.sp,
        ),
      ),
      title: Text(
        item.name,
        style: TextStyle(
          color: AppColors.onSurface,
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        item.displayName,
        style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp),
      ),
      trailing: Text(
        item.code,
        style: TextStyle(
          color: AppColors.secondary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.only(top: 10.h, bottom: 12.h),
      itemBuilder: (_, __) => Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        height: 66.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.outlineVariant),
        ),
      ),
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemCount: 8,
    );
  }
}
