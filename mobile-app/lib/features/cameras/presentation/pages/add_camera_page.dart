import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../sites/presentation/cubit/site_cubit.dart';
import '../cubit/camera_management_cubit.dart';

class AddCameraPage extends StatefulWidget {
  const AddCameraPage({super.key});

  @override
  State<AddCameraPage> createState() => _AddCameraPageState();
}

class _AddCameraPageState extends State<AddCameraPage> {
  final _nameController = TextEditingController();
  final _hostIpController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fpsController = TextEditingController(text: '15');

  String _vendor = 'HIKVISION';
  bool _isProbing = false;
  Map<String, dynamic>? _probeResult;
  String? _errorMessage;

  void _probeConnection() async {
    final siteCubit = context.read<SiteCubit>();
    if (siteCubit.state is! SiteLoaded) return;
    final siteId = (siteCubit.state as SiteLoaded).selectedSite.id;

    final ip = _hostIpController.text.trim();
    if (ip.isEmpty) {
      setState(() => _errorMessage = 'Please enter an IP address or hostname.');
      return;
    }

    setState(() {
      _isProbing = true;
      _errorMessage = null;
      _probeResult = null;
    });

    final port = int.tryParse(_portController.text.trim()) ?? 554;
    final payload = {
      'vendor': _vendor,
      'host_ip': ip,
      'port': port,
      'username': _usernameController.text.trim(),
      'password': _passwordController.text.trim(),
      'channel': 1,
      'stream_subtype': 1,
    };

    final res = await context
        .read<CameraManagementCubit>()
        .testConnection(siteId, payload);

    if (mounted) {
      setState(() {
        _isProbing = false;
        _probeResult = res;
      });
    }
  }

