import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/degraded_banner.dart';
import '../../cubits/connectivity_cubit.dart';
import '../../features/alerts/presentation/cubit/alert_inbox_cubit.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/cameras/presentation/cubit/camera_stream_cubit.dart';
import '../../features/employees/presentation/cubit/employee_cubit.dart';
import '../../features/sites/presentation/cubit/site_cubit.dart';

class NavigationShell extends StatelessWidget {
  final Widget child;

  const NavigationShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location == '/overview') return 0;
    if (location.startsWith('/live-control')) return 1;
    if (location.startsWith('/camera-wall')) return 2;
    if (location.startsWith('/inbox')) return 3;
    if (location == '/employees') return 4;
    if (location.startsWith('/employees/presence')) return 5;
    if (location.startsWith('/cameras')) return 6;
    if (location.startsWith('/nvrs')) return 7;
    if (location.startsWith('/sites')) return 8;
    if (location.startsWith('/zones')) return 9;
    if (location.startsWith('/analytics')) return 10;
    if (location.startsWith('/diagnostics')) return 11;
    if (location.startsWith('/audit')) return 12;
    if (location.startsWith('/settings')) return 13;
    if (location.startsWith('/security')) return 14;
    return 0;
  }

  void _onNavigate(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/overview');
        break;
      case 1:
        context.go('/live-control');
        break;
      case 2:
        context.go('/camera-wall');
        break;
      case 3:
        context.go('/inbox');
        break;
      case 4:
        context.go('/employees');
        break;
      case 5:
        context.go('/employees/presence');
        break;
      case 6:
        context.go('/cameras');
        break;
      case 7:
        context.go('/nvrs');
        break;
      case 8:
        context.go('/sites');
        break;
      case 9:
        context.go('/zones');
        break;
      case 10:
        context.go('/analytics');
        break;
      case 11:
        context.go('/diagnostics');
        break;
      case 12:
        context.go('/audit');
        break;
      case 13:
        context.go('/settings');
        break;
      case 14:
        context.go('/security');
        break;
    }
  }

  void _switchSite(BuildContext context, String code, SiteState siteState) {
    context.read<SiteCubit>().selectSite(code);
    if (siteState is SiteLoaded) {
      final site = siteState.sites.firstWhere(
        (s) => s.code.toUpperCase() == code.toUpperCase(),
        orElse: () => siteState.selectedSite,
      );
      context.read<AlertInboxCubit>().loadAlerts(site.id);
      context.read<CameraStreamCubit>().loadCameras(site.id);
      context.read<EmployeeCubit>().load(site.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return BlocBuilder<SiteCubit, SiteState>(
      builder: (context, siteState) {
        final activeSiteCode = siteState is SiteLoaded ? siteState.selectedSite.code : 'BNF';

        return BlocBuilder<ConnectivityCubit, ConnectivityState>(
          builder: (context, connState) {
            final isOffline = connState is ConnectivityOffline;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;

                return Scaffold(
                  backgroundColor: AppColors.canvas,
                  body: Column(
                    children: [
                      if (isOffline)
                        DegradedBanner(
                          message: 'CONNECTION LOST: Edge daemon unreachable. Live streams paused. Zero mock fallback active.',
                          isOffline: true,
                          onRetry: () => context.read<ConnectivityCubit>().setOnline(),
                        ),
                      Expanded(
                        child: isWide
                            ? Row(
                                children: [
                                  _buildSidebar(context, selectedIndex, activeSiteCode, siteState),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _buildTopBar(context, activeSiteCode, isOffline, siteState),
                                        Expanded(child: child),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildMobileHeader(context, activeSiteCode, isOffline, siteState),
                                  Expanded(child: child),
                                ],
                              ),
                      ),
                    ],
                  ),
                  bottomNavigationBar: isWide
                      ? null
                      : BottomNavigationBar(
                          currentIndex: selectedIndex.clamp(0, 4),
                          onTap: (idx) {
                            if (idx == 0) context.go('/overview');
                            if (idx == 1) context.go('/inbox');
                            if (idx == 2) context.go('/cameras');
                            if (idx == 3) context.go('/employees');
                            if (idx == 4) context.go('/security');
                          },
                          type: BottomNavigationBarType.fixed,
                          backgroundColor: AppColors.panel,
                          selectedItemColor: AppColors.cobalt,
                          unselectedItemColor: AppColors.muted,
                          selectedLabelStyle: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
                          unselectedLabelStyle: AppTypography.labelSmall,
                          items: const [
                            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Overview'),
                            BottomNavigationBarItem(icon: Icon(Icons.notifications_active_outlined), label: 'Alerts'),
                            BottomNavigationBarItem(icon: Icon(Icons.videocam_outlined), label: 'Cameras'),
                            BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: 'Staff'),
                            BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), label: 'Security'),
                          ],
                        ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSidebar(BuildContext context, int selectedIndex, String activeSiteCode, SiteState siteState) {
    final alertState = context.watch<AlertInboxCubit>().state;
    int alertCount = 0;
    if (alertState is AlertInboxLoaded) {
      alertCount = alertState.alerts.where((a) => a.state.toUpperCase() == 'NEW').length;
    } else if (alertState is AlertInboxDegradedOffline) {
      alertCount = alertState.cachedAlerts.where((a) => a.state.toUpperCase() == 'NEW').length;
    }

    return Container(
      width: 224,
      decoration: const BoxDecoration(
        color: AppColors.panel,
        border: Border(right: BorderSide(color: AppColors.borderline, width: 1.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: AppSpacing.p16,
            child: Row(
              children: [
                Container(
                  padding: AppSpacing.p8,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: AppSpacing.roundedSm,
                    border: Border.all(color: AppColors.borderline),
                  ),
                  child: const Icon(Icons.security, color: AppColors.ink, size: 18),
                ),
                AppSpacing.hGap8,
                const Text('SHAWAF AI', style: AppTypography.titleMedium),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderline),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTIVE SITE (RLS)',
                  style: AppTypography.tabularMonoSmall.copyWith(fontSize: 10, letterSpacing: 0.8),
                ),
                AppSpacing.vGap8,
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: AppSpacing.roundedSm,
                    border: Border.all(color: AppColors.borderline),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildSiteButton(context, 'BNF', activeSiteCode == 'BNF', siteState)),
                      Expanded(child: _buildSiteButton(context, 'RNF', activeSiteCode == 'RNF', siteState)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGap8,
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              children: [
                _buildSectionHeader('OPERATIONS'),
                _buildNavItem(context, 0, 'Live Overview', Icons.dashboard_outlined, selectedIndex == 0),
                _buildNavItem(context, 1, 'Live Control', Icons.smart_display_outlined, selectedIndex == 1),
                _buildNavItem(context, 2, 'Camera Wall', Icons.grid_view_outlined, selectedIndex == 2),
                _buildNavItem(context, 3, 'Incident Center', Icons.notifications_active_outlined, selectedIndex == 3, badgeCount: alertCount),
                _buildNavItem(context, 4, 'Employee Directory', Icons.people_alt_outlined, selectedIndex == 4),
                _buildNavItem(context, 5, 'Employee Presence', Icons.radar_outlined, selectedIndex == 5),
                AppSpacing.vGap12,
                _buildSectionHeader('INFRASTRUCTURE'),
                _buildNavItem(context, 6, 'Camera Inventory', Icons.videocam_outlined, selectedIndex == 6),
                _buildNavItem(context, 7, 'NVR Appliances', Icons.dns_outlined, selectedIndex == 7),
                _buildNavItem(context, 8, 'Sites & Facilities', Icons.factory_outlined, selectedIndex == 8),
                _buildNavItem(context, 9, 'Safety Zones', Icons.polyline_outlined, selectedIndex == 9),
                AppSpacing.vGap12,
                _buildSectionHeader('INTELLIGENCE & SYSTEM'),
                _buildNavItem(context, 10, 'AI Analytics', Icons.insights_outlined, selectedIndex == 10),
                _buildNavItem(context, 11, 'System Diagnostics', Icons.monitor_heart_outlined, selectedIndex == 11),
                _buildNavItem(context, 12, 'Audit Trail', Icons.receipt_long_outlined, selectedIndex == 12),
                _buildNavItem(context, 13, 'Settings & Access', Icons.settings_outlined, selectedIndex == 13),
                _buildNavItem(context, 14, 'Security Controls', Icons.shield_outlined, selectedIndex == 14),
              ],
            ),
          ),
          Container(
            padding: AppSpacing.p16,
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderline, width: 1.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Operator Role', style: AppTypography.bodySmall.copyWith(color: AppColors.muted)),
                    Text('SEC_MGR', style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.ink)),
                  ],
                ),
                AppSpacing.vGap4,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('DB Isolation', style: AppTypography.bodySmall.copyWith(color: AppColors.muted)),
                    Text('RLS ON', style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.dim,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          fontFamily: 'JetBrains Mono',
        ),
      ),
    );
  }

  Widget _buildSiteButton(BuildContext context, String code, bool isActive, SiteState siteState) {
    return Material(
      color: isActive ? AppColors.elevated : AppColors.transparent,
      borderRadius: AppSpacing.roundedXs,
      child: InkWell(
        onTap: () => _switchSite(context, code, siteState),
        borderRadius: AppSpacing.roundedXs,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: AppSpacing.roundedXs,
            border: Border.all(color: isActive ? AppColors.borderline : AppColors.transparent),
          ),
          child: Text(
            code,
            style: AppTypography.tabularMonoSmall.copyWith(
              color: isActive ? AppColors.ink : AppColors.muted,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, String label, IconData icon, bool isSelected, {int? badgeCount}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Material(
        color: isSelected ? AppColors.elevated : AppColors.transparent,
        borderRadius: AppSpacing.roundedSm,
        child: InkWell(
          onTap: () => _onNavigate(index, context),
          borderRadius: AppSpacing.roundedSm,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 16, color: isSelected ? AppColors.cobalt : AppColors.muted),
                AppSpacing.hGap12,
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.bodySmall.copyWith(
                      color: isSelected ? AppColors.ink : AppColors.muted,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badgeCount != null && badgeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.crimson.withValues(alpha: 0.2),
                      borderRadius: AppSpacing.roundedXs,
                      border: Border.all(color: AppColors.crimson.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: AppTypography.tabularMonoSmall.copyWith(
                        color: AppColors.crimson,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, String activeSiteCode, bool isOffline, SiteState siteState) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.panel,
        border: Border(bottom: BorderSide(color: AppColors.borderline, width: 1.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('SITE: $activeSiteCode', style: AppTypography.titleSmall),
              AppSpacing.hGap8,
              const Text('·', style: TextStyle(color: AppColors.dim)),
              AppSpacing.hGap8,
              const Text('ON-PREMISES CONTROL ROOM', style: AppTypography.tabularMonoSmall),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOffline ? AppColors.crimson.withValues(alpha: 0.15) : AppColors.emerald.withValues(alpha: 0.15),
                  borderRadius: AppSpacing.roundedSm,
                  border: Border.all(color: isOffline ? AppColors.crimson : AppColors.emerald.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isOffline ? AppColors.crimson : AppColors.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpacing.hGap8,
                    Text(
                      isOffline ? 'OFFLINE' : 'ONLINE (3.6ms)',
                      style: AppTypography.tabularMonoSmall.copyWith(
                        color: isOffline ? AppColors.crimson : AppColors.emerald,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.hGap12,
              IconButton(
                icon: const Icon(Icons.refresh, size: 18, color: AppColors.muted),
                tooltip: 'Refresh',
                onPressed: () {
                  context.read<SiteCubit>().loadSites();
                  if (siteState is SiteLoaded) {
                    context.read<AlertInboxCubit>().loadAlerts(siteState.selectedSite.id);
                    context.read<CameraStreamCubit>().loadCameras(siteState.selectedSite.id);
                    context.read<EmployeeCubit>().load(siteState.selectedSite.id);
                  }
                },
              ),
              AppSpacing.hGap4,
              IconButton(
                icon: const Icon(Icons.logout, size: 18, color: AppColors.muted),
                tooltip: 'Sign Out',
                onPressed: () {
                  context.read<AuthCubit>().logout();
                  context.go('/login');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context, String activeSiteCode, bool isOffline, SiteState siteState) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.panel,
        border: Border(bottom: BorderSide(color: AppColors.borderline, width: 1.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.security, color: AppColors.cobalt, size: 18),
              AppSpacing.hGap8,
              const Text('SHAWAF AI', style: AppTypography.titleSmall),
              AppSpacing.hGap8,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: AppSpacing.roundedXs,
                  border: Border.all(color: AppColors.borderline),
                ),
                child: Text(activeSiteCode, style: AppTypography.tabularMonoSmall.copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOffline ? AppColors.crimson : AppColors.emerald,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
