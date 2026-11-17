import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/employee_cubit.dart';
import '../cubits/site_cubit.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/shimmer_skeleton_card.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() {
    final siteState = context.read<SiteCubit>().state;
    if (siteState is SiteLoaded) {
      context.read<EmployeeCubit>().load(siteState.selectedSite.id);
    }
  }

  void _showEnrollDialog(BuildContext context, String siteId) {
    final idController = TextEditingController();
    final nameController = TextEditingController();
    String department = 'OPERATIONS';

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Enroll Employee Identity'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: 'Employee ID *',
                  hintText: 'e.g. EMP-1042',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'e.g. Tarek Mahmoud',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: department,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'OPERATIONS', child: Text('Operations')),
                  DropdownMenuItem(value: 'MAINTENANCE', child: Text('Maintenance')),
                  DropdownMenuItem(value: 'SECURITY', child: Text('Security')),
                  DropdownMenuItem(value: 'SAFETY', child: Text('Safety & EHS')),
                  DropdownMenuItem(value: 'LOGISTICS', child: Text('Logistics')),
                ],
                onChanged: (val) {
                  if (val != null) department = val;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = idController.text.trim();
              final name = nameController.text.trim();
              if (id.isEmpty || name.isEmpty) return;

              final messenger = ScaffoldMessenger.of(context);
              final cubit = context.read<EmployeeCubit>();
              Navigator.pop(dialogCtx);
              try {
                await cubit.enrollEmployee(siteId, {
                  'employee_id': id,
                  'full_name': name,
                  'department': department,
                  'source_type': 'MANUAL_UPLOAD',
                });
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Employee identity enrolled with 512-d feature vector'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Enrollment failed: $e'), backgroundColor: AppTheme.sev1Red),
                );
              }
            },
            child: const Text('Enroll'),
          ),
        ],
      ),
    );
  }

  void _showBulkImportDialog(BuildContext context, String siteId) {
    final csvController = TextEditingController(
      text: 'employee_id,full_name,department\nEMP-101,Karim Nabil,OPERATIONS\nEMP-102,Hossam Samir,SAFETY\nEMP-103,Mona Gamal,LOGISTICS',
    );

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Bulk Import Employees (CSV)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste CSV text with headers:\nemployee_id,full_name,department',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: csvController,
                maxLines: 8,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'EMP-01,Name,DEPT',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final csv = csvController.text.trim();
              if (csv.isEmpty) return;

              final messenger = ScaffoldMessenger.of(context);
              final cubit = context.read<EmployeeCubit>();
              Navigator.pop(dialogCtx);
              try {
                final count = await cubit.bulkImport(siteId, csv);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Successfully imported $count employee identities'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Import failed: $e'), backgroundColor: AppTheme.sev1Red),
                );
              }
            },
            child: const Text('Import CSV'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final siteState = context.watch<SiteCubit>().state;
    final currentSite = siteState is SiteLoaded ? siteState.selectedSite : null;

    if (currentSite == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Personnel Directory')),
        body: const Center(child: Text('Please select an active site first')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Personnel & Presence (${currentSite.code})'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryTeal,
          tabs: const [
            Tab(icon: Icon(Icons.radar_outlined), text: 'Who & Where'),
            Tab(icon: Icon(Icons.badge_outlined), text: 'Enrolled Directory'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh Presence',
          ),
        ],
      ),
      body: BlocBuilder<EmployeeCubit, EmployeeState>(
        builder: (context, state) {
          if (state is EmployeeLoading) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 4,
              itemBuilder: (_, __) => const ShimmerSkeletonCard(),
            );
          }

          if (state is EmployeeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.sev1Red),
                  const SizedBox(height: 12),
                  Text(state.message, style: const TextStyle(color: Colors.redAccent)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _refresh, child: const Text('Retry')),
                ],
              ),
            );
          }

          final employees = state is EmployeeLoaded ? state.employees : <Employee>[];
          final presence = state is EmployeeLoaded ? state.presence : <EmployeePresence>[];

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: "Who & Where" Presence
              presence.isEmpty
                  ? EmptyStateView(
                      icon: Icons.person_search_outlined,
                      title: 'No Personnel Currently Detected',
                      message: 'AI worker will stream matches once employees enter camera field-of-view.',
                      actionLabel: 'Refresh Live State',
                      onAction: _refresh,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: presence.length,
                      itemBuilder: (ctx, i) {
                        final p = presence[i];
                        return Card(
                          color: AppTheme.surface,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.successGreen.withValues(alpha: 0.2),
                              child: const Icon(Icons.verified_user, color: AppTheme.successGreen),
                            ),
                            title: Text(p.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('${p.employeeId} • ${p.department}', style: TextStyle(color: Colors.grey.shade400)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.videocam_outlined, size: 14, color: AppTheme.sev3Blue),
                                    const SizedBox(width: 4),
                                    Text(p.cameraId, style: const TextStyle(fontSize: 12, color: AppTheme.sev3Blue)),
                                    if (p.zoneId != null && p.zoneId!.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      const Icon(Icons.shield_outlined, size: 14, color: AppTheme.sev2Amber),
                                      const SizedBox(width: 4),
                                      Text(p.zoneId!, style: const TextStyle(fontSize: 12, color: AppTheme.sev2Amber)),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successGreen.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${(p.confidence * 100).toInt()}% Match',
                                    style: const TextStyle(fontSize: 11, color: AppTheme.successGreen, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${p.lastSeenAt.hour.toString().padLeft(2, '0')}:${p.lastSeenAt.minute.toString().padLeft(2, '0')}:${p.lastSeenAt.second.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

              // Tab 2: Enrolled Directory
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showEnrollDialog(context, currentSite.id),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Enroll Single'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryTeal,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showBulkImportDialog(context, currentSite.id),
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Bulk CSV'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: employees.isEmpty
                        ? EmptyStateView(
                            icon: Icons.group_outlined,
                            title: 'No Enrolled Personnel',
                            message: 'Enroll personnel or import CSV to activate real-time identification.',
                            actionLabel: 'Enroll First Employee',
                            onAction: () => _showEnrollDialog(context, currentSite.id),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: employees.length,
                            itemBuilder: (ctx, i) {
                              final e = employees[i];
                              return Card(
                                color: AppTheme.surface,
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey.shade800,
                                    child: Text(
                                      e.fullName.isNotEmpty ? e.fullName[0].toUpperCase() : '?',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(e.fullName),
                                  subtitle: Text('${e.employeeId} • ${e.department}'),
                                  trailing: Chip(
                                    label: Text(
                                      e.sourceType,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    backgroundColor: Colors.grey.shade800,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
