import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/site_banner.dart';
import 'inbox_screen.dart';
import 'cameras_screen.dart';

class HomeScreen extends StatefulWidget {
  final ApiService apiService;

  const HomeScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  bool _isLoading = true;

  List<Site> _sites = [];
  Site? _currentSite;
  List<SurveillanceEvent> _alerts = [];
  List<Camera> _cameras = [];
  List<Zone> _zones = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    _sites = await widget.apiService.getSites();
    if (_sites.isNotEmpty) {
      _currentSite = _sites.first;
      await _loadSiteData(_currentSite!.id);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadSiteData(String siteId) async {
    final alerts = await widget.apiService.getAlertsInbox(siteId);
    final cameras = await widget.apiService.getCameras(siteId);
    final zones = await widget.apiService.getZones(siteId);

    setState(() {
      _alerts = alerts;
      _cameras = cameras;
      _zones = zones;
    });

    // Connect WebSocket
    widget.apiService.connectWebSocket(siteId, (newEvent) {
      setState(() {
        _alerts.insert(0, newEvent);
      });
    });
  }

  void _onSiteChanged(Site newSite) {
    if (_currentSite?.id == newSite.id) return;
    setState(() {
      _currentSite = newSite;
    });
    _loadSiteData(newSite.id);
  }

  void _handleAlertAction(SurveillanceEvent event, String action, String note) async {
    await widget.apiService.executeAlertAction(event.siteId, event.id, action, note);
    setState(() {
      event.state = action == 'ACKNOWLEDGE'
          ? 'ACKNOWLEDGED'
          : (action == 'DISMISS' ? 'DISMISSED' : 'ESCALATED');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentSite == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryTeal),
        ),
      );
    }

    final newAlertsCount = _alerts.where((a) => a.state == 'NEW').length;

    return Scaffold(
      appBar: AppBar(
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
            const Text('شوف', style: TextStyle(color: AppTheme.primaryTeal, fontSize: 16)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                const Text('RLS ACTIVE', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Persistent Two-Tap Site Switcher Banner
          SiteBanner(
            currentSite: _currentSite!,
            availableSites: _sites,
            onSiteSelected: _onSiteChanged,
          ),

          // Main Screen Body
          Expanded(
            child: IndexedStack(
              index: _currentTabIndex,
              children: [
                InboxScreen(
                  currentSite: _currentSite!,
                  alerts: _alerts,
                  onRefresh: () => _loadSiteData(_currentSite!.id),
                  onAlertAction: _handleAlertAction,
                ),
                CamerasScreen(
                  cameras: _cameras,
                  zones: _zones,
                  onRefresh: () => _loadSiteData(_currentSite!.id),
                ),
                _buildComplianceDashboard(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (idx) => setState(() => _currentTabIndex = idx),
        items: [
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: newAlertsCount > 0,
              label: Text('$newAlertsCount'),
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
            icon: Icon(Icons.verified_user_outlined),
            activeIcon: Icon(Icons.verified_user),
            label: 'Compliance',
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceDashboard() {
    final activeCams = _cameras.where((c) => c.healthStatus == 'STREAMING').length;
    final totalCams = _cameras.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PLANT COMPLIANCE & OBSERVABILITY',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),

          // Metric cards
          Row(
            children: [
              Expanded(
                child: _metricCard('ACTIVE CAMERAS', '$activeCams / $totalCams', AppTheme.primaryTeal, Icons.videocam),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metricCard('SAFETY ZONES', '${_zones.length} ARMED', AppTheme.primaryTeal, Icons.security_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _metricCard('WATCHDOG STATUS', 'HEALTHY', AppTheme.successGreen, Icons.speed_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metricCard('PRIVACY LAW 151', 'COMPLIANT', AppTheme.successGreen, Icons.lock_outline),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Egyptian Law 151/2020 Compliance Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Egyptian Data Protection Law (Law 151/2020) Enforcement',
                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(height: 8),
                Text(
                  '• On-Premises Isolation: Raw video streams never leave factory premises.\n'
                  '• Zero Unmasked PII: Real-time neural masking applied to non-incident facial features.\n'
                  '• Cryptographic Audit Trail: All dismissals and acknowledgments permanently logged with operator ID.\n'
                  '• WireGuard Isolated Interconnect: BNF and RNF operate on isolated subnets with mutual TLS.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value, Color color, IconData icon) {
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
              Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
