import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/site_switcher_banner.dart';
import '../cubits/alert_inbox_cubit.dart';
import '../cubits/camera_stream_cubit.dart';
import '../cubits/site_cubit.dart';
import '../features/alerts/presentation/pages/inbox_page.dart';
import '../features/cameras/presentation/pages/cameras_page.dart';
import '../features/employees/presentation/pages/employees_page.dart';

class HomeScreen extends StatelessWidget {
  final ValueNotifier<int> _tabNotifier = ValueNotifier<int>(0);

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SiteCubit, SiteState>(
      listener: (context, state) {
        if (state is SiteLoaded) {
          final id = state.selectedSite.id;
          context.read<AlertInboxCubit>().loadAlerts(id);
          context.read<CameraStreamCubit>().loadCameras(id);
        }
      },
      builder: (context, siteState) {
        final activeSiteCode =
            siteState is SiteLoaded ? siteState.selectedSite.code : 'BNF';

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
                  child: const Icon(Icons.security,
                      color: AppColors.primary, size: 20),
                ),
                AppSpacing.hGap8,
                const Text('SHAWAF AI', style: AppTypography.titleLarge),
                AppSpacing.hGap4,
                Text('شوف',
                    style: AppTypography.titleLarge
                        .copyWith(color: AppColors.primary)),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: SiteSwitcherBanner(
                activeSiteCode: activeSiteCode,
                onSiteSelected: (code) {
                  context.read<SiteCubit>().selectSite(code);
                },
              ),
            ),
          ),
          body: ValueListenableBuilder<int>(
            valueListenable: _tabNotifier,
            builder: (context, tabIdx, _) {
              switch (tabIdx) {
                case 1:
                  return const CamerasPage();
                case 2:
                  return const EmployeesPage();
                case 0:
                default:
                  return const InboxPage();
              }
            },
          ),
          bottomNavigationBar: ValueListenableBuilder<int>(
            valueListenable: _tabNotifier,
            builder: (context, tabIdx, _) {
              return BottomNavigationBar(
                currentIndex: tabIdx,
                onTap: (idx) => _tabNotifier.value = idx,
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
              );
            },
          ),
        );
      },
    );
  }
}
