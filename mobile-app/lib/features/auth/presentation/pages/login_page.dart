import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../cubit/auth_cubit.dart';
import '../../../sites/presentation/cubit/site_cubit.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  LoginPage({super.key})
      : usernameController = TextEditingController(),
        passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: AppSpacing.p24,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticated) {
                  context.read<SiteCubit>().loadSites();
                  context.go('/overview');
                }
              },
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                final errorMessage = state is AuthUnauthenticated ? state.errorMessage : null;

                return AppCard(
                  padding: AppSpacing.p32,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: AppSpacing.p16,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.security,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                      AppSpacing.vGap16,
                      const Text(
                        'SHAWAF AI',
                        style: AppTypography.headlineMedium,
                      ),
                      AppSpacing.vGap4,
                      Text(
                        'Industrial Safety Operator Console',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      AppSpacing.vGap32,
                      LoginForm(
                        usernameController: usernameController,
                        passwordController: passwordController,
                        isLoading: isLoading,
                        errorMessage: errorMessage,
                        onSubmit: () {
                          context.read<AuthCubit>().login(
                                usernameController.text,
                                passwordController.text,
                              );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
