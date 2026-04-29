import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';

import '../../../../constansts/constants.dart';
import '../../../reservations/providers/reservations_provider.dart';
import '../../../reservations/models/reservation_model.dart';
import '../../../widgets/hsp_today_appointment_filter_row.dart';
import '../../../widgets/hsp_today_appointment_search_bar.dart';
import '../../../widgets/hsp_today_apponitment_header_row.dart';
import '../../../widgets/hsp_today_apponitment_pagination_controls.dart';
import '../../../widgets/hsp_today_apponitment_row.dart';

class TodayAppointments extends StatefulWidget {
  final String userType, userId, doctorId, userName;
  const TodayAppointments({
    super.key,
    required this.userType,
    required this.userId,
    required this.doctorId,
    required this.userName,
  });

  @override
  State<TodayAppointments> createState() => _TodayAppointmentsState();
}

class _TodayAppointmentsState extends State<TodayAppointments> {
  String _sortedBy = 'الوقت';
  bool _ascending = true;
  String _selectedFilter = 'All';
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _loadInitialReservations(); // will run if doctorId ready
    _startAutoRefresh(); // 3‑minute polling
  }

  @override
  void didUpdateWidget(covariant TodayAppointments oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.doctorId != widget.doctorId && widget.doctorId.isNotEmpty) {
      _loadInitialReservations();
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  // ------------------------------------------------------------
  // INITIAL & PERIODIC LOAD
  // ------------------------------------------------------------
// ------------------- DATA LOADERS ----------------------------
// ------------------------------------------------------------
// INITIAL & PERIODIC LOAD
// ------------------------------------------------------------
  void _loadInitialReservations() {
    context
        .read<ReservationRetroDisplayGetProvider>()
        .fetchMyFullReservations(context); // 👈  changed
  }

  void _startAutoRefresh() {
    _autoTimer = Timer.periodic(const Duration(minutes: 3), (_) {
      context
          .read<ReservationRetroDisplayGetProvider>()
          .fetchMyFullReservations(context); // 👈  changed
      debugPrint('✅ Auto‑refreshed reservations at ${DateTime.now()}');
    });
  }

  // ------------------------------------------------------------
  // SORT / FILTER / PAGINATION HELPERS
  // ------------------------------------------------------------
  void _sortAppointments(String column) {
    setState(() {
      if (_sortedBy == column) {
        _ascending = !_ascending;
      } else {
        _sortedBy = column;
        _ascending = true;
      }
      context
          .read<ReservationRetroDisplayGetProvider>()
          .sortReservations(_sortedBy, _ascending);
    });
  }

  /// 1️⃣  NEW: filter **out** cancelled rows here, *before* pagination.
  List<ReservationModel> _filter(List<ReservationModel> list) {
    return list.where((a) {
      // Skip cancelled rows completely
      final notCancelled = (a.status ?? '').toUpperCase() != 'CANCELLED';

      final statusOk = _selectedFilter == 'All' || a.status == _selectedFilter;

      final email = a.patient?.email ?? '';
      final searchOk = email.toLowerCase().contains(_searchQuery.toLowerCase());

      return notCancelled && statusOk && searchOk;
    }).toList();
  }

  List<ReservationModel> _page(List<ReservationModel> list) {
    // If the current page no longer exists (e.g., after filtering), reset to 1
    final totalPages = (list.length / _itemsPerPage).ceil().clamp(1, 9999);
    if (_currentPage > totalPages) _currentPage = 1;

    final start = (_currentPage - 1) * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, list.length);
    return list.sublist(start, end);
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Consumer<ReservationRetroDisplayGetProvider>(
      builder: (_, provider, __) {
        final visible = _page(_filter(provider.fullReservations));

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text('حجوزات اليوم',
                    style: kAppointmentsHeaderStyleTextStyle),
                const Divider(),
                HspTodayAppointmentSearchBar(
                  onSearchChanged: (v) => setState(() => _searchQuery = v),
                ),
                const Divider(),
                HspTodayAppointmentFilterRow(
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (v) => setState(() => _selectedFilter = v),
                ),
                const SizedBox(height: 20),
                HspTodayAppointmentHeaderRow(
                  sortedBy: _sortedBy,
                  ascending: _ascending,
                  onSortColumn: _sortAppointments,
                ),
                const Divider(),
                ...visible.map(
                      (a) => HSPAppointmentRow(
                    appointment: a,
                    onStatusChange: (_) {},
                    confirmStatusChange: (_) {},
                  ),
                ),
                HspToadyAppointmentPaginationControls(
                  currentPage: _currentPage,
                  totalItems: _filter(provider.fullReservations).length,
                  itemsPerPage: _itemsPerPage,
                  onNextPage: () => setState(() => _currentPage++),
                  onPreviousPage: () => setState(() => _currentPage--),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
