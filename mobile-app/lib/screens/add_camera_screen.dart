import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/camera_management_cubit.dart';
import '../cubits/site_cubit.dart';
import '../theme/app_theme.dart';

class AddCameraScreen extends StatefulWidget {
  const AddCameraScreen({super.key});

  @override
  State<AddCameraScreen> createState() => _AddCameraScreenState();
}

class _AddCameraScreenState extends State<AddCameraScreen> {
  final _formKey = GlobalKey<FormState>();

  String _vendor = 'HIKVISION';
  final _nameController = TextEditingController();
  final _hostIpController = TextEditingController();
  final _portController = TextEditingController(text: '554');
  final _channelController = TextEditingController(text: '1');
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController();
  final _customPathController = TextEditingController();
  final _rtspUrlController = TextEditingController();

  bool _manualUrl = false;
  bool _testingConnection = false;
  Map<String, dynamic>? _probeResult;
  String? _probeError;

  final List<Offset> _zonePoints = [];

  @override
  void dispose() {
    _nameController.dispose();
    _hostIpController.dispose();
    _portController.dispose();
    _channelController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _customPathController.dispose();
    _rtspUrlController.dispose();
    super.dispose();
  }

  String _buildUrl() {
    if (_manualUrl && _rtspUrlController.text.isNotEmpty) {
      return _rtspUrlController.text.trim();
    }
    final ip = _hostIpController.text.trim();
    final port = int.tryParse(_portController.text) ?? 554;
    final ch = int.tryParse(_channelController.text) ?? 1;
    final user = _usernameController.text.trim();
    final pass = _passwordController.text;

    final userPart = user.isNotEmpty ? '$user:$pass@' : '';

    switch (_vendor) {
      case 'HIKVISION':
        return 'rtsp://$userPart$ip:$port/Streaming/Channels/${ch}02';
      case 'DAHUA':
        return 'rtsp://$userPart$ip:$port/cam/realmonitor?channel=$ch&subtype=1';
      case 'TIANDY':
        return 'rtsp://$userPart$ip:$port/video2';
      default:
        final path = _customPathController.text.trim().isNotEmpty
            ? _customPathController.text.trim()
            : 'live/ch$ch';
        return 'rtsp://$userPart$ip:$port/$path';
    }
  }

  Future<void> _testConnection(String siteId) async {
    setState(() {
      _testingConnection = true;
      _probeResult = null;
      _probeError = null;
    });

    try {
      final payload = <String, dynamic>{
        'vendor': _vendor,
        'host_ip': _hostIpController.text.trim(),
        'port': int.tryParse(_portController.text) ?? 554,
        'channel': int.tryParse(_channelController.text) ?? 1,
        'username': _usernameController.text.trim(),
        'password': _passwordController.text,
        'custom_path': _customPathController.text.trim(),
        if (_manualUrl) 'rtsp_url': _rtspUrlController.text.trim(),
      };

      final cubit = context.read<CameraManagementCubit>();
      final res = await cubit.testConnection(siteId, payload);
      setState(() {
        _probeResult = res;
      });
    } catch (e) {
      setState(() {
        _probeError = e.toString();
      });
    } finally {
      setState(() {
        _testingConnection = false;
      });
    }
  }

