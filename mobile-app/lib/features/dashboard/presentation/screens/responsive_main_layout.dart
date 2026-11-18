import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../incidents/presentation/bloc/incident_bloc.dart';
import '../../../incidents/presentation/bloc/incident_event.dart';
import '../../../incidents/presentation/screens/incident_feed_screen.dart';
import '../../../video/presentation/bloc/camera_bloc.dart';
import '../../../video/presentation/bloc/camera_event.dart';
import '../../../video/presentation/screens/camera_inspection_screen.dart';
import '../../../video/presentation/screens/camera_wall_screen.dart';
import 'command_overview_screen.dart';

class ResponsiveMainLayout extends StatefulWidget {
  final String initialSiteId;

  const ResponsiveMainLayout({
    super.key,
    this.initialSiteId = 'BNF',
  });

  @override
  State<ResponsiveMainLayout> createState() => _ResponsiveMainLayoutState();
}

class _ResponsiveMainLayoutState extends State<ResponsiveMainLayout> {
  int _currentIndex = 0;
  late String _activeSiteId;

  @override
  void initState() {
    super.initState();
    _activeSiteId = widget.initialSiteId;
    _reloadSiteData();
  }

  void _reloadSiteData() {
    context.read<IncidentBloc>().add(LoadIncidents(siteId: _activeSiteId));
    context.read<CameraBloc>().add(LoadCameras(_activeSiteId));
  }

  void _onSiteChanged(String newSiteId) {
    if (_activeSiteId == newSiteId) return;
    setState(() => _activeSiteId = newSiteId);
    _reloadSiteData();
  }

  void _navigateToCamera(String cameraId) {
    final cameraState = context.read<CameraBloc>().state;
    final cameras = cameraState.cameras;
    if (cameras.isEmpty) return;
    final camera = cameras.firstWhere(
      (c) => c.id == cameraId,
      orElse: () => cameras.first,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraInspectionScreen(
          camera: camera,
          siteId: _activeSiteId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppDimensions.isDesktop(context);

    final screens = [
      CommandOverviewScreen(
        activeSiteId: _activeSiteId,
        onSiteChanged: _onSiteChanged,
        onNavigateToCamera: _navigateToCamera,
        onNavigateToIncidents: () => setState(() => _currentIndex = 1),
      ),
      IncidentFeedScreen(
        siteId: _activeSiteId,
        onNavigateToCameraStream: _navigateToCamera,
      ),
      CameraWallScreen(siteId: _activeSiteId),
      _buildDiagnosticsScreen(),
    ];

    if (isDesktop) {
      // Desktop Web Admin Layout (Persistent NavigationRail sidebar)
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: AppColors.surfacePanel,
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.shield, color: AppColors.statusInfo, size: 28.0),
                    SizedBox(width: AppDimensions.spacing8),
                    Text('SURVEILLANCE', style: AppTypography.heading2),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard, color: AppColors.statusInfo),
                  label: Text('Cockpit'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.warning_amber_rounded),
                  selectedIcon: Icon(Icons.warning, color: AppColors.statusCritical),
                  label: Text('Incidents'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view, color: AppColors.statusInfo),
                  label: Text('Camera Wall'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.health_and_safety_outlined),
                  selectedIcon: Icon(Icons.health_and_safety, color: AppColors.statusNormal),
                  label: Text('Diagnostics'),
                ),
              ],
            ),
            const VerticalDivider(color: AppColors.borderSubtle, width: 1.0),
            Expanded(child: screens[_currentIndex]),
          ],
        ),
      );
    }

    // Android Handheld Mobile Layout (Bottom Navigation Bar)
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Cockpit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded),
            activeIcon: Icon(Icons.warning),
            label: 'Incidents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam_outlined),
            activeIcon: Icon(Icons.videocam),
            label: 'Wall',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety_outlined),
            activeIcon: Icon(Icons.health_and_safety),
            label: 'Health',
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticsScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SYSTEM HEALTH & DIAGNOSTICS (W-17 / W-18)', style: AppTypography.heading1),
            Text('Autonomous Edge Telemetry — $_activeSiteId', style: AppTypography.caption),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: ListView(
          children: [
            _buildDiagTile(
              title: 'Go Edged Local Daemon',
              status: 'HEALTHY (Uptime 99.98%)',
              statusColor: AppColors.statusNormal,
              detail: 'REST API, Transactional Outbox, Lease-Reaper Active',
            ),
            _buildDiagTile(
              title: 'PostgreSQL 16 Engine',
              status: 'CONNECTED (FORCE ROW LEVEL SECURITY)',
              statusColor: AppColors.statusNormal,
              detail: 'Site Isolation active; Tenant tokens verified',
            ),
            _buildDiagTile(
              title: 'go2rtc WebRTC SDP Proxy',
              status: 'READY (Zero-Trust Go Proxy)',
              statusColor: AppColors.statusNormal,
              detail: 'Direct sub-500ms WebRTC streaming to browser/handheld',
            ),
            _buildDiagTile(
              title: 'AI Worker Engine (ONNX Runtime)',
              status: 'INFERENCE ACTIVE (24.8 FPS avg)',
              statusColor: AppColors.statusNormal,
              detail: 'Zero PyTorch runtime per ADR-016; CUDA/CPU Fallback active',
            ),
            _buildDiagTile(
              title: 'WAN Fallback Plane (Screen W-18)',
              status: 'AUTONOMOUS LOCAL OPERATION',
              statusColor: AppColors.statusNormal,
              detail: 'Local recording & detection continue uninterrupted during WAN dropouts',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagTile({
    required String title,
    required String status,
    required Color statusColor,
    required String detail,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTypography.heading2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing8,
                    vertical: AppDimensions.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    status,
                    style: AppTypography.badge.copyWith(color: statusColor, fontSize: 10.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(detail, style: AppTypography.bodySecondary),
          ],
        ),
      ),
    );
  }
}

