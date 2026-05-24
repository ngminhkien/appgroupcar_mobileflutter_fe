import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/bus_seat_map.dart';
import '../../domain/entities/bus_showtime_detail.dart';
import '../cubit/bus_seat_selection_cubit.dart';
import '../cubit/bus_seat_selection_state.dart';
import '../models/bus_seat_selection_args.dart';

class BusSeatSelectionScreen extends StatelessWidget {
  const BusSeatSelectionScreen({super.key, required this.args});

  final BusSeatSelectionArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BusSeatSelectionCubit>()..initialize(args),
      child: const _BusSeatSelectionView(),
    );
  }
}

class _BusSeatSelectionView extends StatelessWidget {
  const _BusSeatSelectionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Chon ghe',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          BlocBuilder<BusSeatSelectionCubit, BusSeatSelectionState>(
            builder: (context, state) {
              if (state.status == BusSeatSelectionStatus.loading) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<BusSeatSelectionCubit>().refresh(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<BusSeatSelectionCubit, BusSeatSelectionState>(
        builder: (context, state) {
          switch (state.status) {
            case BusSeatSelectionStatus.loading:
              return const _SeatLoadingView();
            case BusSeatSelectionStatus.failure:
              return _SeatErrorView(
                message: state.errorMessage,
                onRetry: () => context.read<BusSeatSelectionCubit>().refresh(),
              );
            case BusSeatSelectionStatus.success:
              if (state.detail == null || state.seatMap == null) {
                return _SeatErrorView(
                  message: 'Du lieu chon ghe khong hop le',
                  onRetry: () => context.read<BusSeatSelectionCubit>().refresh(),
                );
              }
              return _SeatSuccessView(state: state);
            case BusSeatSelectionStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
      bottomNavigationBar: BlocBuilder<BusSeatSelectionCubit, BusSeatSelectionState>(
        builder: (context, state) {
          if (state.status != BusSeatSelectionStatus.success) {
            return const SizedBox.shrink();
          }
          return _SeatBottomBar(state: state);
        },
      ),
    );
  }
}

class _SeatSuccessView extends StatelessWidget {
  const _SeatSuccessView({required this.state});

  final BusSeatSelectionState state;

  @override
  Widget build(BuildContext context) {
    final detail = state.detail!;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TripBriefCard(detail: detail),
          SizedBox(height: 12.h),
          const _SeatLegend(),
          SizedBox(height: 10.h),
          _SeatLayoutPanel(
            seatMap: state.seatMap!,
            selectedSeats: state.selectedSeats,
            onToggleSeat: (seatNumber) => context
                .read<BusSeatSelectionCubit>()
                .toggleSeatSelection(seatNumber),
          ),
          SizedBox(height: 10.h),
          if (state.selectedSeats.isEmpty)
            Text(
              'Vui long chon it nhat 1 ghe de tiep tuc dat ve.',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 12.sp,
              ),
            )
          else
            Text(
              'Ghe da chon: ${state.selectedSeats.join(', ')}',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 12.sp,
              ),
            ),
        ],
      ),
    );
  }
}

class _TripBriefCard extends StatelessWidget {
  const _TripBriefCard({required this.detail});

  final BusShowtimeDetail detail;

