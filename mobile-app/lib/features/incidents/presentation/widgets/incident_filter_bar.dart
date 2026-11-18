import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/incident.dart';

class IncidentFilterBar extends StatelessWidget {
  final IncidentSeverity? selectedSeverity;
  final IncidentStatus? selectedStatus;
  final ValueChanged<IncidentSeverity?> onSeverityChanged;
  final ValueChanged<IncidentStatus?> onStatusChanged;

  const IncidentFilterBar({
    super.key,
    required this.selectedSeverity,
    required this.selectedStatus,
    required this.onSeverityChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing8,
      ),
      color: AppColors.surfacePanel,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text('STATUS:', style: AppTypography.badge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(width: AppDimensions.spacing8),
            _buildFilterChip<IncidentStatus>(
              label: 'ALL',
              isSelected: selectedStatus == null,
              onSelected: () => onStatusChanged(null),
            ),
            const SizedBox(width: AppDimensions.spacing4),
            ...IncidentStatus.values.map(
              (status) => Padding(
                padding: const EdgeInsets.only(right: AppDimensions.spacing4),
                child: _buildFilterChip<IncidentStatus>(
                  label: status.value,
                  isSelected: selectedStatus == status,
                  selectedColor: status.color,
                  onSelected: () => onStatusChanged(status),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacing16),
            const SizedBox(
              height: 20.0,
              child: VerticalDivider(color: AppColors.borderStrong),
            ),
            const SizedBox(width: AppDimensions.spacing16),
            Text('SEVERITY:', style: AppTypography.badge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(width: AppDimensions.spacing8),
            _buildFilterChip<IncidentSeverity>(
              label: 'ALL',
              isSelected: selectedSeverity == null,
              onSelected: () => onSeverityChanged(null),
            ),
            const SizedBox(width: AppDimensions.spacing4),
            ...IncidentSeverity.values.map(
              (sev) => Padding(
                padding: const EdgeInsets.only(right: AppDimensions.spacing4),
                child: _buildFilterChip<IncidentSeverity>(
                  label: sev.value,
                  isSelected: selectedSeverity == sev,
                  selectedColor: sev.color,
                  onSelected: () => onSeverityChanged(sev),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip<T>({
    required String label,
    required bool isSelected,
    Color? selectedColor,
    required VoidCallback onSelected,
  }) {
    final activeColor = selectedColor ?? AppColors.statusInfo;
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing8,
          vertical: AppDimensions.spacing4,
        ),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.2) : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.borderSubtle,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? activeColor : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
