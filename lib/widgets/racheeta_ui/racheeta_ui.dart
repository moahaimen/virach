import 'package:flutter/material.dart';
import 'package:racheeta/theme/app_theme.dart';

class RacheetaSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;
  final String seeAllText;

  const RacheetaSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
    this.seeAllText = 'عرض الكل',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: RacheetaColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: RacheetaColors.textPrimary,
                          ),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: RacheetaColors.textSecondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (onSeeAll != null)
            InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  seeAllText,
                  style: const TextStyle(
                    color: RacheetaColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RacheetaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final double radius;

  const RacheetaCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? EdgeInsets.zero,
      elevation: 0,
      color: RacheetaColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: const BorderSide(color: RacheetaColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class RacheetaStatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const RacheetaStatusChip({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class RacheetaEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const RacheetaEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: RacheetaColors.mintLight.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64, color: RacheetaColors.primary.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: RacheetaColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: RacheetaColors.textSecondary,
                ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
