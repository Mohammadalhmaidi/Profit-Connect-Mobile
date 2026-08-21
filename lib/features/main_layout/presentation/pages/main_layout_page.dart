import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../feed/presentation/pages/home_page.dart';
import '../../../network/presentation/pages/network_page.dart';
import '../../../jobs/presentation/pages/jobs_page.dart';
import '../../../messages/presentation/pages/messages_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../manager/navigation_cubit.dart';
import '../widgets/app_sidebar.dart';

class MainLayoutPage extends StatefulWidget {
  const MainLayoutPage({super.key});

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => NavigationCubit(),
    child: BlocBuilder<NavigationCubit, int>(
      builder: (context, currentIndex) => Scaffold(
        drawer: const AppSidebar(),
        body: IndexedStack(
          index: currentIndex,
          children: const [
            HomePage(),
            NetworkPage(),
            JobsPage(),
            MessagesPage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(context, currentIndex),
      ),
    ),
  );

  Widget _buildBottomBar(BuildContext context, int currentIndex) =>
      BottomAppBar(
        color: Theme.of(context).colorScheme.surface,
        elevation: 8,
        child: SizedBox(
          height: 62.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: context.tr('nav.home'),
                index: 0,
                currentIndex: currentIndex,
                onTap: () => context.read<NavigationCubit>().setIndex(0),
              ),
              _NavItem(
                icon: Icons.people_rounded,
                label: context.tr('nav.network'),
                index: 1,
                currentIndex: currentIndex,
                onTap: () => context.read<NavigationCubit>().setIndex(1),
              ),
              _NavItem(
                icon: Icons.work_rounded,
                label: context.tr('nav.jobs'),
                index: 2,
                currentIndex: currentIndex,
                onTap: () => context.read<NavigationCubit>().setIndex(2),
              ),
              _NavItem(
                icon: Icons.message_rounded,
                label: context.tr('nav.messages'),
                index: 3,
                currentIndex: currentIndex,
                onTap: () => context.read<NavigationCubit>().setIndex(3),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: context.tr('nav.profile'),
                index: 4,
                currentIndex: currentIndex,
                onTap: () => context.read<NavigationCubit>().setIndex(4),
              ),
            ],
          ),
        ),
      );
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _scale;

  bool get _selected => widget.index == widget.currentIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scale = Tween<double>(
      begin: 0.75,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    if (_selected) _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant _NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selected && oldWidget.currentIndex != widget.currentIndex) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = scheme.primary;
    final unselectedColor = context.colors.textHint;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: _selected
              ? selected.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: ScaleTransition(
          scale: _scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: _selected ? selected : unselectedColor,
                size: 23.sp,
              ),
              SizedBox(height: 2.h),
              Text(
                widget.label,
                style: TextStyle(
                  color: _selected ? selected : unselectedColor,
                  fontSize: 10.sp,
                  fontWeight: _selected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
