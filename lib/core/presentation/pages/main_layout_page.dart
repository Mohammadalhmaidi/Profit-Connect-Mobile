import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../../features/feed/presentation/pages/home_page.dart';
import '../../../features/network/presentation/pages/network_page.dart';
import '../../../features/jobs/presentation/pages/jobs_page.dart';
import '../../../features/messages/presentation/pages/messages_page.dart';
import '../../../features/profile/presentation/pages/profile_page.dart';
import '../manager/dashboard_cubit.dart';

class MainLayoutPage extends StatelessWidget {
  const MainLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      const JobsPage(),
      const MessagesPage(),
      const ProfilePage(),
    ];

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: state.tabIndex,
            children: pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: state.tabIndex,
            onTap: (index) => context.read<DashboardCubit>().changeTab(index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primaryDark,
            unselectedItemColor: AppColors.textHint,
            selectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontSize: 12.sp),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.work_rounded), label: 'Jobs'),
              BottomNavigationBarItem(icon: Icon(Icons.message_rounded), label: 'Messages'),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}
