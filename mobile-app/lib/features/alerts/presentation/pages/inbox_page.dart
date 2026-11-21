import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/degraded_banner.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/severity_badge.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../models/models.dart';
import '../../../sites/presentation/cubit/site_cubit.dart';
import '../cubit/alert_inbox_cubit.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  String _selectedSeverity = 'ALL';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SiteCubit, SiteState>(
      builder: (context, siteState) {
        if (siteState is SiteInitial) {
          context.read<SiteCubit>().loadSites();
          return const Center(
              child: CircularProgressIndicator(color: AppColors.cobalt));
        }

        if (siteState is SiteError) {
          final isAuthError =
              siteState.message.toLowerCase().contains('unauthorized') ||
                  siteState.message.toLowerCase().contains('401') ||
                  siteState.message.toLowerCase().contains('session expired');
          return ErrorStateView(
            errorMessage: siteState.message,
            actionLabel: isAuthError ? 'SIGN IN' : 'RETRY',
            onRetry: () {
              if (isAuthError) {
                context.go('/login');
              } else {
                context.read<SiteCubit>().loadSites();
              }
            },
          );
        }

        if (siteState is! SiteLoaded) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.cobalt));
        }

        final currentSite = siteState.selectedSite;

        return Scaffold(
          backgroundColor: AppColors.canvas,
          body: BlocBuilder<AlertInboxCubit, AlertInboxState>(
            builder: (context, alertState) {
              if (alertState is AlertInboxInitial) {
                context.read<AlertInboxCubit>().loadAlerts(currentSite.id);
                return ListView.builder(
                  padding: AppSpacing.p20,
                  itemCount: 4,
                  itemBuilder: (_, __) => const ShimmerSkeletonCard(),
                );
              }

              if (alertState is AlertInboxLoading) {
                return ListView.builder(
                  padding: AppSpacing.p20,
                  itemCount: 4,
                  itemBuilder: (_, __) => const ShimmerSkeletonCard(),
                );
              }

              if (alertState is AlertInboxError) {
                return ErrorStateView(
                  errorMessage: alertState.message,
                  onRetry: () => context
                      .read<AlertInboxCubit>()
                      .loadAlerts(currentSite.id),
                );
              }

              List<SurveillanceEvent> allAlerts = [];
              String? degradedError;

              if (alertState is AlertInboxLoaded) {
                allAlerts = alertState.alerts;
              } else if (alertState is AlertInboxDegradedOffline) {
                allAlerts = alertState.cachedAlerts;
                degradedError = alertState.error;
              }

              final filteredAlerts = _selectedSeverity == 'ALL'
                  ? allAlerts
                  : allAlerts
                      .where(
                          (a) => a.severity.toUpperCase() == _selectedSeverity)
                      .toList();

              return SingleChildScrollView(
                padding: AppSpacing.p20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (degradedError != null) ...[
                      DegradedBanner(
                        message: degradedError,
                        onRetry: () => context
                            .read<AlertInboxCubit>()
                            .loadAlerts(currentSite.id),
                      ),
                      AppSpacing.vGap16,
                    ],
                    _buildHeader(context, currentSite),
                    AppSpacing.vGap16,
                    _buildFilterBar(),
                    AppSpacing.vGap16,
                    filteredAlerts.isEmpty
                        ? EmptyStateView(
                            icon: Icons.verified_user_outlined,
                            title: 'No Active Safety Alerts',
                            description:
                                'All zones in ${currentSite.code} are operating within normal parameters.',
                            actionLabel: 'REFRESH',
                            onAction: () => context
                                .read<AlertInboxCubit>()
                                .loadAlerts(currentSite.id),
                          )
                        : _buildTable(context, filteredAlerts),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Site site) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Alert Inbox', style: AppTypography.titleLarge),
                AppSpacing.hGap8,
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: AppSpacing.roundedXs,
                    border: Border.all(color: AppColors.borderline),
                  ),
                  child: Text(
                    site.code,
                    style: AppTypography.tabularMonoSmall.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.vGap4,
            const Text(
              'Transactional outbox events with mandatory FR-ALT-008 audit transitions.',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.refresh, size: 20, color: AppColors.muted),
          tooltip: 'Refresh Alerts',
          onPressed: () => context.read<AlertInboxCubit>().loadAlerts(site.id),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    const severities = ['ALL', 'SEV1', 'SEV2', 'SEV3'];
    return Row(
      children: severities.map((sev) {
        final isSelected = _selectedSeverity == sev;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Material(
            color: isSelected ? AppColors.elevated : AppColors.canvas,
            borderRadius: AppSpacing.roundedSm,
            child: InkWell(
              onTap: () => setState(() => _selectedSeverity = sev),
              borderRadius: AppSpacing.roundedSm,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: AppSpacing.roundedSm,
                  border: Border.all(
                      color: isSelected
                          ? AppColors.borderline
                          : AppColors.borderline.withValues(alpha: 0.5)),
                ),
                child: Text(
                  sev,
                  style: AppTypography.tabularMonoSmall.copyWith(
                    color: isSelected ? AppColors.ink : AppColors.muted,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTable(BuildContext context, List<SurveillanceEvent> alerts) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(bottom: BorderSide(color: AppColors.borderline)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('SEVERITY', style: _headerStyle)),
                Expanded(
                    flex: 3, child: Text('EVENT / ZONE', style: _headerStyle)),
                Expanded(flex: 2, child: Text('CAMERA', style: _headerStyle)),
                Expanded(flex: 2, child: Text('STATE', style: _headerStyle)),
                Expanded(flex: 2, child: Text('TIME', style: _headerStyle)),
                SizedBox(
                    width: 80,
                    child: Text('ACTION',
                        style: _headerStyle, textAlign: TextAlign.right)),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alerts.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.borderline),
            itemBuilder: (context, index) {
              final a = alerts[index];
              final timeStr =
                  '${a.occurredAt.hour.toString().padLeft(2, '0')}:${a.occurredAt.minute.toString().padLeft(2, '0')}:${a.occurredAt.second.toString().padLeft(2, '0')}';

              return InkWell(
                onTap: () => context.push('/alerts/${a.id}', extra: a),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SeverityBadge(severity: a.severity),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          a.eventType,
                          style:
                              AppTypography.titleSmall.copyWith(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          a.cameraId,
                          style: AppTypography.tabularMonoSmall
                              .copyWith(color: AppColors.muted),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.elevated,
                            borderRadius: AppSpacing.roundedXs,
                            border: Border.all(color: AppColors.borderline),
                          ),
                          child: Text(
                            a.state.toUpperCase(),
                            style: AppTypography.tabularMonoSmall.copyWith(
                              fontSize: 10,
                              color: a.state.toUpperCase() == 'NEW'
                                  ? AppColors.crimson
                                  : AppColors.ink,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(timeStr,
                            style: AppTypography.tabularMonoSmall
                                .copyWith(color: AppColors.dim)),
                      ),
                      SizedBox(
                        width: 80,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'AUDIT >',
                            style: AppTypography.tabularMonoSmall.copyWith(
                              color: AppColors.cobalt,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    color: AppColors.muted,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    fontFamily: 'JetBrains Mono',
    letterSpacing: 0.8,
  );
}
