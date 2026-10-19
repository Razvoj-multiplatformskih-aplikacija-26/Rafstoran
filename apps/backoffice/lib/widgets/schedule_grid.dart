import 'package:design_tokens/design_tokens.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:ui/ui.dart';
import 'package:use_cases/use_cases.dart';

import 'reservation_cell.dart';

typedef GridCursor = ({int row, int column});

class ScheduleGrid extends StatefulWidget {
  const ScheduleGrid({
    super.key,
    required this.schedule,
    required this.selectedId,
    required this.focusNode,
    required this.initialCursor,
    required this.onCursorChanged,
    required this.onSelect,
    required this.onContextMenu,
  });

  final DailySchedule schedule;
  final ReservationId? selectedId;
  final FocusNode focusNode;
  final GridCursor initialCursor;
  final ValueChanged<GridCursor> onCursorChanged;
  final ValueChanged<Reservation?> onSelect;
  final void Function(Reservation reservation, Offset globalPosition) onContextMenu;

  @override
  State<ScheduleGrid> createState() => _ScheduleGridState();
}

class _ScheduleGridState extends State<ScheduleGrid> {
  static const _tableColumnWidth = 116.0;
  static const _slotColumnWidth = 92.0;
  static const _headerHeight = 40.0;
  static const _rowHeight = 60.0;

  final _horizontal = ScrollController();
  final _vertical = ScrollController();

