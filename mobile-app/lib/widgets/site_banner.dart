import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class SiteBanner extends StatelessWidget {
  final Site currentSite;
  final List<Site> availableSites;
  final Function(Site) onSiteSelected;

  const SiteBanner({
    Key? key,
    required this.currentSite,
    required this.availableSites,
    required this.onSiteSelected,
  }) : super(key: key);

  void _showSitePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SWITCH ACTIVE INDUSTRIAL SITE',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...availableSites.map((site) {
                  final isSelected = site.id == currentSite.id;
                  return InkWell(
                    onTap: () {
                      onSiteSelected(site);
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.surfaceLight : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryTeal : AppTheme.border,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryTeal : AppTheme.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              site.code,
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF042F2E) : AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  site.name,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Timezone: ${site.timezone}',
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: AppTheme.primaryTeal, size: 20),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.15),
              border: Border.all(color: AppTheme.primaryTeal),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              currentSite.code,
              style: const TextStyle(
                color: AppTheme.primaryTeal,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'CURRENT INDUSTRIAL SITE',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  currentSite.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _showSitePicker(context),
            icon: const Icon(Icons.swap_horiz, size: 16, color: AppTheme.primaryTeal),
            label: const Text('SWITCH', style: TextStyle(color: AppTheme.primaryTeal, fontSize: 12)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primaryTeal),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
            ),
          ),
        ],
      ),
    );
  }
}
