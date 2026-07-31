import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../widgets/job_filter_chip.dart';
import '../widgets/featured_job_card.dart';
import '../widgets/recommended_job_tile.dart';
import '../widgets/job_card_skeleton.dart';
import '../manager/jobs_bloc.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<JobsBloc>().add(const GetJobsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    final trimmed = query.trim();
    Navigator.pushNamed(
      context,
      AppRouter.jobSearch,
      arguments: trimmed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRouter.profile),
            child: CircleAvatar(
              radius: 20.r,
              backgroundColor: AppColors.chipUnselected,
              child: Icon(Icons.person, color: AppColors.primaryDark, size: 24.sp),
            ),
          ),
        ),
        title: Text(
          'CareerPath Jobs',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, AppRouter.notifications),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: BlocListener<JobsBloc, JobsState>(
        listener: (context, state) {
          if (state is JobsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
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
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      _buildFilterChips(),
                      if (filteredJobs.isEmpty)
                        _buildEmptyState()
                      else ...[
                        if (_selectedFilter == 'All') ...[
                          _buildSectionTitle('Featured Roles'),
                          _buildFeaturedList(jobs),
                        ],
                        _buildSectionTitle(_selectedFilter == 'All' ? 'Recommended for you' : 'Showing $_selectedFilter Jobs'),
                        _buildJobsList(filteredJobs),
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
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(5, (index) => const JobCardSkeleton()),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400.h,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80.sp, color: AppColors.textHint),
          SizedBox(height: 16.h),
          // Fix: Removed 'const' because 18.sp is a runtime extension
          Text(
            'No Jobs Found',
            style: TextStyle(
              fontSize: 18.sp, 
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedList(List jobs) {
    return SizedBox(
      height: 180.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: jobs.length > 5 ? 5 : jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return FeaturedJobCard(
            title: job.title,
            company: job.companyName,
            location: job.location,
            salary: '\$${job.salary.min.toInt()} - \$${job.salary.max.toInt()}',
            logoUrl: job.companyLogo,
            isVibrant: index % 2 == 0,
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.jobDetails,
              arguments: job,
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobsList(List jobs) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: jobs.map((job) {
          return RecommendedJobTile(
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
          );
        }).toList(),
      ),
    );
  }

  // --- UI Helpers ---
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey.shade200)),
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: _submitSearch,
          decoration: InputDecoration(
            hintText: 'Search titles, companies...',
            hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14.sp),
            prefixIcon: Icon(Icons.search, color: AppColors.textHint),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15.h),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: ['All', 'Remote', 'Full-time', 'Contract', 'Internship'].map((label) => _buildFilterChip(label)).toList(),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryDark : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: isActive ? AppColors.primaryDark : Colors.grey.shade300),
        ),
        child: Text(label, style: TextStyle(color: isActive ? Colors.white : AppColors.textPrimary, fontSize: 14.sp, fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Text(title, style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.bold)),
    );
  }
}
