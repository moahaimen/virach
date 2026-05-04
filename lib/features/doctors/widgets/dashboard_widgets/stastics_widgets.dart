import 'package:flutter/material.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';

class Stastics extends StatelessWidget {
  const Stastics({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Expanded(
            child: StatCard(
              title: 'إجمالي الحجوزات',
              value: '42',
              color: RacheetaColors.primary,
              icon: Icons.calendar_today_rounded,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: StatCard(
              title: 'حجوزات اليوم',
              value: '8',
              color: RacheetaColors.warning,
              icon: Icons.today_rounded,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: StatCard(
              title: 'المشاهدات',
              value: '1.2k',
              color: Color(0xFF6C5DD3),
              icon: Icons.visibility_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return RacheetaCard(
      padding: const EdgeInsets.all(16),
      radius: 20,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: RacheetaColors.textPrimary,
                  fontSize: 18,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: RacheetaColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
