import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../../models/models.dart';

/// Reusable banner for switching between plant sites BNF and RNF.
/// 100% StatelessWidget, animated transition (250ms), zero business logic.
class SiteSwitcherBanner extends StatelessWidget {
  final String? activeSiteCode;
  final Site? currentSite;
  final List<Site>? availableSites;
  final Function(dynamic) onSiteSelected;

  const SiteSwitcherBanner({
    super.key,
    this.activeSiteCode,
    this.currentSite,
    this.availableSites,
    required this.onSiteSelected,
  });

  String get _code => currentSite?.code ?? activeSiteCode ?? 'BNF';

  void _handleTap(String targetCode) {
    if (availableSites != null && availableSites!.isNotEmpty) {
      final matched = availableSites!.firstWhere(
        (s) => s.code.toUpperCase() == targetCode.toUpperCase(),
        orElse: () => availableSites!.first,
      );
      onSiteSelected(matched);
    } else {
      onSiteSelected(targetCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = _code;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.factory_outlined, color: AppColors.primary, size: 20),
              AppSpacing.hGap8,
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  'SITE: $code',
                  key: ValueKey<String>(code),
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _SiteChip(
                code: 'BNF',
                isActive: code == 'BNF',
                onTap: () => _handleTap('BNF'),
              ),
              AppSpacing.hGap8,
              _SiteChip(
                code: 'RNF',
                isActive: code == 'RNF',
                onTap: () => _handleTap('RNF'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SiteChip extends StatelessWidget {
  final String code;
  final bool isActive;
  final VoidCallback onTap;

  const _SiteChip({
    required this.code,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isActive ? AppColors.primary : AppColors.surfaceLight;
    final fg = isActive ? AppColors.primaryTextOn : AppColors.textSecondary;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: AppSpacing.roundedSm,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppSpacing.roundedSm,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border,
              width: 1.0,
            ),
          ),
          child: Text(
            code,
            style: AppTypography.labelSmall.copyWith(
              color: fg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