  @override
  Widget build(BuildContext context) {
    final departure = detail.departureDateTime;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.companyName.trim().isEmpty
                ? 'Nha xe dang cap nhat'
                : detail.companyName.trim(),
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 5.h),
          Text(
            detail.route?.name.trim().isNotEmpty == true
                ? detail.route!.name.trim()
                : 'Lo trinh dang cap nhat',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _InfoChip(
                icon: Icons.schedule_outlined,
                label: departure == null
                    ? 'Dang cap nhat gio'
                    : _formatDateTime(departure),
              ),
              _InfoChip(
                icon: Icons.sell_outlined,
                label: 'Gia/ghe: ${_formatMoney(detail.price)}',
                highlighted: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeatBottomBar extends StatelessWidget {
  const _SeatBottomBar({required this.state});

  final BusSeatSelectionState state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 10.h),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.selectedSeats.isEmpty
                  ? 'Chua chon ghe'
                  : 'Da chon ${state.selectedSeats.length} ghe',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Tam tinh: ${_formatMoney(state.totalSelectedPrice)}',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryContainer,
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: state.selectedSeats.isEmpty
                        ? null
                        : () => context
                              .read<BusSeatSelectionCubit>()
                              .clearSelectedSeats(),
                    child: const Text('Bo chon'),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: state.selectedSeats.isEmpty
                        ? null
                        : () => context.pop(state.selectedSeats),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.onSecondary,
                    ),
                    child: const Text('Xac nhan ghe'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SeatLegend extends StatelessWidget {
  const _SeatLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: const [
        _LegendItem(
          color: Color(0xFFFFF3EE),
          borderColor: AppColors.secondary,
          label: 'Con trong',
        ),
        _LegendItem(
          color: AppColors.secondary,
          borderColor: AppColors.secondary,
          label: 'Dang chon',
          textColor: AppColors.onSecondary,
        ),
        _LegendItem(
          color: Color(0xFFE5E7EB),
          borderColor: Color(0xFFB6BDC8),
          label: 'Da dat',
        ),
        _LegendItem(
          color: Color(0xFFCDD3DD),
          borderColor: Color(0xFF9FA8B7),
          label: 'Khong su dung',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.borderColor,
    required this.label,
    this.textColor = AppColors.onSurface,
  });

  final Color color;
  final Color borderColor;
  final String label;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18.w,
          height: 18.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5.r),
            border: Border.all(color: borderColor),
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SeatLayoutPanel extends StatelessWidget {
  const _SeatLayoutPanel({
    required this.seatMap,
    required this.selectedSeats,
    required this.onToggleSeat,
  });

  final BusSeatMap seatMap;
  final List<String> selectedSeats;
  final ValueChanged<String> onToggleSeat;

  @override
  Widget build(BuildContext context) {
    final resolvedLayout = _SeatLayoutResolver.resolve(seatMap);
    if (resolvedLayout.items.isEmpty) {
      return const _MissingSection(
        message: 'Khong doc duoc so do ghe. Vui long thu lai.',
      );
    }

    final selectedSet = selectedSeats.map(_normalizeSeatKey).toSet();
    final decks = resolvedLayout.items.map((item) => item.deck).toSet().toList()
      ..sort();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!resolvedLayout.usesLayoutJson)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Text(
                'Dang hien thi ghe theo thu tu mac dinh.',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11.sp,
                ),
              ),
            ),
          ...List.generate(decks.length, (index) {
            final deck = decks[index];
            final deckItems =
                resolvedLayout.items.where((item) => item.deck == deck).toList()
                  ..sort((a, b) {
                    if (a.row != b.row) {
                      return a.row.compareTo(b.row);
                    }
                    if (a.column != b.column) {
                      return a.column.compareTo(b.column);
                    }
                    return a.seatNumber.compareTo(b.seatNumber);
                  });

            final rows = <int, List<_ResolvedSeatItem>>{};
            for (final item in deckItems) {
              rows.putIfAbsent(item.row, () => <_ResolvedSeatItem>[]).add(item);
            }
            final rowKeys = rows.keys.toList()..sort();

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == decks.length - 1 ? 0 : 12.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (decks.length > 1)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        'Tang ${deck + 1}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ...List.generate(rowKeys.length, (rowIndex) {
                    final row = rowKeys[rowIndex];
                    final rowItems = rows[row]!
                      ..sort((a, b) => a.column.compareTo(b.column));
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: rowIndex == rowKeys.length - 1 ? 0 : 7.h,
                      ),
                      child: _SeatRow(
                        rowItems: rowItems,
                        selectedSeatKeys: selectedSet,
                        onToggleSeat: onToggleSeat,
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SeatRow extends StatelessWidget {
  const _SeatRow({
    required this.rowItems,
    required this.selectedSeatKeys,
    required this.onToggleSeat,
  });

  final List<_ResolvedSeatItem> rowItems;
  final Set<String> selectedSeatKeys;
  final ValueChanged<String> onToggleSeat;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    var previousColumn = -1;
    for (final seat in rowItems) {
      if (previousColumn >= 0 && seat.column - previousColumn > 1) {
        final gap = min(seat.column - previousColumn - 1, 3);
        children.add(SizedBox(width: (gap * 16).w));
      }
      previousColumn = seat.column;
      final key = _normalizeSeatKey(seat.seatNumber);
      final isSelected = selectedSeatKeys.contains(key);
      children.add(
        _SeatBox(
          seatNumber: seat.seatNumber,
          status: seat.status.availability,
          isSelected: isSelected,
          onTap: seat.status.availability == BusSeatAvailability.available
              ? () => onToggleSeat(seat.seatNumber)
              : null,
        ),
      );
      children.add(SizedBox(width: 7.w));
    }
    if (children.isNotEmpty) {
      children.removeLast();
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: children),
    );
  }
}

class _SeatBox extends StatelessWidget {
  const _SeatBox({
    required this.seatNumber,
    required this.status,
    required this.isSelected,
    this.onTap,
  });

  final String seatNumber;
  final BusSeatAvailability status;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = _seatVisualStyle(status, isSelected: isSelected);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 38.w,
        height: 36.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: style.border),
        ),
        child: Text(
          seatNumber,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: style.foreground,
          ),
        ),
      ),
    );
  }
}

