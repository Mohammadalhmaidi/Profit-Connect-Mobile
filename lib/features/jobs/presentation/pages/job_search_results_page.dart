import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/job_result_card.dart';
import '../widgets/search_filter_chip.dart';

class JobSearchResultsPage extends StatelessWidget {
  const JobSearchResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          // Search & Filters Section
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(bottom: 16.h),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.fieldBackground,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Job title, keywords, or company',
                              hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14.sp),
                              prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(Icons.tune, color: AppColors.primaryBlue, size: 28.sp),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: const [
                      SearchFilterChip(label: 'Remote', isActive: true),
                      SearchFilterChip(label: 'On-site'),
                      SearchFilterChip(label: 'Full-time'),
                      SearchFilterChip(label: 'Internship'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Results Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '42 JOBS FOUND',
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  label: Text(
                    'Newest first',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryBlue, size: 18.sp),
                ),
              ],
            ),
          ),
          
          // Job List
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: [
                JobResultCard(
                  title: 'Senior Product Designer',
                  company: 'TechFlow',
                  location: 'New York, NY',
                  logoUrl: 'https://i.pravatar.cc/150?u=techflow',
                  postedTime: '2 hours ago',
                  salary: r'$120K - $150K',
                  workType: 'Remote',
                  isSaved: true,
                  onApply: () {},
                ),
                JobResultCard(
                  title: 'Frontend Engineer',
                  company: 'CloudScale',
                  location: 'San Francisco',
                  logoUrl: 'https://i.pravatar.cc/150?u=cloudscale',
                  postedTime: '5 hours ago',
                  salary: r'$140K - $180K',
                  workType: 'Hybrid',
                  onApply: () {},
                ),
                JobResultCard(
                  title: 'UX Researcher',
                  company: 'InsightLabs',
                  location: 'Austin, TX',
                  logoUrl: 'https://i.pravatar.cc/150?u=insightlabs',
                  postedTime: '1 day ago',
                  salary: r'$90K - $115K',
                  workType: 'Remote',
                  onApply: () {},
                ),
                JobResultCard(
                  title: 'Data Scientist',
                  company: 'AIPioneer',
                  location: 'Remote',
                  logoUrl: 'https://i.pravatar.cc/150?u=aipioneer',
                  postedTime: '2 days ago',
                  salary: r'$160K - $210K',
                  workType: 'Remote',
                  isSaved: true,
                  onApply: () {},
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
        child: Icon(Icons.add, color: Colors.white, size: 30.sp),
      ),
    );
  }
}
