import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/media_url_helper.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';
import '../manager/jobs_bloc.dart';
import '../widgets/job_result_card.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/usecases/get_jobs_usecase.dart';

class JobSearchResultsPage extends StatefulWidget {
  final String? query;

  const JobSearchResultsPage({super.key, this.query});

  @override
  State<JobSearchResultsPage> createState() => _JobSearchResultsPageState();
}

class _JobSearchResultsPageState extends State<JobSearchResultsPage> {
  late final TextEditingController _searchController;
  String _searchQuery = '';
  String? _activeFilter;

  static const List<String> _filters = [
    'Remote',
    'On-site',
    'Full-time',
    'Part-time',
    'Internship',
  ];

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.query ?? '';
    _searchController = TextEditingController(text: _searchQuery);
  }

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String value) {
    final query = value.trim();
    setState(() => _searchQuery = query);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _dispatch);
  }

  void _applyFilter(String filter) {
    setState(() {
      _activeFilter = _activeFilter == filter ? null : filter;
    });
    _dispatch();
  }

  void _dispatch() {
    final type = _isTypeFilter(_activeFilter) ? _activeFilter : null;
    final workPlace = _isWorkPlaceFilter(_activeFilter) ? _activeFilter : null;
    context.read<JobsBloc>().add(
      GetJobsEvent(search: _searchQuery, type: type, workPlace: workPlace),
    );
  }

  bool _isTypeFilter(String? f) =>
      f == 'Full-time' ||
      f == 'Part-time' ||
      f == 'Contract' ||
      f == 'Internship';
  bool _isWorkPlaceFilter(String? f) =>
      f == 'Remote' || f == 'On-site' || f == 'Hybrid';

  String _filterDisplay(String key) => switch (key) {
    'Remote' => context.tr('remote'),
    'On-site' => context.tr('on_site'),
    'Full-time' => context.tr('full_time'),
    'Part-time' => context.tr('part_time'),
    'Internship' => context.tr('internship'),
    _ => key,
  };

  String _salaryText(JobEntity job) {
    final s = job.salary;
    if (s.min == 0 && s.max == 0) return context.tr('jobs.salary_on_request');
    return '${s.currency} ${s.min.toInt()} - ${s.max.toInt()}';
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        JobsBloc(getJobsUseCase: sl<GetJobsUseCase>())
          ..add(GetJobsEvent(search: _searchQuery)),
    child: Scaffold(
      backgroundColor: context.colors.backgroundAlt,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('jobs'),
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) => Column(
          children: [
            Container(
              color: context.colors.surface,
              padding: EdgeInsets.only(bottom: 16.h),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.colors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onChanged: _submitSearch,
                        style: TextStyle(color: context.colors.textPrimary),
                        decoration: InputDecoration(
                          hintText: context.tr('jobs.search_titles'),
                          hintStyle: TextStyle(
                            color: context.colors.textHint,
                            fontSize: 14.sp,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: context.colors.textHint,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      children: _filters.map(_buildFilterChip).toList(),
                    ),
                  ),
                ],
              ),
            ),
            if (state is JobsLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (state is JobsError)
              Expanded(
                child: Center(
                  child: Text(
                    state.message,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (state is JobsLoaded)
              Expanded(
                child: state.jobs.isEmpty
                    ? _buildEmptyState()
                    : ListView(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        children: state.jobs.map((job) {
                          final salary = _salaryText(job);
                          return JobResultCard(
                            title: job.title,
                            company: job.companyName,
                            location: job.location,
                            logoUrl: MediaUrlHelper.resolve(job.companyLogo),
                            postedTime: job.status,
                            salary: salary,
                            workType: job.type,
                            jobId: job.id,
                            onApply: () async {
                              if (job.id.isEmpty) {
                                UIUtils.showSnackBar(
                                  context: context,
                                  message: context.tr('jobs.apply_failed'),
                                );
                                return;
                              }
                              try {
                                final result = await FilePicker.platform
                                    .pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['pdf', 'doc', 'docx'],
                                    );
                                final path = result?.files.single.path;
                                if (path == null) return;
                                await sl<ApiService>().applyJob(
                                  job.id,
                                  resumePath: path,
                                );
                                if (!context.mounted) return;
                                UIUtils.showSnackBar(
                                  context: context,
                                  message: context.tr('jobs.applied_to', {
                                    'title': job.title,
                                  }),
                                  isError: false,
                                );
                              } catch (_) {
                                if (!context.mounted) return;
                                UIUtils.showSnackBar(
                                  context: context,
                                  message: context.tr('jobs.apply_error'),
                                );
                              }
                            },
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRouter.jobDetails,
                              arguments: job,
                            ),
                          );
                        }).toList(),
                      ),
              )
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      ),
    ),
  );

  Widget _buildFilterChip(String key) {
    final isActive = _activeFilter == key;
    return GestureDetector(
      onTap: () => _applyFilter(key),
      child: Container(
        margin: EdgeInsetsDirectional.only(end: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : context.colors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : context.colors.inputBorder,
          ),
        ),
        child: Text(
          _filterDisplay(key),
          style: TextStyle(
            color: isActive ? Colors.white : context.colors.textPrimary,
            fontSize: 13.sp,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() => Center(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80.sp,
            color: context.colors.textHint,
          ),
          SizedBox(height: 16.h),
          Text(
            _searchQuery.isEmpty
                ? context.tr('jobs.empty_search')
                : context.tr('jobs.no_results_for', {'query': _searchQuery}),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            context.tr('jobs.try_adjusting'),
            style: TextStyle(
              fontSize: 13.sp,
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