  List<DiningTable> get _tables => widget.schedule.tables;
  List<DateTime> get _halfHours => widget.schedule.halfHours;
  FocusNode get _focusNode => widget.focusNode;
  late int _cursorRow = widget.initialCursor.row.clamp(0, _tables.length - 1);
  late int _cursorColumn = widget.initialCursor.column.clamp(0, _halfHours.length - 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCursorColumn());
  }

  @override
  void didUpdateWidget(ScheduleGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedId != null && widget.selectedId != oldWidget.selectedId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected());
    }
  }

  void _revealSelected() {
    final selected = widget.schedule.reservations.where((r) => r.id == widget.selectedId).firstOrNull;
    if (selected == null) return;
    final first = _halfHours.indexWhere((h) => !h.isBefore(selected.slot.start));
    final end = _halfHours.indexWhere((h) => !h.isBefore(selected.slot.end));
    if (first < 0) return;
    final last = end < 0 ? _halfHours.length : end;
    _reveal(
      _horizontal,
      start: first * _slotColumnWidth,
      extent: (last - first) * _slotColumnWidth,
      pinned: _tableColumnWidth,
    );
  }

  void _scrollToCursorColumn() {
    if (!_horizontal.hasClients) return;
    final position = _horizontal.position;
    final offset = (_cursorColumn - 2) * _slotColumnWidth;
    _horizontal.jumpTo(offset.clamp(position.minScrollExtent, position.maxScrollExtent));
  }

  @override
  void dispose() {
    _horizontal.dispose();
    _vertical.dispose();
    super.dispose();
  }

  void _revealCursor() {
    _reveal(_horizontal, start: _cursorColumn * _slotColumnWidth, extent: _slotColumnWidth, pinned: _tableColumnWidth);
    _reveal(_vertical, start: _cursorRow * _rowHeight, extent: _rowHeight, pinned: _headerHeight);
  }

  void _reveal(ScrollController controller, {required double start, required double extent, required double pinned}) {
    if (!controller.hasClients) return;
    final position = controller.position;
    final visible = position.viewportDimension - pinned;
    final double target;
    if (start < position.pixels) {
      target = start;
    } else if (start + extent > position.pixels + visible) {
      target = start + extent - visible;
    } else {
      return;
    }
    controller.animateTo(
      target.clamp(position.minScrollExtent, position.maxScrollExtent),
      duration: MotionTokens.short,
      curve: Curves.easeOut,
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final (dRow, dColumn) = switch (key) {
      LogicalKeyboardKey.arrowUp => (-1, 0),
      LogicalKeyboardKey.arrowDown => (1, 0),
      LogicalKeyboardKey.arrowLeft => (0, -1),
      LogicalKeyboardKey.arrowRight => (0, 1),
      _ => (0, 0),
    };
    if (dRow != 0 || dColumn != 0) {
      if (HardwareKeyboard.instance.isAltPressed) return KeyEventResult.ignored;
      _moveCursor(
        (_cursorRow + dRow).clamp(0, _tables.length - 1),
        (_cursorColumn + dColumn).clamp(0, _halfHours.length - 1),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealCursor());
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter || key == LogicalKeyboardKey.space) {
      widget.onSelect(widget.schedule.reservationAt(_tables[_cursorRow], _halfHours[_cursorColumn]));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _moveCursor(int row, int column) {
    setState(() {
      _cursorRow = row;
      _cursorColumn = column;
    });
    widget.onCursorChanged((row: row, column: column));
  }

  void _moveCursorTo(int row, int column) {
    _moveCursor(row, column);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final border = BorderSide(color: scheme.outlineVariant);
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _onKey,
      child: Semantics(
        container: true,
        label: 'Dnevni raspored, ${_tables.length} stolova',
        child: ListenableBuilder(
          listenable: _focusNode,
          builder: (context, _) => TableView.builder(
            horizontalDetails: ScrollableDetails.horizontal(controller: _horizontal),
            verticalDetails: ScrollableDetails.vertical(controller: _vertical),
            columnCount: _halfHours.length + 1,
            rowCount: _tables.length + 1,
            pinnedRowCount: 1,
            pinnedColumnCount: 1,
            columnBuilder: (index) => TableSpan(
              extent: FixedSpanExtent(index == 0 ? _tableColumnWidth : _slotColumnWidth),
              backgroundDecoration: SpanDecoration(
                border: SpanBorder(trailing: border),
                color: index == 0 ? scheme.surfaceContainerLow : null,
              ),
            ),
            rowBuilder: (index) => TableSpan(
              extent: FixedSpanExtent(index == 0 ? _headerHeight : _rowHeight),
              backgroundDecoration: SpanDecoration(
                border: SpanBorder(trailing: border),
                color: index == 0 ? scheme.surfaceContainerLow : null,
              ),
            ),
            cellBuilder: _buildCell,
          ),
        ),
      ),
    );
  }

  TableViewCell _buildCell(BuildContext context, TableVicinity vicinity) {
    final theme = Theme.of(context);
    if (vicinity.row == 0 && vicinity.column == 0) return const TableViewCell(child: SizedBox.shrink());
    if (vicinity.row == 0) {
      final instant = _halfHours[vicinity.column - 1];
      final local = restaurantTime(instant);
      final isFullHour = local.minute == 0;
      return TableViewCell(
        child: Semantics(
          header: true,
          child: Center(
            child: Text(
              formatTime(instant),
              style: (isFullHour ? theme.textTheme.labelLarge : theme.textTheme.labelMedium)?.copyWith(
                color: isFullHour ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }
    final table = _tables[vicinity.row - 1];
    if (vicinity.column == 0) {
      return TableViewCell(child: _TableHeader(table: table));
    }
    final instant = _halfHours[vicinity.column - 1];
    final reservation = widget.schedule.reservationAt(table, instant);
    final rowIndex = vicinity.row - 1;
    final columnIndex = vicinity.column - 1;
    final focused = _focusNode.hasFocus && _cursorRow == rowIndex;
    if (reservation == null) {
      return TableViewCell(
        child: _EmptyCell(
          focused: focused && _cursorColumn == columnIndex,
          onTap: () {
            _moveCursorTo(rowIndex, columnIndex);
            widget.onSelect(null);
          },
        ),
      );
    }
    final startIndex = _halfHours.indexWhere((h) => !h.isBefore(reservation.slot.start));
    final endIndex = _halfHours.indexWhere((h) => !h.isBefore(reservation.slot.end));
    final firstColumn = (startIndex < 0 ? 0 : startIndex) + 1;
    final lastColumnExclusive = (endIndex < 0 ? _halfHours.length : endIndex) + 1;
    final span = (lastColumnExclusive - firstColumn).clamp(1, _halfHours.length);
    final cursorInside = focused && _cursorColumn + 1 >= firstColumn && _cursorColumn + 1 < firstColumn + span;
    return TableViewCell(
      columnMergeStart: firstColumn,
      columnMergeSpan: span,
      child: ReservationCell(
        reservation: reservation,
        guestName: widget.schedule.guestNameOf(reservation),
        selected: reservation.id == widget.selectedId,
        focused: cursorInside,
        onTap: () {
          _moveCursorTo(rowIndex, firstColumn - 1);
          widget.onSelect(reservation);
        },
        onContextMenu: (position) {
          _moveCursorTo(rowIndex, firstColumn - 1);
          widget.onContextMenu(reservation, position);
        },
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.table});

  final DiningTable table;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final area = switch (table.area) {
      TableArea.hall => 'sala',
      TableArea.terrace => 'terasa',
      TableArea.garden => 'bašta',
    };
    return Semantics(
      header: true,
      label: 'Sto ${table.label}, $area, ${seatsLabel(table.capacity)}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(table.label, style: theme.textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              '$area · ${seatsLabel(table.capacity)}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCell extends StatefulWidget {
  const _EmptyCell({required this.focused, required this.onTap});

  final bool focused;
  final VoidCallback onTap;

  @override
  State<_EmptyCell> createState() => _EmptyCellState();
}

class _EmptyCellState extends State<_EmptyCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _hovered ? scheme.onSurface.withValues(alpha: 0.05) : null,
                borderRadius: BorderRadius.circular(8),
                border: widget.focused ? Border.all(color: scheme.onSurface, width: 2) : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
