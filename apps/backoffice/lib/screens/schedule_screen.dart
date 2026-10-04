import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../dependencies.dart';
import '../shortcuts.dart';
import '../widgets/reservation_detail_panel.dart';
import '../widgets/schedule_grid.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, required this.day, this.selectedId});

  final DateTime day;
  final ReservationId? selectedId;

  static String pathFor(DateTime day, {ReservationId? selected}) {
    final date = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    return selected == null ? '/schedule/$date' : '/schedule/$date?reservation=${selected.value}';
  }

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DailyScheduleBloc get _bloc => context.read<DailyScheduleBloc>();

  @override
  void initState() {
    super.initState();
    _syncWithRoute();
  }

  @override
  void didUpdateWidget(ScheduleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.day != widget.day || oldWidget.selectedId != widget.selectedId) _syncWithRoute();
  }

  void _syncWithRoute() {
    final state = _bloc.state;
    if (state.day != widget.day) {
      _bloc.add(DailyScheduleRequested(widget.day));
    }
    if (state is DailyScheduleLoaded && state.selectedId != widget.selectedId) {
      _bloc.add(ScheduleReservationSelected(widget.selectedId));
    }
  }

  void _goTo(DateTime day, {ReservationId? selected}) => context.go(ScheduleScreen.pathFor(day, selected: selected));

  void _select(Reservation? reservation) {
    _bloc.add(ScheduleReservationSelected(reservation?.id));
    _goTo(widget.day, selected: reservation?.id);
  }

  Reservation? get _selected => switch (_bloc.state) {
    DailyScheduleLoaded(:final selected) => selected,
    _ => null,
  };

  void _confirm([Reservation? reservation]) {
    final target = reservation ?? _selected;
    if (target != null) _bloc.add(ScheduleConfirmationRequested(target.id));
  }

  void _recordArrival([Reservation? reservation]) {
    final target = reservation ?? _selected;
    if (target != null) _bloc.add(ScheduleArrivalRequested(target.id));
  }

  Future<void> _cancel([Reservation? reservation]) async {
    final target = reservation ?? _selected;
    if (target == null) return;
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _CancellationDialog(reservation: target),
    );
    if (!mounted || reason == null) return;
    _bloc.add(ScheduleCancellationRequested(target.id, reason: reason.trim()));
  }

  Future<void> _showContextMenu(Reservation reservation, Offset position) async {
    final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
    final action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(position & const Size(1, 1), Offset.zero & overlay.size),
      items: [
        if (reservation.status is Pending) const PopupMenuItem(value: 'confirm', child: Text('Potvrdi')),
        if (reservation.status is Confirmed) const PopupMenuItem(value: 'arrival', child: Text('Gost stigao')),
        if (!reservation.status.isFinal) const PopupMenuItem(value: 'cancel', child: Text('Otkaži')),
        const PopupMenuItem(value: 'details', child: Text('Detalji')),
      ],
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'confirm':
        _confirm(reservation);
      case 'arrival':
        _recordArrival(reservation);
      case 'cancel':
        await _cancel(reservation);
      case 'details':
        _select(reservation);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.day,
      firstDate: DateTime(2026),
      lastDate: DateTime(2027, 12, 31),
    );
    if (picked != null) _goTo(picked);
  }

  void _showNotice(BuildContext context, ScheduleNotice notice) {
    final message = switch (notice) {
      ScheduleActionSucceeded(:final reservation) => switch (reservation.status) {
        Confirmed() => 'Rezervacija je potvrđena.',
        Arrived() => 'Dolazak je zabeležen.',
        Cancelled() => 'Rezervacija je otkazana.',
        Pending() => 'Rezervacija je ažurirana.',
      },
      ScheduleActionRejected(:final error) => error.message,
      ScheduleActionFailed() => 'Izmena nije sačuvana.',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    _bloc.add(const DailyScheduleNoticeAcknowledged());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = _bloc;
    final fake = context.read<BackofficeDependencies>().fakeSchedule;
    return Shortcuts(
      shortcuts: scheduleShortcuts(),
      child: Actions(
        actions: {
          ConfirmSelectedIntent: CallbackAction<ConfirmSelectedIntent>(onInvoke: (_) => _confirm()),
          RecordArrivalIntent: CallbackAction<RecordArrivalIntent>(onInvoke: (_) => _recordArrival()),
          CancelSelectedIntent: CallbackAction<CancelSelectedIntent>(onInvoke: (_) => _cancel()),
          ClearSelectionIntent: CallbackAction<ClearSelectionIntent>(onInvoke: (_) => _select(null)),
          PreviousDayIntent: CallbackAction<PreviousDayIntent>(
            onInvoke: (_) => _goTo(widget.day.subtract(const Duration(days: 1))),
          ),
          NextDayIntent: CallbackAction<NextDayIntent>(onInvoke: (_) => _goTo(widget.day.add(const Duration(days: 1)))),
          TodayIntent: CallbackAction<TodayIntent>(onInvoke: (_) => _goTo(bloc.today)),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  const RafstoranWordmark(),
                  const SizedBox(width: 10),
                  Text(
                    'Backoffice',
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Prethodni dan ($optionKeyLabel ←)',
                  onPressed: () => _goTo(widget.day.subtract(const Duration(days: 1))),
                  icon: const Icon(Icons.chevron_left),
                ),
                TextButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text(capitalize(formatLongDate(widget.day))),
                ),
                IconButton(
                  tooltip: 'Sledeći dan ($optionKeyLabel →)',
                  onPressed: () => _goTo(widget.day.add(const Duration(days: 1))),
                  icon: const Icon(Icons.chevron_right),
                ),
                TextButton(onPressed: () => _goTo(bloc.today), child: const Text('Danas')),
                const SizedBox(width: 8),
                if (kDebugMode && fake != null)
                  IconButton(
                    tooltip: 'Simuliraj grešku',
                    onPressed: () {
                      fake.failingRequests = 1;
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Sledeći zahtev neće uspeti.')));
                    },
                    icon: const Icon(Icons.cloud_off_outlined),
                  ),
                const SizedBox(width: 8),
              ],
            ),
            body: BlocConsumer<DailyScheduleBloc, DailyScheduleState>(
              listenWhen: (previous, current) => current is DailyScheduleLoaded && current.notice != null,
              listener: (context, state) => _showNotice(context, (state as DailyScheduleLoaded).notice!),
              builder: (context, state) => switch (state) {
                DailyScheduleLoading() => const Center(child: CircularProgressIndicator()),
                DailyScheduleFailure() => Center(
                  child: FailureView(onRetry: () => bloc.add(DailyScheduleRequested(widget.day))),
                ),
                DailyScheduleLoaded() => _LoadedBody(
                  state: state,
                  onSelect: _select,
                  onContextMenu: _showContextMenu,
                  onConfirm: _confirm,
                  onArrival: _recordArrival,
                  onCancel: _cancel,
                ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({
    required this.state,
    required this.onSelect,
    required this.onContextMenu,
    required this.onConfirm,
    required this.onArrival,
    required this.onCancel,
  });

  final DailyScheduleLoaded state;
  final ValueChanged<Reservation?> onSelect;
  final void Function(Reservation reservation, Offset position) onContextMenu;
  final void Function([Reservation? reservation]) onConfirm;
  final void Function([Reservation? reservation]) onArrival;
  final Future<void> Function([Reservation? reservation]) onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = state.selected;
    final schedule = state.schedule;
    return Column(
      children: [
        if (state.isBusy) const LinearProgressIndicator(minHeight: 3) else const SizedBox(height: 3),
        if (state.isEmpty)
          Container(
            width: double.infinity,
            color: theme.colorScheme.surfaceContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Semantics(
              liveRegion: true,
              child: Text('Nema rezervacija za ovaj dan.', style: theme.textTheme.bodyMedium),
            ),
          ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ScheduleGrid(
                  schedule: schedule,
                  selectedId: state.selectedId,
                  onSelect: onSelect,
                  onContextMenu: onContextMenu,
                ),
              ),
              if (selected != null) ...[
                const VerticalDivider(width: 1),
                SizedBox(
                  width: 340,
                  child: ReservationDetailPanel(
                    reservation: selected,
                    guest: schedule.guestOf(selected),
                    table: schedule.tables.where((t) => t.id == selected.tableId).firstOrNull,
                    busy: state.isBusy,
                    onConfirm: () => onConfirm(selected),
                    onArrival: () => onArrival(selected),
                    onCancel: () => onCancel(selected),
                    onClose: () => onSelect(null),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CancellationDialog extends StatefulWidget {
  const _CancellationDialog({required this.reservation});

  final Reservation reservation;

  @override
  State<_CancellationDialog> createState() => _CancellationDialogState();
}

class _CancellationDialogState extends State<_CancellationDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reservation = widget.reservation;
    return AlertDialog(
      title: const Text('Otkazati rezervaciju?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${capitalize(formatDateAndTime(reservation.slot.start))}, ${peopleLabel(reservation.partySize.value)}.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Razlog'),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Odustani')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Otkaži rezervaciju'),
        ),
      ],
    );
  }
}
