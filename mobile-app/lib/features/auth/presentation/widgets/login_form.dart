import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSubmit;

  const LoginForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.isLoading,
    this.errorMessage,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (errorMessage != null && errorMessage!.isNotEmpty) ...[
          Container(
            padding: AppSpacing.p12,
            decoration: BoxDecoration(
              color: AppColors.sev1RedGlow,
              borderRadius: AppSpacing.roundedSm,
              border: Border.all(color: AppColors.sev1Red, width: 1.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.sev1Red, size: 18),
                AppSpacing.hGap8,
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.sev1Red),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGap16,
        ],
        TextField(
          controller: usernameController,
          enabled: !isLoading,
          decoration: const InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
          ),
        ),
        AppSpacing.vGap16,
        TextField(
          controller: passwordController,
          obscureText: true,
          enabled: !isLoading,
          onSubmitted: (_) => onSubmit(),
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary),
          ),
        ),
        AppSpacing.vGap24,
        AppButton(
          label: 'SIGN IN',
          icon: Icons.login,
          isLoading: isLoading,
          onPressed: onSubmit,
        ),
        AppSpacing.vGap12,
        OutlinedButton.icon(
          icon: const Icon(Icons.flash_on, size: 16, color: AppColors.cobalt),
          label: Text(
            'QUICK SIGN IN (admin_corp)',
            style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.cobalt, fontWeight: FontWeight.bold),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.borderline),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: const RoundedRectangleBorder(borderRadius: AppSpacing.roundedSm),
          ),
          onPressed: isLoading
              ? null
              : () {
                  usernameController.text = 'admin_corp';
                  passwordController.text = 'AdminPassword123!';
                  onSubmit();
                },
        ),
      ],
    );
  }
}
