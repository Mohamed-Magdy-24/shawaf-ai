import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../sites/presentation/cubit/site_cubit.dart';
import '../cubit/employee_cubit.dart';
import '../widgets/presence_radar_widget.dart';

class EmployeesPage extends StatelessWidget {
  const EmployeesPage({super.key});

  void _showEnrollDialog(BuildContext context, String siteId) {
    final idCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final deptCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Enroll Employee', style: AppTypography.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idCtrl,
              decoration: const InputDecoration(labelText: 'Employee ID', hintText: 'EMP-001'),
            ),
            AppSpacing.vGap12,
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name', hintText: 'Full Name'),
            ),
            AppSpacing.vGap12,
            TextField(
              controller: deptCtrl,
              decoration: const InputDecoration(labelText: 'Department', hintText: 'Operations'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          AppButton(
            label: 'ENROLL',
            onPressed: () {
              if (idCtrl.text.isNotEmpty && nameCtrl.text.isNotEmpty) {
                final dept = deptCtrl.text.trim().isEmpty ? 'General' : deptCtrl.text.trim();
                context.read<EmployeeCubit>().enrollEmployee(siteId, {
                  'employee_id': idCtrl.text.trim(),
                  'full_name': nameCtrl.text.trim(),
                  'department': dept,
                });
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SiteCubit, SiteState>(
      builder: (context, siteState) {
        if (siteState is SiteError) {
          return ErrorStateView(
            errorMessage: siteState.message,
            onRetry: () => context.read<SiteCubit>().loadSites(),
          );
        }

        if (siteState is! SiteLoaded) {
          return const Center(child: CircularProgressIndicator(color: AppColors.cobalt));
        }

        final currentSite = siteState.selectedSite;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: AppColors.canvas,
            appBar: AppBar(
              backgroundColor: AppColors.panel,
              title: Text('Personnel & IDs: ${currentSite.code}', style: AppTypography.titleMedium),
              bottom: const TabBar(
                indicatorColor: AppColors.cobalt,
                labelColor: AppColors.cobalt,
                unselectedLabelColor: AppColors.muted,
                tabs: [
                  Tab(icon: Icon(Icons.radar), text: 'WHO & WHERE RADAR'),
                  Tab(icon: Icon(Icons.people_alt_outlined), text: 'DIRECTORY'),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: AppColors.cobalt,
              foregroundColor: AppColors.ink,
              onPressed: () => _showEnrollDialog(context, currentSite.id),
              child: const Icon(Icons.person_add_alt_1_outlined),
            ),
            body: BlocBuilder<EmployeeCubit, EmployeeState>(
              builder: (context, empState) {
                if (empState is EmployeeInitial) {
                  context.read<EmployeeCubit>().load(currentSite.id);
                  return ListView.builder(
                    padding: AppSpacing.p16,
                    itemCount: 4,
                    itemBuilder: (_, __) => const ShimmerSkeletonCard(),
                  );
                }

                if (empState is EmployeeLoading) {
                  return ListView.builder(
                    padding: AppSpacing.p16,
                    itemCount: 4,
                    itemBuilder: (_, __) => const ShimmerSkeletonCard(),
                  );
                }

                if (empState is EmployeeError) {
                  return ErrorStateView(
                    errorMessage: empState.message,
                    onRetry: () => context.read<EmployeeCubit>().load(currentSite.id),
                  );
                }

                final loaded = empState as EmployeeLoaded;

                return TabBarView(
                  children: [
                    PresenceRadarWidget(presenceList: loaded.presence),
                    loaded.employees.isEmpty
                        ? EmptyStateView(
                            icon: Icons.people_outline,
                            title: 'No Enrolled Personnel',
                            description: 'Zero mock mode active. Enroll staff for ${currentSite.code} using the + button.',
                            actionLabel: 'REFRESH',
                            onAction: () => context.read<EmployeeCubit>().load(currentSite.id),
                          )
                        : ListView.builder(
                            padding: AppSpacing.p16,
                            itemCount: loaded.employees.length,
                            itemBuilder: (context, index) {
                              final emp = loaded.employees[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: AppCard(
                                  padding: AppSpacing.p12,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.badge_outlined, color: AppColors.cobalt),
                                      AppSpacing.hGap12,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(emp.fullName, style: AppTypography.titleSmall),
                                            Text('${emp.id} • ${emp.department}', style: AppTypography.bodySmall),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
