import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../widgets/post_card.dart';
import '../widgets/story_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              radius: 18.r,
              backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=me'),
            ),
          ),
        ),
        title: Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: AppColors.fieldBackground,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14.sp),
              prefixIcon: Icon(Icons.search, color: AppColors.textHint, size: 20.sp),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8.h),
            ),
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: AppColors.primaryDark, size: 24.sp),
                onPressed: () => Navigator.pushNamed(context, AppRouter.notifications),
              ),
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: AppColors.accentCyan,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stories
            Container(
              height: 110.h,
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: const [
                  StoryItem(label: 'Your Story', isYourStory: true),
                  StoryItem(label: 'Sarah J.', imageUrl: 'https://i.pravatar.cc/150?u=sarah'),
                  StoryItem(label: 'David L.', imageUrl: 'https://i.pravatar.cc/150?u=david'),
                  StoryItem(label: 'Emily C.', imageUrl: 'https://i.pravatar.cc/150?u=emily'),
                  StoryItem(label: 'Marcus J.', imageUrl: 'https://i.pravatar.cc/150?u=marcus'),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            // Feed
            const PostCard(
              userName: 'Emily Chen',
              userRole: 'Product Designer @ TechFlow',
              userAvatar: 'https://i.pravatar.cc/150?u=emily',
              timeAgo: '2h',
              content: "I'm thrilled to share that I'm starting a new position as Senior Product Designer at TechFlow Inc.! 🚀 It's been a long journey of learning and growing. Huge thanks to everyone who supported me along the way.",
              hashtags: ['#NewBeginnings', '#Design', '#CareerUpdate'],
              mediaUrl: 'https://images.unsplash.com/photo-1497215728101-856f4ea42174?q=80&w=500',
              likes: '438',
              comments: '42',
            ),
            const PostCard(
              userName: 'Dr. James Wilson',
              userRole: 'Professor of Economics @ Ivy Univ',
              userAvatar: 'https://i.pravatar.cc/150?u=james',
              timeAgo: '5h',
              content: 'The future of remote work is hybrid. Our latest study shows a 25% increase in productivity when teams meet in person once a week. Read the full analysis below. 👇',
              hashtags: [],
              mediaUrl: 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?q=80&w=500',
              likes: '1.2k',
              comments: '89',
            ),
            const PostCard(
              userName: 'Marcus Johnson',
              userRole: 'Tech Recruiter',
              userAvatar: 'https://i.pravatar.cc/150?u=marcus',
              timeAgo: '1d',
              content: 'Top 3 tips for your next interview! 💡 Make sure you\'re prepared for the most common questions.',
              hashtags: ['#CareerAdvice', '#InterviewTips'],
              mediaUrl: 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?q=80&w=500',
              likes: '856',
              comments: '34',
            ),
          ],
        ),
      ),
    );
  }
}
