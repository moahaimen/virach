import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';

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
    _loadInitialReservations();
    _startAutoRefresh();
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

  void _loadInitialReservations() {
    context.read<ReservationRetroDisplayGetProvider>().fetchMyFullReservations(context);
  }

  void _startAutoRefresh() {
    _autoTimer = Timer.periodic(const Duration(minutes: 3), (_) {
      context.read<ReservationRetroDisplayGetProvider>().fetchMyFullReservations(context);
    });
  }

  void _sortAppointments(String column) {
    setState(() {
      if (_sortedBy == column) {
        _ascending = !_ascending;
      } else {
        _sortedBy = column;
        _ascending = true;
      }
      context.read<ReservationRetroDisplayGetProvider>().sortReservations(_sortedBy, _ascending);
    });
  }

  List<ReservationModel> _filter(List<ReservationModel> list) {
    return list.where((a) {
      final notCancelled = (a.status ?? '').toUpperCase() != 'CANCELLED';
      final statusOk = _selectedFilter == 'All' || a.status == _selectedFilter;
      final email = a.patient?.email ?? '';
      final searchOk = email.toLowerCase().contains(_searchQuery.toLowerCase());
      return notCancelled && statusOk && searchOk;
    }).toList();
  }

  List<ReservationModel> _page(List<ReservationModel> list) {
    final totalPages = (list.length / _itemsPerPage).ceil().clamp(1, 9999);
    if (_currentPage > totalPages) _currentPage = 1;
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, list.length);
    return list.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReservationRetroDisplayGetProvider>(
      builder: (_, provider, __) {
        final filteredList = _filter(provider.fullReservations);
        final visible = _page(filteredList);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RacheetaSectionHeader(
                title: 'حجوزات اليوم',
                subtitle: 'إدارة المواعيد المجدولة لهذا اليوم',
              ),
              RacheetaCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    HspTodayAppointmentSearchBar(
                      onSearchChanged: (v) => setState(() => _searchQuery = v),
                    ),
                    const SizedBox(height: 12),
                    HspTodayAppointmentFilterRow(
                      selectedFilter: _selectedFilter,
                      onFilterChanged: (v) => setState(() => _selectedFilter = v),
                    ),
                    const Divider(height: 32, color: RacheetaColors.border),
                    HspTodayAppointmentHeaderRow(
                      sortedBy: _sortedBy,
                      ascending: _ascending,
                      onSortColumn: _sortAppointments,
                    ),
                    const SizedBox(height: 8),
                    if (visible.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text('لا توجد حجوزات تطابق البحث', style: TextStyle(color: RacheetaColors.textSecondary)),
                        ),
                      )
                    else
                      ...visible.map(
                        (a) => HSPAppointmentRow(
                          appointment: a,
                          onStatusChange: (_) {},
                          confirmStatusChange: (_) {},
                        ),
                      ),
                    if (filteredList.length > _itemsPerPage)
                      HspToadyAppointmentPaginationControls(
                        currentPage: _currentPage,
                        totalItems: filteredList.length,
                        itemsPerPage: _itemsPerPage,
                        onNextPage: () => setState(() => _currentPage++),
                        onPreviousPage: () => setState(() => _currentPage--),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