class _SeatLoadingView extends StatelessWidget {
  const _SeatLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(18.w),
      itemBuilder: (_, __) => Container(
        height: 140.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14.r),
        ),
      ),
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemCount: 3,
    );
  }
}

class _SeatErrorView extends StatelessWidget {
  const _SeatErrorView({required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final text =
        message?.replaceFirst('Exception: ', '') ?? 'Khong the tai du lieu ghe';
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 26.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 36.sp, color: AppColors.error),
            SizedBox(height: 10.h),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 14.h),
            ElevatedButton(onPressed: onRetry, child: const Text('Thu lai')),
          ],
        ),
      ),
    );
  }
}

class _MissingSection extends StatelessWidget {
  const _MissingSection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        message,
        style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final background = highlighted
        ? AppColors.secondaryContainer
        : AppColors.surfaceContainerLow;
    final foreground = highlighted ? AppColors.secondary : AppColors.onSurface;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: foreground),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResolvedSeatLayout {
  const _ResolvedSeatLayout({
    required this.items,
    required this.usesLayoutJson,
  });

  final List<_ResolvedSeatItem> items;
  final bool usesLayoutJson;
}

class _ResolvedSeatItem {
  const _ResolvedSeatItem({
    required this.seatNumber,
    required this.status,
    required this.row,
    required this.column,
    required this.deck,
  });

  final String seatNumber;
  final BusSeatStatus status;
  final int row;
  final int column;
  final int deck;
}

