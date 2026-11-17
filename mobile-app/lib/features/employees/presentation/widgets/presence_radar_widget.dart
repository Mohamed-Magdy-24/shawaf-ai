import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../models/models.dart';

class PresenceRadarWidget extends StatelessWidget {
  final List<EmployeePresence> presenceList;

  const PresenceRadarWidget({
    super.key,
    required this.presenceList,
  });

  @override
  Widget build(BuildContext context) {
    if (presenceList.isEmpty) {
      return const Center(
        child: Padding(
          padding: AppSpacing.p24,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.radar_outlined, size: 48, color: AppColors.textMuted),
              AppSpacing.vGap16,
              Text('No Real-Time Presence Detected',
                  style: AppTypography.titleMedium),
              AppSpacing.vGap8,
              Text(
                'AI worker has not matched facial embeddings in plant zones recently.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.p16,
      itemCount: presenceList.length,
      itemBuilder: (context, index) {
        final item = presenceList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: AppCard(
            padding: AppSpacing.p12,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: const Center(
                    child:
                        Icon(Icons.person, color: AppColors.primary, size: 22),
                  ),
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.fullName,
                        style: AppTypography.titleSmall
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      AppSpacing.vGap4,
                      Text(
                        'Zone: ${item.zoneName ?? item.zoneId} • Camera: ${item.cameraId}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: AppSpacing.badgePadding,
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withValues(alpha: 0.15),
                        borderRadius: AppSpacing.roundedXs,
                      ),
                      child: Text(
                        'ACTIVE',
                        style: AppTypography.labelSmall
                            .copyWith(color: AppColors.successGreen),
                      ),
                    ),
                    AppSpacing.vGap4,
                    Text(
                      'Conf: ${(item.confidence * 100).toStringAsFixed(0)}%',
                      style: AppTypography.monospace.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
