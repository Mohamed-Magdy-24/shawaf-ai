import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class SiteSwitcherBanner extends StatelessWidget {
  final Site currentSite;
  final List<Site> availableSites;
  final ValueChanged<Site> onSiteSelected;

  const SiteSwitcherBanner({
    super.key,
    required this.currentSite,
    required this.availableSites,
    required this.onSiteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.15),
              border: Border.all(color: AppTheme.primaryTeal, width: 1.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Text(
                currentSite.code,
                key: ValueKey<String>(currentSite.code),
                style: const TextStyle(
                  color: AppTheme.primaryTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ACTIVE SITE',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    currentSite.name,
                    key: ValueKey<String>(currentSite.id),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // 2-Tap Switcher: directly toggles between BNF and RNF or shows bottom sheet if more
          Wrap(
            spacing: 6,
            children: availableSites.map((site) {
              final isSelected = site.id == currentSite.id;
              return ChoiceChip(
                label: Text(
                  site.code,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF042F2E) : AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppTheme.primaryTeal,
                backgroundColor: AppTheme.surfaceLight,
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryTeal : AppTheme.border,
                ),
                onSelected: (selected) {
                  if (selected && !isSelected) {
                    onSiteSelected(site);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