class _SeatLayoutResolver {
  static _ResolvedSeatLayout resolve(BusSeatMap seatMap) {
    final statusMap = <String, BusSeatStatus>{};
    for (final seat in seatMap.seats) {
      final key = _normalizeSeatKey(seat.seatNumber);
      if (key.isEmpty) {
        continue;
      }
      statusMap[key] = seat;
    }

    final layoutCandidates = _extractLayoutSeats(seatMap.seatLayout.layoutJson);
    final layoutBySeat = <String, _LayoutSeatCandidate>{};
    for (final candidate in layoutCandidates) {
      final key = _normalizeSeatKey(candidate.seatNumber);
      if (key.isEmpty) {
        continue;
      }
      final current = layoutBySeat[key];
      if (current == null || _isBetterCandidate(candidate, current)) {
        layoutBySeat[key] = candidate;
      }
    }

    final items = <_ResolvedSeatItem>[];
    final knownSeats = <String>{};

    for (final entry in layoutBySeat.entries) {
      final key = entry.key;
      final candidate = entry.value;
      final status =
          statusMap[key] ??
          BusSeatStatus(seatNumber: candidate.seatNumber, status: 'Disabled');
      final parts = _parseSeatLabel(candidate.seatNumber);
      final row = candidate.row ?? parts.row ?? (items.length + 1);
      final column = candidate.column ?? parts.column ?? 1;
      final deck = candidate.deck ?? 0;
      items.add(
        _ResolvedSeatItem(
          seatNumber: status.seatNumber.trim().isEmpty
              ? candidate.seatNumber
              : status.seatNumber,
          status: status,
          row: row,
          column: column,
          deck: deck,
        ),
      );
      knownSeats.add(key);
    }

    final remaining =
        statusMap.entries
            .where((entry) => !knownSeats.contains(entry.key))
            .map((entry) => entry.value)
            .toList()
          ..sort((a, b) => _seatSort(a.seatNumber, b.seatNumber));

    for (var index = 0; index < remaining.length; index++) {
      final seat = remaining[index];
      final parts = _parseSeatLabel(seat.seatNumber);
      final fallbackRow = parts.row ?? (1000 + (index ~/ 4));
      final fallbackColumn = parts.column ?? ((index % 4) + 1);
      items.add(
        _ResolvedSeatItem(
          seatNumber: seat.seatNumber,
          status: seat,
          row: fallbackRow,
          column: fallbackColumn,
          deck: 0,
        ),
      );
    }

    items.sort((a, b) {
      if (a.deck != b.deck) {
        return a.deck.compareTo(b.deck);
      }
      if (a.row != b.row) {
        return a.row.compareTo(b.row);
      }
      if (a.column != b.column) {
        return a.column.compareTo(b.column);
      }
      return _seatSort(a.seatNumber, b.seatNumber);
    });

    return _ResolvedSeatLayout(
      items: items,
      usesLayoutJson: layoutBySeat.isNotEmpty,
    );
  }

  static List<_LayoutSeatCandidate> _extractLayoutSeats(
    Map<String, dynamic>? layoutJson,
  ) {
    if (layoutJson == null || layoutJson.isEmpty) {
      return const [];
    }
    final results = <_LayoutSeatCandidate>[];
    _walkNode(layoutJson, results: results, depth: 0);
    return results;
  }

  static void _walkNode(
    dynamic node, {
    required List<_LayoutSeatCandidate> results,
    required int depth,
    int? inheritedRow,
    int? inheritedColumn,
    int? inheritedDeck,
  }) {
    if (depth > 24) {
      return;
    }
    if (node is Map<String, dynamic>) {
      final row =
          _extractInt(node, const ['row', 'rowIndex', 'seatRow', 'r', 'y']) ??
          inheritedRow;
      final column =
          _extractInt(node, const [
            'column',
            'col',
            'columnIndex',
            'seatColumn',
            'c',
            'x',
          ]) ??
          inheritedColumn;
      final deck =
          _extractInt(node, const ['deck', 'floor', 'level']) ?? inheritedDeck;
      final seatNumber = _extractString(node, const [
        'seatNumber',
        'seatNo',
        'seat_no',
        'number',
        'code',
      ]);

      if (seatNumber != null && seatNumber.trim().isNotEmpty) {
        results.add(
          _LayoutSeatCandidate(
            seatNumber: seatNumber.trim(),
            row: row,
            column: column,
            deck: deck,
          ),
        );
      }

      for (final value in node.values) {
        _walkNode(
          value,
          results: results,
          depth: depth + 1,
          inheritedRow: row,
          inheritedColumn: column,
          inheritedDeck: deck,
        );
      }
      return;
    }

    if (node is List<dynamic>) {
      for (final value in node) {
        _walkNode(
          value,
          results: results,
          depth: depth + 1,
          inheritedRow: inheritedRow,
          inheritedColumn: inheritedColumn,
          inheritedDeck: inheritedDeck,
        );
      }
    }
  }
}

class _LayoutSeatCandidate {
  const _LayoutSeatCandidate({
    required this.seatNumber,
    required this.row,
    required this.column,
    required this.deck,
  });

  final String seatNumber;
  final int? row;
  final int? column;
  final int? deck;
}

class _SeatLabelParts {
  const _SeatLabelParts({this.row, this.column});

