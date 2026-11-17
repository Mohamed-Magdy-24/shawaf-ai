import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/site_switcher_banner.dart';
import '../../features/sites/presentation/cubit/site_cubit.dart';
import '../../features/alerts/presentation/cubit/alert_inbox_cubit.dart';
import '../../features/cameras/presentation/cubit/camera_stream_cubit.dart';

class NavigationShell extends StatelessWidget {
  final Widget child;

  const NavigationShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/cameras')) return 1;
    if (location.startsWith('/employees')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/inbox');
        break;
      case 1:
        context.go('/cameras');
        break;
      case 2:
        context.go('/employees');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return BlocBuilder<SiteCubit, SiteState>(
      builder: (context, siteState) {
        final activeSiteCode = siteState is SiteLoaded ? siteState.selectedSite.code : 'BNF';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: AppSpacing.p4,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: AppSpacing.roundedXs,
                  ),
                  child: const Icon(Icons.security, color: AppColors.primary, size: 20),
                ),
                AppSpacing.hGap8,
                const Text('SHAWAF AI', style: AppTypography.titleLarge),
                AppSpacing.hGap4,
                Text('شوف', style: AppTypography.titleLarge.copyWith(color: AppColors.primary)),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: SiteSwitcherBanner(
                activeSiteCode: activeSiteCode,
                onSiteSelected: (siteCode) {
                  context.read<SiteCubit>().selectSite(siteCode);
                  if (siteState is SiteLoaded) {
                    final site = siteState.sites.firstWhere(
                      (s) => s.code.toUpperCase() == siteCode.toUpperCase(),
                      orElse: () => siteState.selectedSite,
                    );
                    context.read<AlertInboxCubit>().loadAlerts(site.id);
                    context.read<CameraStreamCubit>().loadCameras(site.id);
                  }
                },
              ),
            ),
          ),
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (idx) => _onItemTapped(idx, context),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_active_outlined),
                activeIcon: Icon(Icons.notifications_active),
                label: 'Alerts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.videocam_outlined),
                activeIcon: Icon(Icons.videocam),
                label: 'Cameras',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_alt_outlined),
                activeIcon: Icon(Icons.people_alt),
                label: 'Personnel',
              ),
            ],
          ),
        );
      },
    );
  }
}
