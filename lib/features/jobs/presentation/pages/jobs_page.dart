import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/presentation/widgets/stagger_entrance.dart';
import '../../../../core/presentation/widgets/shimmer.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/featured_job_card.dart';
import '../widgets/recommended_job_tile.dart';
import '../widgets/job_card_skeleton.dart';
import '../manager/jobs_bloc.dart';
import '../../domain/entities/job_entity.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const List<String> _filterKeys = [
    'All',
    'Remote',
    'Full-time',
    'Contract',
    'Internship',
  ];

  @override
  void initState() {
    super.initState();
    context.read<JobsBloc>().add(const GetJobsEvent());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<JobsBloc>().add(const GetJobsEvent(loadMore: true));
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _filterDisplay(String key) => switch (key) {
    'Remote' => context.tr('remote'),
    'Full-time' => context.tr('full_time'),
    'Contract' => context.tr('contract'),
    'Internship' => context.tr('internship'),
    _ => context.tr('common.all'),
  };

  void _submitSearch(String query) {
    final trimmed = query.trim();
    Navigator.pushNamed(context, AppRouter.jobSearch, arguments: trimmed);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.backgroundAlt,
    appBar: AppBar(
      backgroundColor: context.colors.surface,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsetsDirectional.only(start: 16.w),
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRouter.profile),
          child: CircleAvatar(
            radius: 20.r,
            backgroundColor: context.colors.surfaceMuted,
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
              size: 24.sp,
            ),
          ),
        ),
      ),
      title: Text(
        context.tr('jobs.title'),
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_none,
            color: context.colors.textPrimary,
          ),
          onPressed: () =>
              Navigator.pushNamed(context, AppRouter.notifications),
        ),
        SizedBox(width: 8.w),
      ],
    ),
    body: BlocListener<JobsBloc, JobsState>(
      listener: (context, state) {
        if (state is JobsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          if (state is JobsLoading) {
            return _buildLoadingSkeleton();
          } else if (state is JobsLoaded) {
            final jobs = state.jobs;
            final filteredJobs = _selectedFilter == 'All'
                ? jobs
                : _selectedFilter == 'Remote'
                ? jobs.where((j) => j.workPlace == 'Remote').toList()
                : jobs.where((j) => j.type == _selectedFilter).toList();

            return RefreshIndicator(
              onRefresh: () async {
                context.read<JobsBloc>().add(const GetJobsEvent());
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMyApplicationsTile(),
                    _buildSearchBar(),
                    _buildFilterChips(),
                    if (filteredJobs.isEmpty)
                      _buildEmptyState()
                    else ...[
                      if (_selectedFilter == 'All') ...[
                        _buildSectionTitle(context.tr('jobs.featured_role')),
                        _buildFeaturedList(jobs),
                      ],
                      _buildSectionTitle(
                        _selectedFilter == 'All'
                            ? context.tr('jobs.recommended')
                            : context.tr('jobs.showing', {
                                'type': _filterDisplay(_selectedFilter),
                              }),
                      ),
                      _buildJobsList(filteredJobs),
                      if (state.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    ],
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            );
          }
          return _buildLoadingSkeleton(); // Fallback loading
        },
      ),
    ),
  );

  Widget _buildLoadingSkeleton() => Shimmer(
    child: SingleChildScrollView(
      child: Column(
        children: List.generate(5, (index) => const JobCardSkeleton()),
      ),
    ),
  );

  Widget _buildEmptyState() => Container(
    height: 400.h,
    alignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off_rounded,
          size: 80.sp,
          color: context.colors.textHint,
        ),
        SizedBox(height: 16.h),
        Text(
          context.tr('jobs.no_jobs'),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    ),
  );

  Widget _buildFeaturedList(List<JobEntity> jobs) => SizedBox(
    height: 205.h,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: jobs.length > 5 ? 5 : jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return StaggerEntrance(
          key: ValueKey('featured-$index'),
          index: index,
          child: FeaturedJobCard(
            title: job.title,
            company: job.companyName,
            location: job.location,
            salary: '\$${job.salary.min.toInt()} - \$${job.salary.max.toInt()}',
            logoUrl: job.companyLogo,
            type: job.type,
            workPlace: job.workPlace,
            jobId: job.id,
            isVibrant: index.isEven,
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.jobDetails,
              arguments: job,
            ),
          ),
        );
      },
    ),
  );

  Widget _buildJobsList(List<JobEntity> jobs) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Column(
      children: jobs.asMap().entries.map((e) {
        final job = e.value;
        return StaggerEntrance(
          key: ValueKey('rec-${job.id}'),
          index: e.key,
          child: RecommendedJobTile(
            title: job.title,
            company: job.companyName,
            location: job.location,
            logoUrl: job.companyLogo,
            tags: [job.type, if (job.workPlace == 'Remote') 'Remote'],
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.jobDetails,
              arguments: job,
            ),
          ),
        );
      }).toList(),
    ),
  );

  // --- UI Helpers ---
  Widget _buildMyApplicationsTile() => Padding(
    padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.w, 16.w, 0),
    child: InkWell(
      onTap: () => Navigator.pushNamed(context, AppRouter.myApplications),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.description_outlined, color: Colors.white, size: 22.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                context.tr('jobs.my_apps'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              color: Colors.white,
              size: 20.sp,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildSearchBar() => Padding(
    padding: EdgeInsets.all(16.w),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.colors.inputBorder),
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: _submitSearch,
        style: TextStyle(color: context.colors.textPrimary),
        decoration: InputDecoration(
          hintText: context.tr('jobs.search_titles'),
          hintStyle: TextStyle(color: context.colors.textHint, fontSize: 14.sp),
          prefixIcon: Icon(Icons.search, color: context.colors.textHint),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15.h),
        ),
      ),
    ),
  );

  Widget _buildFilterChips() => SizedBox(
    height: 40.h,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      children: _filterKeys.map(_buildFilterChip).toList(),
    ),
  );

  Widget _buildFilterChip(String key) {
    final isActive = _selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
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
            fontSize: 14.sp,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: EdgeInsetsDirectional.fromSTEB(16.w, 20.h, 16.w, 12.h),
    child: Text(
      title,
      style: TextStyle(
        color: context.colors.textPrimary,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