  void _saveCamera() async {
    final siteCubit = context.read<SiteCubit>();
    if (siteCubit.state is! SiteLoaded) return;
    final siteId = (siteCubit.state as SiteLoaded).selectedSite.id;

    final name = _nameController.text.trim();
    final ip = _hostIpController.text.trim();
    if (name.isEmpty || ip.isEmpty) {
      setState(() => _errorMessage = 'Camera Name and IP are required.');
      return;
    }

    final port = int.tryParse(_portController.text.trim()) ?? 554;
    final user = _usernameController.text.trim();
    final pass = _passwordController.text.trim();
    final fps = int.tryParse(_fpsController.text.trim()) ?? 15;

    // Construct standard RTSP URL based on vendor preset
    String rtspUrl;
    final authPart = user.isNotEmpty ? '$user:$pass@' : '';
    if (_vendor == 'HIKVISION') {
      rtspUrl = 'rtsp://$authPart$ip:$port/Streaming/Channels/101';
    } else if (_vendor == 'DAHUA') {
      rtspUrl = 'rtsp://$authPart$ip:$port/cam/realmonitor?channel=1&subtype=0';
    } else {
      rtspUrl = 'rtsp://$authPart$ip:$port/live/ch0';
    }

    try {
      await context.read<CameraManagementCubit>().addCamera(
            siteId,
            name: name,
            rtspUrl: rtspUrl,
            fpsTarget: fps,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Camera onboarded successfully'),
              backgroundColor: AppColors.emerald),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Failed to register camera: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.panel,
        title:
            const Text('Add NVR / IP Camera', style: AppTypography.titleMedium),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.p24,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: AppCard(
              padding: AppSpacing.p24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.elevated,
                          borderRadius: AppSpacing.roundedXs,
                          border: Border.all(color: AppColors.borderline),
                        ),
                        child: const Icon(Icons.videocam_outlined,
                            color: AppColors.cobalt, size: 20),
                      ),
                      AppSpacing.hGap12,
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Network Camera Configuration',
                              style: AppTypography.titleMedium),
                          Text(
                              'All inputs start empty. Encrypted at rest via AES-256-GCM.',
                              style: AppTypography.bodySmall),
                        ],
                      ),
                    ],
                  ),
                  AppSpacing.vGap24,
                  if (_errorMessage != null) ...[
                    Container(
                      padding: AppSpacing.p12,
                      decoration: BoxDecoration(
                        color: AppColors.crimson.withValues(alpha: 0.15),
                        borderRadius: AppSpacing.roundedSm,
                        border: Border.all(color: AppColors.crimson),
                      ),
                      child: Text(_errorMessage!,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.crimson)),
                    ),
                    AppSpacing.vGap16,
                  ],
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _nameController,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.ink),
                          decoration: const InputDecoration(
                            labelText: 'Camera Name *',
                            hintText: 'e.g. Gate 1 Entry',
                          ),
                        ),
                      ),
                      AppSpacing.hGap12,
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: _vendor,
                          dropdownColor: AppColors.panel,
                          style: AppTypography.tabularMonoSmall
                              .copyWith(color: AppColors.ink),
                          decoration:
                              const InputDecoration(labelText: 'Vendor Preset'),
                          items: const [
                            DropdownMenuItem(
                                value: 'HIKVISION', child: Text('Hikvision')),
                            DropdownMenuItem(
                                value: 'DAHUA', child: Text('Dahua')),
                            DropdownMenuItem(
                                value: 'TIANDY', child: Text('Tiandy')),
                            DropdownMenuItem(
                                value: 'RTSP', child: Text('Generic RTSP')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _vendor = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vGap16,
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _hostIpController,
                          style: AppTypography.tabularMonoSmall
                              .copyWith(color: AppColors.ink),
                          decoration: const InputDecoration(
                            labelText: 'Device IP / Host *',
                            hintText: 'e.g. 192.168.1.100',
                          ),
                        ),
                      ),
                      AppSpacing.hGap12,
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _portController,
                          style: AppTypography.tabularMonoSmall
                              .copyWith(color: AppColors.ink),
                          decoration: const InputDecoration(
                            labelText: 'RTSP Port',
                            hintText: '554',
                          ),
                        ),
                      ),
                      AppSpacing.hGap12,
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _fpsController,
                          style: AppTypography.tabularMonoSmall
                              .copyWith(color: AppColors.ink),
                          decoration: const InputDecoration(
                            labelText: 'FPS Target',
                            hintText: '15',
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vGap16,
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _usernameController,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.ink),
                          decoration: const InputDecoration(
                            labelText: 'RTSP Username',
                            hintText: 'admin',
                          ),
                        ),
                      ),
                      AppSpacing.hGap12,
                      Expanded(
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.ink),
                          decoration: const InputDecoration(
                            labelText: 'RTSP Password',
                            hintText: 'Encrypted at rest',
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vGap24,
                  _buildDiagnosticProbeSection(),
                  AppSpacing.vGap24,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel',
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.muted)),
                      ),
                      AppSpacing.hGap12,
                      AppButton(
                        label: 'SAVE & START AI INFERENCE',
                        variant: ButtonVariant.primary,
                        onPressed: _saveCamera,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticProbeSection() {
    return Container(
      padding: AppSpacing.p16,
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: AppSpacing.roundedSm,
        border: Border.all(color: AppColors.borderline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Multi-Stage Diagnostic Probe',
                      style: AppTypography.titleSmall),
                  Text(
                      'Verifies DNS, TCP 554, RTSP handshake, SDP and frame decoding.',
                      style: AppTypography.tabularMonoSmall
                          .copyWith(fontSize: 10, color: AppColors.muted)),
                ],
              ),
              AppButton(
                label: _isProbing ? 'PROBING...' : 'TEST CONNECTION',
                isLoading: _isProbing,
                variant: ButtonVariant.outlined,
                onPressed: _isProbing ? null : _probeConnection,
              ),
            ],
          ),
          if (_probeResult != null) ...[
            AppSpacing.vGap16,
            _buildProbeStagesTable(_probeResult!),
          ],
        ],
      ),
    );
  }

  Widget _buildProbeStagesTable(Map<String, dynamic> result) {
    final stages = result['stages'] as Map<String, dynamic>? ?? {};
    final failedStage = result['failed_stage'];
    final errorMsg = result['error_message'];
    final latency = result['probe_latency_ms'] ?? 0;

    final stageList = [
      {'key': 'dns_resolved', 'label': 'Stage 1: DNS Resolution'},
      {'key': 'tcp_connected', 'label': 'Stage 2: TCP Handshake (Port 554)'},
      {'key': 'rtsp_auth_ok', 'label': 'Stage 3: RTSP Digest Authentication'},
      {'key': 'stream_described', 'label': 'Stage 4: SDP Stream Description'},
      {'key': 'frame_decoded', 'label': 'Stage 5: First Video Frame Decoded'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Probe Latency: ${latency}ms',
                style: AppTypography.tabularMonoSmall
                    .copyWith(color: AppColors.cobalt)),
            Text(
              failedStage == null
                  ? 'ALL STAGES VERIFIED'
                  : 'FAILED AT: $failedStage',
              style: AppTypography.tabularMonoSmall.copyWith(
                color:
                    failedStage == null ? AppColors.emerald : AppColors.crimson,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        AppSpacing.vGap8,
        ...stageList.map((s) {
          final isOk = stages[s['key']] == true;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Icon(
                  isOk ? Icons.check_circle_outline : Icons.cancel_outlined,
                  size: 14,
                  color: isOk ? AppColors.emerald : AppColors.crimson,
                ),
                AppSpacing.hGap8,
                Text(s['label']!,
                    style:
                        AppTypography.tabularMonoSmall.copyWith(fontSize: 11)),
              ],
            ),
          );
        }),
        if (errorMsg != null && errorMsg.toString().isNotEmpty) ...[
          AppSpacing.vGap8,
          Text('Error: $errorMsg',
              style: AppTypography.tabularMonoSmall
                  .copyWith(color: AppColors.crimson, fontSize: 11)),
        ],
      ],
    );
  }
}
