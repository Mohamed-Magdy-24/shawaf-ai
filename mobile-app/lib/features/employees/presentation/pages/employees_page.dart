import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Enroll Employee', style: AppTypography.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'Employee ID (e.g. EMP-101)')),
            AppSpacing.vGap12,
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          AppButton(
            label: 'ENROLL',
            onPressed: () {
              if (idCtrl.text.isNotEmpty && nameCtrl.text.isNotEmpty) {
                context.read<EmployeeCubit>().enrollEmployee(siteId, {
                  'employee_id': idCtrl.text.trim(),
                  'full_name': nameCtrl.text.trim(),
                  'department': 'OPERATIONS',
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
        if (siteState is! SiteLoaded) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final currentSite = siteState.selectedSite;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text('Personnel: ${currentSite.code}', style: AppTypography.titleLarge),
              bottom: const TabBar(
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: [
                  Tab(icon: Icon(Icons.radar), text: 'WHO & WHERE RADAR'),
                  Tab(icon: Icon(Icons.people_alt_outlined), text: 'DIRECTORY'),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryTextOn,
              onPressed: () => _showEnrollDialog(context, currentSite.id),
              child: const Icon(Icons.person_add_alt_1_outlined),
            ),
            body: BlocBuilder<EmployeeCubit, EmployeeState>(
              builder: (context, empState) {
                if (empState is EmployeeLoading || empState is EmployeeInitial) {
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
                    ListView.builder(
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
                                const Icon(Icons.badge_outlined, color: AppColors.primary),
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
