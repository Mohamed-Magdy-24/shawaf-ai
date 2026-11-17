import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth_cubit.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticated) {
                  // Navigation handled by parent or BlocBuilder in App root
                }
              },
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                final errorMessage = state is AuthUnauthenticated ? state.errorMessage : null;

                return Card(
                  color: AppTheme.surface,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: AppTheme.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.primaryTeal),
                            ),
                            child: const Icon(
                              Icons.security,
                              size: 40,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'SHAWAF AI',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Industrial Safety & Edge Surveillance',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.sev1Red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.sev1Red.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppTheme.sev1Red, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: const TextStyle(color: AppTheme.sev1Red, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Operator / Manager Username',
                            prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSecondary),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: AppTheme.surfaceLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textSecondary),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: AppTheme.surfaceLight,
                          ),
                          onSubmitted: (_) {
                            if (!isLoading) {
                              context.read<AuthCubit>().login(
                                    _usernameController.text,
                                    _passwordController.text,
                                  );
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<AuthCubit>().login(
                                        _usernameController.text,
                                        _passwordController.text,
                                      );
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF042F2E)),
                                )
                              : const Text('AUTHENTICATE'),
                        ),
                      ],
                    ),
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
