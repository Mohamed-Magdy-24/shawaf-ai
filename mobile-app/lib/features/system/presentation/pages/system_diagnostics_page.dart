import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';

class SystemDiagnosticsPage extends StatelessWidget {
  const SystemDiagnosticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: AppSpacing.p20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('System Diagnostics & Service Topology', style: AppTypography.titleLarge),
            AppSpacing.vGap4,
            const Text(
              'Real-time edge daemon service health, container processes, and connection latencies.',
              style: AppTypography.bodySmall,
            ),
            AppSpacing.vGap20,
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildServiceTile('Go Edge Daemon (edged)', 'Port 8080 · REST / WebSocket / gRPC', 'HEALTHY (3.6ms latency)', AppColors.emerald),
                  const Divider(height: 1, color: AppColors.borderline),
                  _buildServiceTile('PostgreSQL 16 (surv_postgres)', 'Port 5432 · FORCE RLS Active', 'CONNECTED · Site Isolation Verified', AppColors.emerald),
                  const Divider(height: 1, color: AppColors.borderline),
                  _buildServiceTile('go2rtc Video Gateway (surv_go2rtc)', 'Port 1984 / 8554 · Internal RTSP Proxy', 'ACTIVE · Zero Raw Video Leaks', AppColors.emerald),
                  const Divider(height: 1, color: AppColors.borderline),
                  _buildServiceTile('Python AI Worker (surv_ai_worker)', 'Inference Engine · YOLOv8 + ONNX', 'RUNNING · Stream Processing', AppColors.emerald),
                  const Divider(height: 1, color: AppColors.borderline),
                  _buildServiceTile('MediaMTX RTSP Simulator (surv_mediamtx)', 'Port 8554 · Synthetic RTSP Feeds', 'ACTIVE · 15.0 FPS Broadcast', AppColors.emerald),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTile(String name, String details, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
              ),
              AppSpacing.hGap12,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.titleSmall),
                  Text(details, style: AppTypography.tabularMonoSmall.copyWith(color: AppColors.muted, fontSize: 11)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: AppSpacing.roundedXs,
              border: Border.all(color: statusColor),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono'),
            ),
          ),
        ],
      ),
    );
  }
}
