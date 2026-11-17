import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/alert_inbox_cubit.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/camera_stream_cubit.dart';
import '../cubits/site_cubit.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/site_switcher_banner.dart';
import 'add_camera_screen.dart';
import 'cameras_screen.dart';
import 'employees_screen.dart';
import 'inbox_screen.dart';

class HomeScreen extends StatelessWidget {
  final ValueNotifier<int> _activeTab = ValueNotifier<int>(0);

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SiteCubit, SiteState>(
      listener: (context, state) {
        if (state is SiteLoaded) {
          final siteId = state.selectedSite.id;
          context.read<AlertInboxCubit>().loadAlerts(siteId);
          context.read<CameraStreamCubit>().loadCameras(siteId);
        }
      },
      child: BlocBuilder<SiteCubit, SiteState>(
        builder: (context, siteState) {
          if (siteState is SiteLoading || siteState is SiteInitial) {
            return const Scaffold(
              backgroundColor: AppTheme.background,
              body: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryTeal),
              ),
            );
          }

          if (siteState is SiteError) {
            return Scaffold(
              backgroundColor: AppTheme.background,
              body: EmptyStateView(
                icon: Icons.cloud_off,
                title: 'SITE DISCOVERY FAILED',
                message: siteState.message,
                actionLabel: 'RETRY CONNECTION',
                onAction: () => context.read<SiteCubit>().loadSites(),
              ),
            );
          }

          final loaded = siteState as SiteLoaded;
          final currentSite = loaded.selectedSite;
          final availableSites = loaded.sites;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 1024;
              final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth <= 1024;

              return Scaffold(
                backgroundColor: AppTheme.background,
                appBar: _buildAppBar(context, currentSite),
                body: ValueListenableBuilder<int>(
                  valueListenable: _activeTab,
                  builder: (context, tabIndex, _) {
                    if (isDesktop) {
                      return _buildDesktopLayout(context, currentSite, availableSites, tabIndex);
                    } else if (isTablet) {
                      return _buildTabletLayout(context, currentSite, availableSites, tabIndex);
                    } else {
                      return _buildMobileLayout(context, currentSite, availableSites, tabIndex);
                    }
                  },
                ),
                bottomNavigationBar: (!isDesktop && !isTablet)
                    ? ValueListenableBuilder<int>(
                        valueListenable: _activeTab,
                        builder: (context, tabIndex, _) {
                          return BlocBuilder<AlertInboxCubit, AlertInboxState>(
                            builder: (context, inboxState) {
                              int newCount = 0;
                              if (inboxState is AlertInboxLoaded) {
                                newCount = inboxState.alerts.where((a) => a.state == 'NEW').length;
                              }
                              return BottomNavigationBar(
                                currentIndex: tabIndex,
                                onTap: (idx) => _activeTab.value = idx,
                                items: [
                                  BottomNavigationBarItem(
                                    icon: Badge(
                                      isLabelVisible: newCount > 0,
                                      label: Text('$newCount'),
                                      backgroundColor: AppTheme.sev1Red,
                                      child: const Icon(Icons.notifications_active_outlined),
                                    ),
                                    activeIcon: const Icon(Icons.notifications_active),
                                    label: 'Alert Inbox',
                                  ),
                                  const BottomNavigationBarItem(
                                    icon: Icon(Icons.videocam_outlined),
                                    activeIcon: Icon(Icons.videocam),
                                    label: 'Cameras',
                                  ),
                                  const BottomNavigationBarItem(
                                    icon: Icon(Icons.shield_outlined),
                                    activeIcon: Icon(Icons.shield),
                                    label: 'Compliance',
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Site currentSite) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.security, color: AppTheme.primaryTeal, size: 20),
          ),
          const SizedBox(width: 10),
          const Text('SHAWAF AI'),
          const SizedBox(width: 6),
          const Text(
            'شوف',
            style: TextStyle(
              color: AppTheme.primaryTeal,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.successGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'RLS ACTIVE',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Personnel & Presence',
          icon: const Icon(Icons.people_alt_outlined, size: 20, color: AppTheme.primaryTeal),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeesScreen())),
        ),
        IconButton(
          tooltip: 'Add Camera',
          icon: const Icon(Icons.add_a_photo_outlined, size: 20, color: AppTheme.primaryTeal),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCameraScreen())),
        ),
        IconButton(
          tooltip: 'Logout',
          icon: const Icon(Icons.logout, size: 20, color: AppTheme.textSecondary),
          onPressed: () => context.read<AuthCubit>().logout(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    Site currentSite,
    List<Site> availableSites,
    int tabIndex,
  ) {
    return Column(
      children: [
        SiteSwitcherBanner(
          currentSite: currentSite,
          availableSites: availableSites,
          onSiteSelected: (s) => context.read<SiteCubit>().selectSite(s),
        ),
        Expanded(
          child: IndexedStack(
            index: tabIndex,
            children: [
              InboxScreen(),
              const CamerasScreen(),
              _buildComplianceView(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    Site currentSite,
    List<Site> availableSites,
    int tabIndex,
  ) {
    return Row(
      children: [
        NavigationRail(
          backgroundColor: AppTheme.surface,
          selectedIndex: tabIndex,
          onDestinationSelected: (idx) => _activeTab.value = idx,
          labelType: NavigationRailLabelType.selected,
          selectedIconTheme: const IconThemeData(color: AppTheme.primaryTeal),
          selectedLabelTextStyle: const TextStyle(
            color: AppTheme.primaryTeal,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedIconTheme: const IconThemeData(color: AppTheme.textSecondary),
          unselectedLabelTextStyle: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.notifications_active_outlined),
              selectedIcon: Icon(Icons.notifications_active),
              label: Text('Alerts'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.videocam_outlined),
              selectedIcon: Icon(Icons.videocam),
              label: Text('Cameras'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield),
              label: Text('Compliance'),
            ),
          ],
        ),
        const VerticalDivider(width: 1, color: AppTheme.border),
        Expanded(
          child: Column(
            children: [
              SiteSwitcherBanner(
                currentSite: currentSite,
                availableSites: availableSites,
                onSiteSelected: (s) => context.read<SiteCubit>().selectSite(s),
              ),
              Expanded(
                child: IndexedStack(
                  index: tabIndex,
                  children: [
                    InboxScreen(),
                    const CamerasScreen(),
                    _buildComplianceView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    Site currentSite,
    List<Site> availableSites,
    int tabIndex,
  ) {
    return Row(
      children: [
        // Side navigation rail
        NavigationRail(
          backgroundColor: AppTheme.surface,
          selectedIndex: tabIndex,
          onDestinationSelected: (idx) => _activeTab.value = idx,
          extended: true,
          minExtendedWidth: 200,
          selectedIconTheme: const IconThemeData(color: AppTheme.primaryTeal),
          selectedLabelTextStyle: const TextStyle(
            color: AppTheme.primaryTeal,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          unselectedIconTheme: const IconThemeData(color: AppTheme.textSecondary),
          unselectedLabelTextStyle: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.notifications_active_outlined),
              selectedIcon: Icon(Icons.notifications_active),
              label: Text('Incident Inbox'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.videocam_outlined),
              selectedIcon: Icon(Icons.videocam),
              label: Text('Camera Matrix'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield),
              label: Text('Compliance & RLS'),
            ),
          ],
        ),
        const VerticalDivider(width: 1, color: AppTheme.border),
        // Master-Detail Web Split View
        Expanded(
          child: Column(
            children: [
              SiteSwitcherBanner(
                currentSite: currentSite,
                availableSites: availableSites,
                onSiteSelected: (s) => context.read<SiteCubit>().selectSite(s),
              ),
              Expanded(
                child: Row(
                  children: [
                    // Master Left Pane (60% width)
                    Expanded(
                      flex: 6,
                      child: IndexedStack(
                        index: tabIndex,
                        children: [
                          InboxScreen(),
                          const CamerasScreen(),
                          _buildComplianceView(),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 1, color: AppTheme.border),
                    // Detail Right Pane (40% width)
                    Expanded(
                      flex: 4,
                      child: Container(
                        color: AppTheme.surface,
                        padding: const EdgeInsets.all(20),
                        child: _buildDesktopDetailInspector(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopDetailInspector(BuildContext context) {
    return BlocBuilder<AlertInboxCubit, AlertInboxState>(
      builder: (context, inboxState) {
        if (inboxState is AlertInboxLoaded && inboxState.alerts.isNotEmpty) {
          final topAlert = inboxState.alerts.first;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LATEST INCIDENT INSPECTOR',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                topAlert.eventType.replaceAll('_', ' '),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Camera: ${topAlert.cameraId} • Zone: ${topAlert.zoneId}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    _metricRow('Status', topAlert.state),
                    _metricRow('Severity', topAlert.severity),
                    _metricRow('Track ID', '#${topAlert.trackId}'),
                    _metricRow('Confidence', '${(topAlert.confidence * 100).toStringAsFixed(1)}%'),
                    _metricRow('Timestamp', topAlert.occurredAt.toUtc().toIso8601String()),
                  ],
                ),
              ),
            ],
          );
        }

        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monitor_heart_outlined, size: 48, color: AppTheme.textMuted),
              SizedBox(height: 12),
              Text(
                'SYSTEM TELEMETRY NOMINAL',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Select an incident or camera to view real-time inspector.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComplianceView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PLANT COMPLIANCE & OBSERVABILITY',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard('RLS ISOLATION', 'ENFORCED', AppTheme.successGreen, Icons.lock_outline),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard('LAW 151/2020', 'PROTECTED', AppTheme.primaryTeal, Icons.security_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard('WIREGUARD', 'ISOLATED', AppTheme.primaryTeal, Icons.hub_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard('BIOMETRICS', 'GOVERNANCE BLOCKED', AppTheme.sev2Amber, Icons.block_outlined),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Governance & Compliance Policies',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '• Strict Dual-Site Boundary: BNF and RNF sites are partitioned at the database layer via PostgreSQL Row-Level Security (RLS).\n'
                  '• Egyptian Law 151/2020 Privacy Masking: Facial features and non-incident person descriptors are masked at the edge before streaming.\n'
                  '• Face Recognition Prohibited: Attendance and employee photo sync endpoints return HTTP 503 FEATURE_BLOCKED_BY_GOVERNANCE.\n'
                  '• Cryptographic Audit Trail: All dismissals require a verified audit note (>= 10 chars) with operator attribution.\n'
                  '• Zero-Trust Stream Gateway: WebRTC streams proxy through edged reverse-proxy, keeping go2rtc internal.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _metricRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
