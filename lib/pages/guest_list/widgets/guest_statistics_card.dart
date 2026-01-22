import 'package:flutter/material.dart';

class GuestStatisticsCard extends StatelessWidget {
  const GuestStatisticsCard({
    required this.title,
    required this.value,
    this.icon,
    this.color,
    this.subtitle,
    this.onTap,
    super.key,
  });

  final String title;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final effectiveColor = color ?? colorScheme.primary;

    return Semantics(
      label: '$title: $value${subtitle != null ? ', $subtitle' : ''}',
      button: onTap != null,
      child: Card(
        elevation: 2,
        color: colorScheme.surfaceContainer,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: effectiveColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: effectiveColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        value,
                        style: textTheme.displaySmall?.copyWith(
                          color: effectiveColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
