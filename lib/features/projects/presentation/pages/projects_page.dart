import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/media_url_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';
import 'create_project_sheet.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  int _tabIndex = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _projects = [];
  List<Map<String, dynamic>> _proposals = [];
  final Map<String, List<Map<String, dynamic>>> _proposalsByProject = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final api = sl<ApiService>();
      var projects = <Map<String, dynamic>>[];
      try {
        final res = await api.getMyProjectsWithProposals();
        final data = res.data['data'] as List<dynamic>? ?? [];
        projects = data
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } catch (_) {}
      var proposals = <Map<String, dynamic>>[];
      try {
        final res = await api.getMyProposals();
        final data = res.data['data'] as List<dynamic>? ?? [];
        proposals = data
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _projects = projects;
        _proposals = proposals;
        for (final project in projects) {
          final props = project['proposals'] as List<dynamic>? ?? [];
          _proposalsByProject[project['_id']?.toString() ?? ''] = props
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showCreateSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => const CreateProjectSheet(),
    );
    if (created == true) _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.backgroundAlt,
    appBar: AppBar(
      backgroundColor: context.colors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        context.tr('projects.title'),
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.add_circle_outline,
            color: context.colors.textPrimary,
            size: 26.sp,
          ),
          onPressed: _showCreateSheet,
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _showCreateSheet,
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
    ),
    body: Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: context.colors.chipUnselected,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                _buildTab(context.tr('projects.my'), 0),
                _buildTab(context.tr('projects.proposals'), 1),
              ],
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _tabIndex == 0
                      ? _buildProjectsList()
                      : _buildProposalsList(),
                ),
        ),
      ],
    ),
  );

  Widget _buildTab(String label, int index) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: _tabIndex == index
              ? context.colors.surface
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: _tabIndex == index
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _tabIndex == index
                ? Theme.of(context).colorScheme.primary
                : context.colors.textSecondary,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );

  Widget _buildProjectsList() {
    if (_projects.isEmpty) {
      return _buildEmpty(context.tr('projects.empty'));
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      itemCount: _projects.length,
      itemBuilder: (context, index) => _buildProjectCard(_projects[index]),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    final projectId = project['_id']?.toString() ?? '';
    final proposals = _proposalsByProject[projectId] ?? [];
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project['title']?.toString() ??
                      context.tr('projects.untitled_project'),
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  project['status']?.toString() ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            [
              project['category']?.toString() ?? '',
              project['location']?.toString() ?? '',
            ].where((s) => s.isNotEmpty).join(' \u2022 '),
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            project['description']?.toString() ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            context.tr('projects.budget_label', {
              'amount': _formatBudget(project['budget']),
            }),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            context.tr('projects.proposals_count', {
              'count': '${proposals.length}',
            }),
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (proposals.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Text(
                context.tr('projects.no_proposals_received'),
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
            )
          else
            ...proposals.map(_buildProposalRow),
        ],
      ),
    );
  }

  Widget _buildProposalRow(Map<String, dynamic> proposal) {
    final freelancer = proposal['freelancer'] is Map
        ? Map<String, dynamic>.from(proposal['freelancer'] as Map)
        : <String, dynamic>{};
    final profile = freelancer['profile'] as Map<String, dynamic>? ?? {};
    final avatar = MediaUrlHelper.resolve(profile['avatar'] as String? ?? '');
    final name = '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}'
        .trim();
    final bid = proposal['bidAmount'];
    final status = proposal['status']?.toString() ?? 'Pending';
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14.r,
            backgroundColor: context.colors.surfaceMuted,
            backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
            child: avatar.isEmpty
                ? Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                    size: 14.sp,
                  )
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? context.tr('projects.freelancer') : name,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  bid != null ? '\$$bid' : '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: _statusColor(status).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: _statusColor(status),
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalsList() {
    if (_proposals.isEmpty) {
      return _buildEmpty(context.tr('projects.empty_proposals'));
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      itemCount: _proposals.length,
      itemBuilder: (context, index) {
        final proposal = _proposals[index];
        final project = proposal['project'] is Map
            ? Map<String, dynamic>.from(proposal['project'] as Map)
            : <String, dynamic>{};
        final client = project['client'] is Map
            ? Map<String, dynamic>.from(project['client'] as Map)
            : <String, dynamic>{};
        final clientProfile = client['profile'] as Map<String, dynamic>? ?? {};
        final clientName =
            '${clientProfile['firstName'] ?? ''} ${clientProfile['lastName'] ?? ''}'
                .trim();
        final status = proposal['status']?.toString() ?? 'Pending';
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project['title']?.toString() ??
                          context.tr('projects.untitled_project'),
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _statusColor(status),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                [
                  project['category']?.toString() ?? '',
                  if (clientName.isNotEmpty)
                    context.tr('projects.client_label', {'name': clientName}),
                ].where((s) => s.isNotEmpty).join(' \u2022 '),
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                context.tr('projects.bid_label', {
                  'amount': _formatBudget(proposal['bidAmount']),
                }),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatBudget(Object? budget) {
    if (budget is Map) {
      final min = budget['min']?.toString() ?? '';
      final max = budget['max']?.toString() ?? '';
      return '\$$min - \$$max';
    }
    return budget != null ? '\$$budget' : 'N/A';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return AppColors.successGreen;
      case 'rejected':
        return AppColors.logoutRed;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return AppColors.successGreen;
      default:
        return context.colors.textSecondary;
    }
  }

  Widget _buildEmpty(String message) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: EdgeInsets.all(40.w),
    children: [
      Icon(Icons.folder_open, size: 48.sp, color: context.colors.textHint),
      SizedBox(height: 12.h),
      Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: context.colors.textSecondary, fontSize: 14.sp),
      ),
    ],
  );
}