  Future<void> _saveCamera(String siteId) async {
    if (!_formKey.currentState!.validate()) return;

    final rtspUrl = _buildUrl();
    final name = _nameController.text.trim();

    List<Map<String, dynamic>>? zones;
    if (_zonePoints.length >= 3) {
      zones = [
        {
          'name': 'Primary Safety Zone',
          'zone_type': 'RESTRICTED_AREA',
          'severity': 'SEV1',
          'polygon': _zonePoints.map((pt) => [pt.dx, pt.dy]).toList(),
        }
      ];
    }

    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      final cubit = context.read<CameraManagementCubit>();
      await cubit.addCamera(
        siteId,
        name: name,
        rtspUrl: rtspUrl,
        fpsTarget: 15,
        zones: zones,
      );

      messenger.showSnackBar(
        SnackBar(
          content: Text('Camera "$name" registered successfully'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      nav.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to save camera: $e'),
          backgroundColor: AppTheme.sev1Red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final siteState = context.watch<SiteCubit>().state;
    final currentSite = siteState is SiteLoaded ? siteState.selectedSite : null;

    if (currentSite == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Camera')),
        body: const Center(child: Text('Please select an active site first')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Onboard Camera (${currentSite.code})'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: AppTheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'On-Premises IP Camera Setup',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Registers sub-stream to Shawaf AI edge daemon with zero raw video leaving site boundaries.',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Camera Name *',
                  hintText: 'e.g. BNF Gate 1 North',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.videocam_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Camera name is required' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _vendor,
                decoration: const InputDecoration(
                  labelText: 'Appliance Vendor Preset',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.memory),
                ),
                items: const [
                  DropdownMenuItem(value: 'HIKVISION', child: Text('Hikvision (Channel Sub-stream)')),
                  DropdownMenuItem(value: 'DAHUA', child: Text('Dahua (Subtype 1 Sub-stream)')),
                  DropdownMenuItem(value: 'TIANDY', child: Text('Tiandy (/video2)')),
                  DropdownMenuItem(value: 'GENERIC', child: Text('Generic ONVIF / RTSP')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _vendor = val);
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _hostIpController,
                      decoration: const InputDecoration(
                        labelText: 'Host IP Address *',
                        hintText: '192.168.1.100',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lan_outlined),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Host IP required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _portController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'RTSP Port',
                        hintText: '554',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _channelController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Channel Number',
                  hintText: '1',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        hintText: 'admin',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Direct Custom RTSP URL'),
                subtitle: const Text('Override preset parameters with a direct connection string'),
                value: _manualUrl,
                onChanged: (val) => setState(() => _manualUrl = val),
              ),
              if (_manualUrl) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _rtspUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Direct RTSP URL',
                    hintText: 'rtsp://user:pass@host:554/stream',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _testingConnection ? null : () => _testConnection(currentSite.id),
                icon: _testingConnection
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.network_check),
                label: Text(_testingConnection ? 'Testing Connection...' : 'Test Appliance Reachability'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              if (_probeResult != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _probeResult!['reachable'] == true
                        ? AppTheme.successGreen.withValues(alpha: 0.15)
                        : AppTheme.sev1Red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _probeResult!['reachable'] == true ? AppTheme.successGreen : AppTheme.sev1Red,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _probeResult!['reachable'] == true ? Icons.check_circle : Icons.error,
                        color: _probeResult!['reachable'] == true ? AppTheme.successGreen : AppTheme.sev1Red,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _probeResult!['reachable'] == true
                                  ? 'Stream Reachable (${_probeResult!['latency_ms']} ms)'
                                  : 'Stream Unreachable',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (_probeResult!['sanitized_url'] != null)
                              Text(
                                '${_probeResult!['sanitized_url']}',
                                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                              ),
                            if (_probeResult!['error'] != null && (_probeResult!['error'] as String).isNotEmpty)
                              Text(
                                '${_probeResult!['error']}',
                                style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_probeError != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Probe error: $_probeError',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ],
              const SizedBox(height: 24),

              const Text(
                'Safety Exclusion Zone (Optional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap canvas to define normalized polygon boundary (min 3 points).',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 12),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: GestureDetector(
                  onTapUp: (details) {
                    final box = context.findRenderObject() as RenderBox?;
                    if (box != null) {
                      final local = details.localPosition;
                      setState(() {
                        _zonePoints.add(Offset(
                          (local.dx / 320).clamp(0.0, 1.0),
                          (local.dy / 180).clamp(0.0, 1.0),
                        ));
                      });
                    }
                  },
                  child: CustomPaint(
                    painter: _ZoneEditorPainter(_zonePoints),
                    child: Center(
                      child: _zonePoints.isEmpty
                          ? Text(
                              'Tap here to plot polygon points',
                              style: TextStyle(color: Colors.grey.shade500),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              if (_zonePoints.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_zonePoints.length} points defined', style: const TextStyle(fontSize: 12)),
                    TextButton(
                      onPressed: () => setState(() => _zonePoints.clear()),
                      child: const Text('Clear Points', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () => _saveCamera(currentSite.id),
                icon: const Icon(Icons.save),
                label: const Text('Register Camera Appliance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoneEditorPainter extends CustomPainter {
  final List<Offset> points;
  _ZoneEditorPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paintStroke = Paint()
      ..color = AppTheme.sev2Amber
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final paintFill = Paint()
      ..color = AppTheme.sev2Amber.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final paintDot = Paint()
      ..color = AppTheme.sev1Red
      ..style = PaintingStyle.fill;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final p = Offset(points[i].dx * size.width, points[i].dy * size.height);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawCircle(p, 4.0, paintDot);
    }

    if (points.length >= 3) {
      path.close();
      canvas.drawPath(path, paintFill);
    }
    canvas.drawPath(path, paintStroke);
  }

  @override
  bool shouldRepaint(covariant _ZoneEditorPainter oldDelegate) => true;
}
