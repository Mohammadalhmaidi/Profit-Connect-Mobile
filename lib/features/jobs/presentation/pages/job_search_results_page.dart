import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/media_url_helper.dart';
import '../../../../core/utils/ui_utils.dart';
import '../manager/jobs_bloc.dart';
import '../widgets/job_result_card.dart';

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

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.query ?? '';
    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String value) {
    final query = value.trim();
    setState(() => _searchQuery = query);
    _dispatch();
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
    context.read<JobsBloc>().add(GetJobsEvent(search: _searchQuery, type: type, workPlace: workPlace));
  }

  bool _isTypeFilter(String? f) =>
      f == 'Full-time' || f == 'Part-time' || f == 'Contract' || f == 'Internship';
  bool _isWorkPlaceFilter(String? f) => f == 'Remote' || f == 'On-site' || f == 'Hybrid';

  String _salaryText(job) {
    final s = job.salary;
    if (s.min == 0 && s.max == 0) return 'Salary on request';
    return '${s.currency} ${s.min.toInt()} - ${s.max.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JobsBloc>()..add(GetJobsEvent(search: _searchQuery)),
      child: Scaffold(
        backgroundColor: AppColors.backgroundAlt,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Jobs',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<JobsBloc, JobsState>(
          builder: (context, state) {
            return Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.fieldBackground,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onChanged: _submitSearch,
                            decoration: InputDecoration(
                              hintText: 'Job title, keywords, or company',
                              hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14.sp),
                              prefixIcon: Icon(Icons.search, color: AppColors.textHint),
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
                          children: [
                            _buildFilterChip('Remote'),
                            _buildFilterChip('On-site'),
                            _buildFilterChip('Full-time'),
                            _buildFilterChip('Part-time'),
                            _buildFilterChip('Internship'),
                          ],
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
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
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
                                isSaved: false,
                                onApply: () {
                                  UIUtils.showSnackBar(
                                    context: context,
                                    message: 'Application submitted for ${job.title}',
                                    isError: false,
                                  );
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isActive = _activeFilter == label;
    return GestureDetector(
      onTap: () => _applyFilter(label),
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryDark : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: isActive ? AppColors.primaryDark : AppColors.fieldBackground),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textPrimary,
            fontSize: 13.sp,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 80.sp, color: AppColors.textHint),
            SizedBox(height: 16.h),
            Text(
              _searchQuery.isEmpty
                  ? 'Search for jobs by title, keywords, or company'
                  : 'No jobs found for "$_searchQuery"',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Try adjusting your keywords or filters',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
