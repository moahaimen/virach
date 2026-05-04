import 'package:flutter/material.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';
import '../../features/reservations/models/reservation_model.dart';

class ReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;

  const ReservationCard({
    super.key,
    required this.reservation,
    this.onCancel,
    this.onTap,
  });

  String _translateStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return 'قيد الانتظار';
      case 'CONFIRMED':
        return 'مؤكدة';
      case 'CANCELLED':
        return 'ملغاة';
      default:
        return 'غير معروف';
    }
  }

  Color _statusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return RacheetaColors.warning;
      case 'CONFIRMED':
        return RacheetaColors.success;
      case 'CANCELLED':
        return RacheetaColors.danger;
      default:
        return RacheetaColors.textSecondary;
    }
  }

  String _deriveProviderName(Map<String, dynamic>? hspUser) {
    if (hspUser == null) return "مزود خدمة غير معروف";
    return hspUser["full_name"] ?? 
           hspUser["hospital_name"] ?? 
           hspUser["center_name"] ?? 
           hspUser["name"] ?? 
           "مزود خدمة";
  }

  @override
  Widget build(BuildContext context) {
    final hspUser = reservation.hspUser;
    final providerImage = hspUser?["profile_image"] ?? "";
    final providerName = _deriveProviderName(hspUser);
    final spType = reservation.serviceProviderType ?? '';

    return RacheetaCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: RacheetaColors.mintLight,
                  image: providerImage.isNotEmpty
                      ? DecorationImage(image: NetworkImage(providerImage), fit: BoxFit.cover)
                      : null,
                ),
                child: providerImage.isEmpty
                    ? const Icon(Icons.person_outline, color: RacheetaColors.primary)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      providerName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: RacheetaColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      spType,
                      style: const TextStyle(fontSize: 12, color: RacheetaColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              RacheetaStatusChip(
                label: _translateStatus(reservation.status),
                color: _statusColor(reservation.status),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: RacheetaColors.border),
          ),
          Row(
            children: [
              _infoTile(Icons.calendar_today_outlined, reservation.appointmentDate ?? '—'),
              const SizedBox(width: 24),
              _infoTile(Icons.access_time_outlined, reservation.appointmentTime ?? '—'),
              const Spacer(),
              if (onCancel != null && reservation.status?.toUpperCase() == 'PENDING')
                IconButton(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined, color: RacheetaColors.danger, size: 22),
                  tooltip: 'إلغاء الحجز',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: RacheetaColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: RacheetaColors.textPrimary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