  final int? row;
  final int? column;
}

class _SeatVisualStyle {
  const _SeatVisualStyle({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;
}

_SeatVisualStyle _seatVisualStyle(
  BusSeatAvailability status, {
  required bool isSelected,
}) {
  if (isSelected) {
    return const _SeatVisualStyle(
      background: AppColors.secondary,
      border: AppColors.secondary,
      foreground: AppColors.onSecondary,
    );
  }
  switch (status) {
    case BusSeatAvailability.available:
      return const _SeatVisualStyle(
        background: Color(0xFFFFF3EE),
        border: AppColors.secondary,
        foreground: AppColors.onSurface,
      );
    case BusSeatAvailability.booked:
      return const _SeatVisualStyle(
        background: Color(0xFFE5E7EB),
        border: Color(0xFFB6BDC8),
        foreground: AppColors.onSurfaceVariant,
      );
    case BusSeatAvailability.disabled:
      return const _SeatVisualStyle(
        background: Color(0xFFCDD3DD),
        border: Color(0xFF9FA8B7),
        foreground: AppColors.onSurfaceVariant,
      );
    case BusSeatAvailability.unknown:
      return const _SeatVisualStyle(
        background: AppColors.surfaceContainer,
        border: AppColors.outlineVariant,
        foreground: AppColors.onSurfaceVariant,
      );
  }
}

bool _isBetterCandidate(
  _LayoutSeatCandidate next,
  _LayoutSeatCandidate current,
) {
  final nextScore = (next.row != null ? 1 : 0) + (next.column != null ? 1 : 0);
  final currentScore =
      (current.row != null ? 1 : 0) + (current.column != null ? 1 : 0);
  if (nextScore != currentScore) {
    return nextScore > currentScore;
  }
  return (next.deck ?? 0) < (current.deck ?? 0);
}

int? _extractInt(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return null;
}

String? _extractString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
  }
  return null;
}

String _formatDateTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute - $day/$month/$year';
}

String _formatMoney(double value) {
  final number = value.round().toString();
  final chars = number.split('').reversed.toList();
  final buffer = StringBuffer();
  for (var index = 0; index < chars.length; index++) {
    if (index > 0 && index % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(chars[index]);
  }
  final formatted = buffer.toString().split('').reversed.join();
  return '$formatted d';
}

String _normalizeSeatKey(String value) {
  return value.trim().toUpperCase();
}

_SeatLabelParts _parseSeatLabel(String seatNumber) {
  final normalized = seatNumber.trim().toUpperCase();
  if (normalized.isEmpty) {
    return const _SeatLabelParts();
  }

  final alphaNumeric = RegExp(r'^([A-Z]+)(\d+)$');
  final alphaNumericMatch = alphaNumeric.firstMatch(normalized);
  if (alphaNumericMatch != null) {
    final letters = alphaNumericMatch.group(1) ?? '';
    final digits = alphaNumericMatch.group(2) ?? '';
    var row = 0;
    for (final codeUnit in letters.codeUnits) {
      row = row * 26 + (codeUnit - 64);
    }
    final column = int.tryParse(digits);
    return _SeatLabelParts(row: row > 0 ? row : null, column: column);
  }

  final numeric = RegExp(r'^(\d+)$');
  final numericMatch = numeric.firstMatch(normalized);
  if (numericMatch != null) {
    return _SeatLabelParts(column: int.tryParse(numericMatch.group(1) ?? ''));
  }

  return const _SeatLabelParts();
}

int _seatSort(String left, String right) {
  final leftParts = _parseSeatLabel(left);
  final rightParts = _parseSeatLabel(right);
  final leftRow = leftParts.row ?? (1 << 30);
  final rightRow = rightParts.row ?? (1 << 30);
  if (leftRow != rightRow) {
    return leftRow.compareTo(rightRow);
  }
  final leftColumn = leftParts.column ?? (1 << 30);
  final rightColumn = rightParts.column ?? (1 << 30);
  if (leftColumn != rightColumn) {
    return leftColumn.compareTo(rightColumn);
  }
  return left.compareTo(right);
}
