import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class SiteBanner extends StatelessWidget {
  final Site currentSite;
  final List<Site> availableSites;
  final Function(Site) onSiteSelected;

  const SiteBanner({
    super.key,
    required this.currentSite,
    required this.availableSites,
    required this.onSiteSelected,
  });

  void _showSitePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 8),
              ...availableSites.map((site) {
                final isSelected = site.id == currentSite.id;
                return ListTile(
                  title: Text(site.name, style: const TextStyle(color: AppTheme.textPrimary)),
                  subtitle: Text(site.code, style: const TextStyle(color: AppTheme.primaryTeal)),
                  trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryTeal) : null,
                  onTap: () {
                    onSiteSelected(site);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
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
              color: AppTheme.primaryTeal.withValues(alpha: 0.15),
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
            child: Text(
              currentSite.name,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
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
