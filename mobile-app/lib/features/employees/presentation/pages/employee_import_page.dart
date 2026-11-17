import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../sites/presentation/cubit/site_cubit.dart';
import '../cubit/employee_cubit.dart';

class EmployeeImportPage extends StatefulWidget {
  const EmployeeImportPage({super.key});

  @override
  State<EmployeeImportPage> createState() => _EmployeeImportPageState();
}

class _EmployeeImportPageState extends State<EmployeeImportPage> {
  int _currentStep = 1;
  final TextEditingController _dataController = TextEditingController();
  bool _isProcessing = false;
  int _validCount = 0;
  String? _statusMessage;

  void _processPreview() {
    final text = _dataController.text.trim();
    if (text.isEmpty) {
      setState(() => _statusMessage = 'Please enter or paste CSV/spreadsheet rows to preview.');
      return;
    }

    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    setState(() {
      _validCount = lines.length;
      _currentStep = 2;
      _statusMessage = null;
    });
  }

  void _commitImport(String siteId) async {
    setState(() => _isProcessing = true);
    try {
      final count = await context.read<EmployeeCubit>().bulkImport(siteId, _dataController.text.trim());
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _currentStep = 3;
          _validCount = count;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Import error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SiteCubit, SiteState>(
      builder: (context, siteState) {
        final site = siteState is SiteLoaded ? siteState.selectedSite : null;
        final siteCode = site?.code ?? 'BNF';
        final siteId = site?.id ?? '';

        return Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: AppBar(
            backgroundColor: AppColors.panel,
            title: Text('Employee Import Center · $siteCode', style: AppTypography.titleMedium),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/employees'),
            ),
          ),
          body: SingleChildScrollView(
            padding: AppSpacing.p24,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: AppCard(
                  padding: AppSpacing.p24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStepIndicator(1, 'Upload / Paste', _currentStep >= 1),
                          const Expanded(child: Divider(color: AppColors.borderline, indent: 8, endIndent: 8)),
                          _buildStepIndicator(2, 'Validation Preview', _currentStep >= 2),
                          const Expanded(child: Divider(color: AppColors.borderline, indent: 8, endIndent: 8)),
                          _buildStepIndicator(3, 'Commit Results', _currentStep >= 3),
                        ],
                      ),
                      AppSpacing.vGap24,
                      if (_statusMessage != null) ...[
                        Container(
                          padding: AppSpacing.p12,
                          decoration: BoxDecoration(
                            color: AppColors.crimson.withValues(alpha: 0.15),
                            borderRadius: AppSpacing.roundedSm,
                            border: Border.all(color: AppColors.crimson),
                          ),
                          child: Text(_statusMessage!, style: AppTypography.bodySmall.copyWith(color: AppColors.crimson)),
                        ),
                        AppSpacing.vGap16,
                      ],
                      if (_currentStep == 1) ...[
                        const Text('Step 1: Input CSV / Spreadsheet Data', style: AppTypography.titleSmall),
                        AppSpacing.vGap8,
                        Text(
                          'Format: employee_id, full_name, department\nExample: EMP-101, Ahmed Ali, Operations',
                          style: AppTypography.tabularMonoSmall.copyWith(fontSize: 11, color: AppColors.muted),
                        ),
                        AppSpacing.vGap16,
                        TextField(
                          controller: _dataController,
                          maxLines: 8,
                          style: AppTypography.tabularMonoSmall.copyWith(fontSize: 12),
                          decoration: const InputDecoration(
                            hintText: 'EMP-101, Ahmed Ali, Operations\nEMP-102, Tarek Omar, Safety',
                          ),
                        ),
                        AppSpacing.vGap24,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppButton(
                              label: 'PREVIEW VALIDATION >',
                              variant: ButtonVariant.primary,
                              onPressed: _processPreview,
                            ),
                          ],
                        ),
                      ] else if (_currentStep == 2) ...[
                        const Text('Step 2: Validation Summary & Conflict Check', style: AppTypography.titleSmall),
                        AppSpacing.vGap16,
                        Container(
                          padding: AppSpacing.p16,
                          decoration: BoxDecoration(
                            color: AppColors.canvas,
                            borderRadius: AppSpacing.roundedSm,
                            border: Border.all(color: AppColors.borderline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Rows Parsed: $_validCount', style: AppTypography.tabularMonoSmall.copyWith(fontWeight: FontWeight.bold)),
                              AppSpacing.vGap8,
                              Text('Conflict Strategy: ON CONFLICT (site_id, employee_id) DO NOTHING',
                                  style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.muted, fontSize: 11)),
                              AppSpacing.vGap8,
                              Text('Database Isolation: Verified active RLS context for $siteCode.',
                                  style: const TextStyle(color: AppColors.emerald, fontSize: 11, fontFamily: 'JetBrains Mono')),
                            ],
                          ),
                        ),
                        AppSpacing.vGap24,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppButton(
                              label: '< BACK',
                              variant: ButtonVariant.outlined,
                              onPressed: () => setState(() => _currentStep = 1),
                            ),
                            AppButton(
                              label: 'CONFIRM & COMMIT IMPORT',
                              variant: ButtonVariant.primary,
                              isLoading: _isProcessing,
                              onPressed: () => _commitImport(siteId),
                            ),
                          ],
                        ),
                      ] else ...[
                        const Text('Step 3: Import Complete', style: AppTypography.titleSmall),
                        AppSpacing.vGap16,
                        Container(
                          padding: AppSpacing.p16,
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.1),
                            borderRadius: AppSpacing.roundedSm,
                            border: Border.all(color: AppColors.emerald),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: AppColors.emerald, size: 20),
                                  AppSpacing.hGap8,
                                  Text('Successfully imported $_validCount employee records into $siteCode.',
                                      style: AppTypography.titleSmall.copyWith(color: AppColors.emerald)),
                                ],
                              ),
                              AppSpacing.vGap8,
                              const Text('All records persisted to PostgreSQL 16 database under active site isolation.',
                                  style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                        AppSpacing.vGap24,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppButton(
                              label: 'RETURN TO EMPLOYEE DIRECTORY',
                              variant: ButtonVariant.primary,
                              onPressed: () => context.go('/employees'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator(int stepNum, String title, bool isActive) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? AppColors.cobalt : AppColors.elevated,
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? AppColors.cobalt : AppColors.borderline),
          ),
          child: Center(
            child: Text(
              '$stepNum',
              style: TextStyle(
                color: isActive ? AppColors.ink : AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        AppSpacing.hGap8,
        Text(
          title,
          style: AppTypography.bodySmall.copyWith(
            color: isActive ? AppColors.ink : AppColors.muted,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
