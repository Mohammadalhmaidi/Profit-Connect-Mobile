import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/presentation/widgets/brand_logo.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String? _lastFailureMessage;

  @override
  void initState() {
    super.initState();
    // Trigger the session check
    context.read<AuthBloc>().add(const CheckAuthStatus());
  }

  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
    listener: (context, state) {
      if (state is AuthSuccess) {
        Navigator.pushReplacementNamed(context, AppRouter.mainLayout);
      } else if (state is AuthInitial) {
        Navigator.pushReplacementNamed(context, AppRouter.login);
      } else if (state is AuthFailure) {
        // لا نطرد المستخدم المسجّل دخوله إلى صفحة الدخول عند فشل مؤقت
        // (شبكة/خادم) — نعرض إعادة المحاولة بدلاً من ذلك.
        setState(() => _lastFailureMessage = state.message);
      }
    },
    child: Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthFailure) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 56.sp,
                    color: Colors.white70,
                  ),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      _lastFailureMessage ?? context.tr('error'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: () {
                      setState(() => _lastFailureMessage = null);
                      context.read<AuthBloc>().add(const CheckAuthStatus());
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(context.tr('retry')),
                  ),
                ],
              );
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const BrandLogo(width: 180, color: Colors.white)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(delay: 200.ms, curve: Curves.easeOutBack),
                SizedBox(height: 24.h),
                const CircularProgressIndicator(color: Colors.white),
              ],
            );
          },
        ),
      ),
    ),
  );
}
