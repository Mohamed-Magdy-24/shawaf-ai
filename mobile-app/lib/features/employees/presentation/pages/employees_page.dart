import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../models/models.dart';
import '../../../sites/presentation/cubit/site_cubit.dart';
import '../cubit/employee_cubit.dart';

class EmployeesPage extends StatelessWidget {
  const EmployeesPage({super.key});

  void _showEnrollDialog(BuildContext context, String siteId) {
    final idCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final deptCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panel,
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.roundedMd,
          side: BorderSide(color: AppColors.borderline),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: AppSpacing.roundedXs,
                border: Border.all(color: AppColors.borderline),
              ),
              child: const Icon(Icons.person_add_alt_1,
                  color: AppColors.cobalt, size: 18),
            ),
            AppSpacing.hGap12,
            const Text('Enroll Employee', style: AppTypography.titleMedium),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enroll employee biometric identity. Leave fields empty until real data is entered.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
              ),
              AppSpacing.vGap16,
              TextField(
                controller: idCtrl,
                style: AppTypography.tabularMonoSmall
                    .copyWith(color: AppColors.ink),
                decoration: const InputDecoration(
                  labelText: 'Employee ID *',
                  hintText: 'e.g. EMP-1050',
                ),
              ),
              AppSpacing.vGap12,
              TextField(
                controller: nameCtrl,
                style: AppTypography.bodySmall.copyWith(color: AppColors.ink),
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'e.g. Ahmed Ali',
                ),
              ),
              AppSpacing.vGap12,
              TextField(
                controller: deptCtrl,
                style: AppTypography.bodySmall.copyWith(color: AppColors.ink),
                decoration: const InputDecoration(
                  labelText: 'Department *',
                  hintText: 'e.g. Operations / Safety',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style:
                    AppTypography.bodySmall.copyWith(color: AppColors.muted)),
          ),
          AppButton(
            label: 'SAVE & ENROLL',
            variant: ButtonVariant.primary,
            onPressed: () {
              final empId = idCtrl.text.trim();
              final name = nameCtrl.text.trim();
              final dept = deptCtrl.text.trim().isEmpty
                  ? 'Operations'
                  : deptCtrl.text.trim();
              if (empId.isNotEmpty && name.isNotEmpty) {
                context.read<EmployeeCubit>().enrollEmployee(siteId, {
                  'employee_id': empId,
                  'full_name': name,
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

  void _showImportDialog(BuildContext context, String siteId) {
    final csvCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panel,
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.roundedMd,
          side: BorderSide(color: AppColors.borderline),
        ),
        title: const Text('Bulk Import Employees (CSV)',
            style: AppTypography.titleMedium),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paste CSV lines: employee_id,full_name,department',
                style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
              ),
              AppSpacing.vGap12,
              TextField(
                controller: csvCtrl,
                maxLines: 6,
                style: AppTypography.tabularMonoSmall
                    .copyWith(color: AppColors.ink, fontSize: 11),
                decoration: const InputDecoration(
                  hintText:
                      'EMP-101,Ahmed Ali,Operations\nEMP-102,Khaled Omar,Safety',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style:
                    AppTypography.bodySmall.copyWith(color: AppColors.muted)),
          ),
          AppButton(
            label: 'IMPORT ROWS',
            variant: ButtonVariant.primary,
            onPressed: () {
              final text = csvCtrl.text.trim();
              if (text.isNotEmpty) {
                context.read<EmployeeCubit>().bulkImport(siteId, text);
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
        if (siteState is SiteInitial) {
          context.read<SiteCubit>().loadSites();
          return const Center(
              child: CircularProgressIndicator(color: AppColors.cobalt));
        }

        if (siteState is SiteError) {
          final isAuthError =
              siteState.message.toLowerCase().contains('unauthorized') ||
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
          return const Center(
              child: CircularProgressIndicator(color: AppColors.cobalt));
        }

        final currentSite = siteState.selectedSite;

        return Scaffold(
          backgroundColor: AppColors.canvas,
          body: SingleChildScrollView(
            padding: AppSpacing.p20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, currentSite),
                AppSpacing.vGap20,
                BlocBuilder<EmployeeCubit, EmployeeState>(
                  builder: (context, empState) {
                    if (empState is EmployeeInitial) {
                      context.read<EmployeeCubit>().load(currentSite.id);
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        itemBuilder: (_, __) => const ShimmerSkeletonCard(),
                      );
                    }

                    if (empState is EmployeeLoading) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        itemBuilder: (_, __) => const ShimmerSkeletonCard(),
                      );
                    }

                    if (empState is EmployeeError) {
                      return ErrorStateView(
                        errorMessage: empState.message,
                        onRetry: () =>
                            context.read<EmployeeCubit>().load(currentSite.id),
                      );
                    }

                    final loaded = empState as EmployeeLoaded;
                    if (loaded.employees.isEmpty) {
                      return EmptyStateView(
                        icon: Icons.people_outline,
                        title: 'No Enrolled Personnel',
                        description:
                            'Zero mock mode active. Enroll staff for ${currentSite.code} using the button above.',
                        actionLabel: 'REFRESH',
                        onAction: () =>
                            context.read<EmployeeCubit>().load(currentSite.id),
                      );
                    }

                    return _buildTable(context, currentSite, loaded);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Site site) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Employees & Live Presence',
                      style: AppTypography.titleLarge),
                  AppSpacing.hGap8,
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      borderRadius: AppSpacing.roundedXs,
                      border: Border.all(color: AppColors.borderline),
                    ),
                    child: Text(
                      site.code,
                      style: AppTypography.tabularMonoSmall.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.vGap4,
              const Text(
                'Authorized ONNX identity matching: who was detected, on which camera, and in which zone.',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
        Row(
          children: [
            AppButton(
              label: '+ ENROLL EMPLOYEE',
              variant: ButtonVariant.primary,
              onPressed: () => _showEnrollDialog(context, site.id),
            ),
            AppSpacing.hGap8,
            AppButton(
              label: 'IMPORT CSV',
              variant: ButtonVariant.outlined,
              onPressed: () => _showImportDialog(context, site.id),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context, Site site, EmployeeLoaded loaded) {
    final presenceMap = <String, EmployeePresence>{};
    for (final p in loaded.presence) {
      presenceMap[p.employeeId] = p;
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(bottom: BorderSide(color: AppColors.borderline)),
            ),
            child: const Row(
              children: [
                Expanded(
                    flex: 2, child: Text('EMPLOYEE ID', style: _headerStyle)),
                Expanded(flex: 3, child: Text('NAME', style: _headerStyle)),
                Expanded(
                    flex: 2, child: Text('DEPARTMENT', style: _headerStyle)),
                Expanded(
                    flex: 3,
                    child: Text('LAST SEEN (WHERE)', style: _headerStyle)),
                Expanded(
                    flex: 2, child: Text('MATCH CONF.', style: _headerStyle)),
                Expanded(flex: 2, child: Text('SOURCE', style: _headerStyle)),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: loaded.employees.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.borderline),
            itemBuilder: (context, index) {
              final emp = loaded.employees[index];
              final pres = presenceMap[emp.employeeId];
              final whereText = pres != null
                  ? '${pres.cameraId} · ${pres.zoneId ?? "General"}'
                  : '—';
              final confText = pres != null
                  ? '${(pres.confidence * 100).toStringAsFixed(1)}%'
                  : '—';

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        emp.employeeId,
                        style: AppTypography.tabularMonoSmall.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(emp.fullName,
                          style: AppTypography.bodySmall
                              .copyWith(fontWeight: FontWeight.w500)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(emp.department,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.muted)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          if (pres != null) ...[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: AppColors.emerald,
                                  shape: BoxShape.circle),
                            ),
                            AppSpacing.hGap6,
                          ],
                          Expanded(
                            child: Text(
                              whereText,
                              style: AppTypography.tabularMonoSmall.copyWith(
                                color: pres != null
                                    ? AppColors.ink
                                    : AppColors.dim,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        confText,
                        style: AppTypography.tabularMonoSmall.copyWith(
                          color:
                              pres != null ? AppColors.emerald : AppColors.dim,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.elevated,
                          borderRadius: AppSpacing.roundedXs,
                          border: Border.all(color: AppColors.borderline),
                        ),
                        child: Text(
                          emp.sourceType,
                          style: AppTypography.tabularMonoSmall
                              .copyWith(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    color: AppColors.muted,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    fontFamily: 'JetBrains Mono',
    letterSpacing: 0.8,
  );
}
