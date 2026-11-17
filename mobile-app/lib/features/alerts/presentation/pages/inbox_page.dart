import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/degraded_banner.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../models/models.dart';
import '../../../sites/presentation/cubit/site_cubit.dart';
import '../cubit/alert_inbox_cubit.dart';
import '../widgets/alert_card_widget.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SiteCubit, SiteState>(
      builder: (context, siteState) {
        if (siteState is SiteInitial) {
          context.read<SiteCubit>().loadSites();
          return const Center(child: CircularProgressIndicator(color: AppColors.cobalt));
        }

        if (siteState is SiteError) {
          final isAuthError = siteState.message.toLowerCase().contains('unauthorized') ||
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
          return const Center(child: CircularProgressIndicator(color: AppColors.cobalt));
        }

        final currentSite = siteState.selectedSite;

        return Scaffold(
          backgroundColor: AppColors.canvas,
          body: BlocBuilder<AlertInboxCubit, AlertInboxState>(
            builder: (context, alertState) {
              if (alertState is AlertInboxInitial) {
                context.read<AlertInboxCubit>().loadAlerts(currentSite.id);
                return ListView.builder(
                  padding: AppSpacing.p16,
                  itemCount: 4,
                  itemBuilder: (_, __) => const ShimmerSkeletonCard(),
                );
              }

              if (alertState is AlertInboxLoading) {
                return ListView.builder(
                  padding: AppSpacing.p16,
                  itemCount: 4,
                  itemBuilder: (_, __) => const ShimmerSkeletonCard(),
                );
              }

              if (alertState is AlertInboxError) {
                return ErrorStateView(
                  errorMessage: alertState.message,
                  onRetry: () => context.read<AlertInboxCubit>().loadAlerts(currentSite.id),
                );
              }

              if (alertState is AlertInboxEmpty) {
                return EmptyStateView(
                  icon: Icons.verified_user_outlined,
                  title: 'No Active Safety Alerts',
                  description: 'All zones in ${currentSite.code} are operating within normal parameters.',
                  actionLabel: 'REFRESH',
                  onAction: () => context.read<AlertInboxCubit>().loadAlerts(currentSite.id),
                );
              }

              List<SurveillanceEvent> alerts = [];
              String? degradedError;

              if (alertState is AlertInboxLoaded) {
                alerts = alertState.alerts;
              } else if (alertState is AlertInboxDegradedOffline) {
                alerts = alertState.cachedAlerts;
                degradedError = alertState.error;
              }

              return Column(
                children: [
                  if (degradedError != null)
                    DegradedBanner(
                      message: degradedError,
                      onRetry: () => context.read<AlertInboxCubit>().loadAlerts(currentSite.id),
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      onRefresh: () => context.read<AlertInboxCubit>().loadAlerts(currentSite.id),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        itemCount: alerts.length,
                        itemBuilder: (context, index) {
                          final alert = alerts[index];
                          return AlertCardWidget(
                            alert: alert,
                            onTap: () {
                              context.push('/alerts/${alert.id}', extra: alert);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
