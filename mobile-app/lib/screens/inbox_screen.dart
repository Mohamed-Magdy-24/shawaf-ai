import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/alert_inbox_cubit.dart';
import '../cubits/site_cubit.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/alert_card.dart';
import '../widgets/degraded_connection_banner.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/shimmer_skeleton_card.dart';
import 'alert_detail_screen.dart';

class InboxScreen extends StatelessWidget {
  final ValueNotifier<String> _severityFilter = ValueNotifier<String>('ALL');

  InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SiteCubit, SiteState>(
      builder: (context, siteState) {
        final currentSiteId = siteState is SiteLoaded ? siteState.selectedSite.id : '';
        final currentSiteCode = siteState is SiteLoaded ? siteState.selectedSite.code : '';

        return Column(
          children: [
            // Filter Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.surface,
              child: Row(
                children: [
                  const Text(
                    'SEVERITY: ',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<String>(
                    valueListenable: _severityFilter,
                    builder: (context, activeFilter, _) {
                      return Row(
                        children: ['ALL', 'SEV1', 'SEV2', 'SEV3'].map((sev) {
                          final isSelected = activeFilter == sev;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(
                                sev,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected ? const Color(0xFF042F2E) : AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppTheme.primaryTeal,
                              backgroundColor: AppTheme.surfaceLight,
                              side: BorderSide(
                                color: isSelected ? AppTheme.primaryTeal : AppTheme.border,
                              ),
                              onSelected: (val) {
                                if (val) _severityFilter.value = sev;
                              },
                              visualDensity: VisualDensity.compact,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppTheme.primaryTeal, size: 20),
                    onPressed: () {
                      if (currentSiteId.isNotEmpty) {
                        context.read<AlertInboxCubit>().loadAlerts(currentSiteId);
                      }
                    },
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: BlocBuilder<AlertInboxCubit, AlertInboxState>(
                builder: (context, state) {
                  if (state is AlertInboxLoading) {
                    return ListView.builder(
                      itemCount: 4,
                      itemBuilder: (_, __) => const ShimmerSkeletonCard(height: 110),
                    );
                  }

                  if (state is AlertInboxError) {
                    return EmptyStateView(
                      icon: Icons.error_outline,
                      title: 'INBOX OFFLINE / UNREACHABLE',
                      message: state.message,
                      actionLabel: 'RETRY',
                      onAction: () {
                        if (currentSiteId.isNotEmpty) {
                          context.read<AlertInboxCubit>().loadAlerts(currentSiteId);
                        }
                      },
                    );
                  }

                  if (state is AlertInboxEmpty) {
                    return EmptyStateView(
                      icon: Icons.shield_outlined,
                      title: 'ALL SAFETY ZONES SECURE',
                      message: 'Zero pending surveillance alerts recorded for $currentSiteCode.',
                      actionLabel: 'REFRESH',
                      onAction: () {
                        if (currentSiteId.isNotEmpty) {
                          context.read<AlertInboxCubit>().loadAlerts(currentSiteId);
                        }
                      },
                    );
                  }

                  List<SurveillanceEvent> alerts = [];
                  String? degradedError;

                  if (state is AlertInboxLoaded) {
                    alerts = state.alerts;
                  } else if (state is AlertInboxDegradedOffline) {
                    alerts = state.cachedAlerts;
                    degradedError = state.error;
                  }

                  return ValueListenableBuilder<String>(
                    valueListenable: _severityFilter,
                    builder: (context, activeFilter, _) {
                      final filtered = alerts.where((a) {
                        if (activeFilter == 'ALL') return true;
                        return a.severity.toUpperCase() == activeFilter;
                      }).toList();

                      return Column(
                        children: [
                          if (degradedError != null)
                            DegradedConnectionBanner(
                              message: degradedError,
                              isOffline: true,
                              onRetry: () {
                                if (currentSiteId.isNotEmpty) {
                                  context.read<AlertInboxCubit>().loadAlerts(currentSiteId);
                                }
                              },
                            ),
                          Expanded(
                            child: filtered.isEmpty
                                ? EmptyStateView(
                                    icon: Icons.filter_alt_off,
                                    title: 'NO MATCHING ALERTS',
                                    message: 'No alerts match severity filter "$activeFilter".',
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) {
                                      final alert = filtered[index];
                                      return AlertCard(
                                        alert: alert,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AlertDetailScreen(
                                                event: alert,
                                                onAction: (action, note) async {
                                                  await context.read<AlertInboxCubit>().executeAction(
                                                        alert.siteId,
                                                        alert.id,
                                                        action,
                                                        note,
                                                      );
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
