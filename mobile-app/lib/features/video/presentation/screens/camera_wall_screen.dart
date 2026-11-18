import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/molecules/state_badge.dart';
import '../../../../core/widgets/organisms/state_boundary_builder.dart';
import '../bloc/camera_bloc.dart';
import '../bloc/camera_event.dart';
import '../bloc/camera_state.dart';
import '../widgets/webrtc_viewport.dart';
import 'camera_inspection_screen.dart';

class CameraWallScreen extends StatefulWidget {
  final String siteId;

  const CameraWallScreen({super.key, required this.siteId});

  @override
  State<CameraWallScreen> createState() => _CameraWallScreenState();
}

class _CameraWallScreenState extends State<CameraWallScreen> {
  int _gridColumns = 2; // 1, 2, or 3 columns

  @override
  Widget build(BuildContext context) {
    final isMobile = AppDimensions.isMobile(context);
    final columns = isMobile ? 1 : _gridColumns;

    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CAMERA WALL — ${widget.siteId}', style: AppTypography.heading1),
                Text('Low-Latency WebRTC Stream Matrix', style: AppTypography.caption),
              ],
            ),
            actions: [
              if (!isMobile) ...[
                IconButton(
                  icon: const Icon(Icons.looks_one_outlined),
                  tooltip: '1x1 Focus View',
                  onPressed: () => setState(() => _gridColumns = 1),
                  color: _gridColumns == 1 ? AppColors.statusInfo : AppColors.textSecondary,
                ),
                IconButton(
                  icon: const Icon(Icons.grid_view_outlined),
                  tooltip: '2x2 Matrix',
                  onPressed: () => setState(() => _gridColumns = 2),
                  color: _gridColumns == 2 ? AppColors.statusInfo : AppColors.textSecondary,
                ),
                IconButton(
                  icon: const Icon(Icons.apps_outlined),
                  tooltip: '3x3 Matrix',
                  onPressed: () => setState(() => _gridColumns = 3),
                  color: _gridColumns == 3 ? AppColors.statusInfo : AppColors.textSecondary,
                ),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing16),
                child: Center(child: StateBadge(state: state.uiState)),
              ),
            ],
          ),
          body: StateBoundaryBuilder(
            state: state.uiState,
            onRetry: () {
              context.read<CameraBloc>().add(LoadCameras(widget.siteId));
            },
            contentBuilder: (context) {
              return GridView.builder(
                padding: const EdgeInsets.all(AppDimensions.spacing12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: AppDimensions.spacing12,
                  mainAxisSpacing: AppDimensions.spacing12,
                  childAspectRatio: 16.0 / 9.0,
                ),
                itemCount: state.cameras.length,
                itemBuilder: (context, index) {
                  final camera = state.cameras[index];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CameraInspectionScreen(
                            camera: camera,
                            siteId: widget.siteId,
                          ),
                        ),
                      );
                    },
                    child: WebRtcViewport(
                      camera: camera,
                      showBoundingBoxes: state.showBoundingBoxes,
                      showTelemetryHud: true,
                      onToggleFullscreen: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CameraInspectionScreen(
                              camera: camera,
                              siteId: widget.siteId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
