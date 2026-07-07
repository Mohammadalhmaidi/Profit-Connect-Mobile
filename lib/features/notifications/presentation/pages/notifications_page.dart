import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Notifications',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () {},
              child: Text(
                'Mark all',
                style: TextStyle(
                  color: const Color(0xFF7B39FD),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 8.w),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60.h),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Colors.black,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Jobs'),
                  Tab(text: 'Social'),
                ],
              ),
            ),
          ),
        ),
        body: ListView(
          children: [
            _buildSectionHeader('NEW'),
            NotificationTile(
              isUnread: true,
              leading: _buildIconContainer(Icons.work, const Color(0xFFE1F5FE), const Color(0xFF03A9F4)),
              title: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 15.sp),
                children: [
                  const TextSpan(text: 'New Job: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: 'Senior Product Designer at '),
                  TextSpan(text: 'TechFlow', style: TextStyle(color: const Color(0xFF7B39FD), fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' matches your profile.'),
                ],
              ),
              time: '2h ago',
              actions: [
                NotificationActionButton(label: 'Apply Now', onPressed: () {}),
              ],
            ),
            NotificationTile(
              isUnread: true,
              leading: _buildIconContainer(Icons.visibility, const Color(0xFFEDE7F6), const Color(0xFF7B39FD)),
              title: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 15.sp),
                children: [
                  const TextSpan(text: 'Profile View: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: 'Someone at '),
                  const TextSpan(text: 'Google', style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' and 3 others viewed your profile.'),
                ],
              ),
              time: '4h ago',
            ),
            _buildSectionHeader('EARLIER'),
            NotificationTile(
              leading: _buildIconContainer(Icons.favorite, const Color(0xFFF3E5F5), const Color(0xFF7B39FD)),
              title: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 15.sp),
                children: [
                  const TextSpan(text: 'Sarah Jenkins', style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' liked your post: "5 Tips for Junior Devs entering the market".'),
                ],
              ),
              time: '1d ago',
            ),
            NotificationTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=james'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: const BoxDecoration(color: Color(0xFF4A148C), shape: BoxShape.circle),
                      child: Icon(Icons.person_add, color: Colors.white, size: 10.sp),
                    ),
                  ),
                ],
              ),
              title: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 15.sp),
                children: [
                  const TextSpan(text: 'James Miller', style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' invited you to connect. He also works at '),
                  const TextSpan(text: 'TechFlow.', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              time: '2d ago',
              actions: [
                NotificationActionButton(label: 'Accept', onPressed: () {}),
                NotificationActionButton(label: 'Ignore', onPressed: () {}, isPrimary: false),
              ],
            ),
            NotificationTile(
              leading: _buildIconContainer(Icons.work, const Color(0xFFE1F5FE), const Color(0xFF03A9F4)),
              title: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 15.sp),
                children: [
                  const TextSpan(text: 'Your application for '),
                  const TextSpan(text: 'UX Researcher', style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' at '),
                  const TextSpan(text: 'Figma', style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' was viewed.'),
                ],
              ),
              time: '3d ago',
            ),
            NotificationTile(
              leading: _buildIconContainer(Icons.chat_bubble, const Color(0xFFEDE7F6), const Color(0xFF7B39FD)),
              title: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 15.sp),
                children: [
                  const TextSpan(text: 'Marcus Thorne', style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' commented on your post: "Great insights on the new Figma update!"'),
                ],
              ),
              time: '4d ago',
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, top: 24.h, bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textHint,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildIconContainer(IconData icon, Color bgColor, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 24.sp),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 3, // Alerts is index 3
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF7B39FD),
      unselectedItemColor: AppColors.textHint,
      selectedLabelStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontSize: 10.sp),
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'HOME'),
        const BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'NETWORK'),
        BottomNavigationBarItem(
          icon: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.textHint,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          label: 'POST',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'ALERTS'),
        const BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'JOBS'),
      ],
    );
  }
}
