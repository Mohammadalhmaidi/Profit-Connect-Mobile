import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/presentation/manager/theme_bloc.dart';
import '../../../../core/presentation/manager/app_settings_cubit.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../api_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/settings_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  String _profileVisibility = 'public';

  @override
  void initState() {
    super.initState();
    _syncFromServer();
  }

  Future<void> _syncFromServer() async {
    try {
      final res = await sl<ApiService>().getSettings();
      final settings = res.data['data'] as Map<String, dynamic>?;
      if (settings == null || !mounted) return;
      final theme = settings['theme']?.toString();
      final language = settings['language']?.toString();
      if (theme != null && theme != 'system') {
        final shouldBeDark = theme == 'dark';
        final bloc = context.read<ThemeBloc>();
        if (bloc.state.themeMode !=
            (shouldBeDark ? ThemeMode.dark : ThemeMode.light)) {
          bloc.setDark(value: shouldBeDark);
        }
      }
      if (language != null && language != 'system' && language != 'en') {
        if (context.read<AppSettingsCubit>().state.locale.languageCode !=
            language) {
          context.read<AppSettingsCubit>().setLocale(language);
        }
      }
      if (!mounted) return;
      setState(() {
        _emailNotifications = settings['emailNotifications'] != false;
        _pushNotifications = settings['pushNotifications'] != false;
        _profileVisibility =
            settings['profileVisibility']?.toString() ?? 'public';
      });
    } catch (_) {
      // Server unreachable - keep local defaults
    }
  }

  Future<bool> _updateServer(Map<String, dynamic> updates) async {
    try {
      await sl<ApiService>().updateSettings(updates);
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('settings.sync_error'))),
        );
      }
      return false;
    }
  }

  Future<void> _toggleDarkMode(ThemeBloc bloc) async {
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final wasDark = bloc.isDark(platformBrightness);
    final isDark = !wasDark;
    bloc.setDark(value: isDark);
    final ok = await _updateServer({'theme': isDark ? 'dark' : 'light'});
    if (!ok && mounted) {
      bloc.setDark(value: wasDark); // تراجع محلي عند فشل المزامنة
    }
  }

  Future<void> _changeLanguage(AppSettingsCubit cubit, String current) async {
    final newLang = current == 'en' ? 'ar' : 'en';
    final previous = cubit.state.locale.languageCode;
    cubit.setLocale(newLang);
    final ok = await _updateServer({'language': newLang});
    if (!ok && mounted) {
      cubit.setLocale(previous); // تراجع محلي عند فشل المزامنة
    }
  }

  bool _isDark(ThemeState themeState) {
    final platform = MediaQuery.platformBrightnessOf(context);
    return themeState.themeMode == ThemeMode.dark ||
        (themeState.themeMode == ThemeMode.system &&
            platform == Brightness.dark);
  }

  Future<void> _openCompanyDashboard() async {
    final state = context.read<AuthBloc>().state;
    if (state is! AuthSuccess) return;
    final user = state.user;
    var companyId = user.companyId;
    if (companyId == null || companyId.isEmpty) {
      if (user.role != UserRole.Employer) {
        if (mounted) {
          UIUtils.showSnackBar(
            context: context,
            message: context.tr('company.no_linked'),
          );
        }
        return;
      }
      try {
        companyId = await sl<ApiService>().findOwnedCompanyId(user.id);
      } catch (_) {
        companyId = null;
      }
      if (companyId == null || companyId.isEmpty) {
        if (mounted) {
          UIUtils.showSnackBar(
            context: context,
            message: context.tr('company.no_linked'),
          );
        }
        return;
      }
    }
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      AppRouter.companyDashboard,
      arguments: companyId,
    );
  }

  Widget _sectionHeader(String label) => Text(
    label,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    ),
  );

  Widget _sectionCard(BuildContext context, List<Widget> children) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(16.r),
    clipBehavior: Clip.antiAlias,
    child: Column(children: children),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.backgroundAlt,
    appBar: AppBar(title: Text(context.tr('settings'))),
    body: ListView(
      padding: EdgeInsets.all(24.w),
      children: [
        _sectionHeader(context.tr('settings.appearance')),
        SizedBox(height: 12.h),
        _sectionCard(context, [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              final isDark = _isDark(themeState);
              return SettingsTile(
                icon: isDark ? Icons.dark_mode : Icons.light_mode,
                title: context.tr('dark_mode'),
                trailing: Switch.adaptive(
                  value: isDark,
                  onChanged: (_) => _toggleDarkMode(context.read<ThemeBloc>()),
                  activeThumbColor: AppColors.vibrantPurple,
                ),
              );
            },
          ),
          BlocBuilder<AppSettingsCubit, AppSettingsState>(
            builder: (context, state) => SettingsTile(
              icon: Icons.language,
              title: context.tr('language'),
              subtitle: state.locale.languageCode == 'ar'
                  ? 'العربية'
                  : 'English',
              onTap: () {
                _changeLanguage(
                  context.read<AppSettingsCubit>(),
                  state.locale.languageCode,
                );
              },
            ),
          ),
          SettingsTile(
            icon: Icons.email_outlined,
            title: context.tr('settings.email_notifications'),
            trailing: Switch.adaptive(
              value: _emailNotifications,
              onChanged: (value) async {
                final previous = _emailNotifications;
                setState(() => _emailNotifications = value);
                final ok = await _updateServer({'emailNotifications': value});
                if (!ok && mounted) {
                  setState(() => _emailNotifications = previous);
                }
              },
              activeThumbColor: AppColors.vibrantPurple,
            ),
          ),
          SettingsTile(
            icon: Icons.notifications_active_outlined,
            title: context.tr('settings.push_notifications'),
            trailing: Switch.adaptive(
              value: _pushNotifications,
              onChanged: (value) async {
                final previous = _pushNotifications;
                setState(() => _pushNotifications = value);
                final ok = await _updateServer({'pushNotifications': value});
                if (!ok && mounted) {
                  setState(() => _pushNotifications = previous);
                }
              },
              activeThumbColor: AppColors.vibrantPurple,
            ),
          ),
          SettingsTile(
            icon: Icons.visibility_outlined,
            title: context.tr('settings.profile_visibility'),
            subtitle: _profileVisibility == 'private'
                ? context.tr('settings.private')
                : _profileVisibility == 'connections'
                ? context.tr('settings.connections_only')
                : context.tr('settings.public'),
            onTap: () async {
              final options = ['public', 'connections', 'private'];
              final currentIndex = options
                  .indexOf(_profileVisibility)
                  .clamp(0, 2);
              final next = options[(currentIndex + 1) % options.length];
              final previous = _profileVisibility;
              setState(() => _profileVisibility = next);
              final ok = await _updateServer({'profileVisibility': next});
              if (!ok && mounted) {
                setState(() => _profileVisibility = previous);
              }
            },
          ),
        ]),
        SizedBox(height: 24.h),
        _sectionHeader(context.tr('settings.account')),
        SizedBox(height: 12.h),
        _sectionCard(context, [
          SettingsTile(
            icon: Icons.person_outline,
            title: context.tr('settings.edit_profile'),
            onTap: () => Navigator.pushNamed(context, AppRouter.profile),
          ),
          SettingsTile(
            icon: Icons.notifications_outlined,
            title: context.tr('notifications'),
            onTap: () => Navigator.pushNamed(context, AppRouter.notifications),
          ),
          SettingsTile(
            icon: Icons.lock_outline,
            title: context.tr('settings.change_password'),
            onTap: () => Navigator.pushNamed(context, AppRouter.changePassword),
          ),
        ]),
        SizedBox(height: 24.h),
        _sectionHeader(context.tr('settings.services')),
        SizedBox(height: 12.h),
        _sectionCard(context, [
          SettingsTile(
            icon: Icons.account_balance_wallet_outlined,
            title: context.tr('settings.wallet'),
            onTap: () => Navigator.pushNamed(context, AppRouter.wallet),
          ),
          SettingsTile(
            icon: Icons.payments_outlined,
            title: context.tr('settings.payments'),
            onTap: () => Navigator.pushNamed(context, AppRouter.payments),
          ),
          SettingsTile(
            icon: Icons.monetization_on_outlined,
            title: context.tr('settings.salaries'),
            onTap: () => Navigator.pushNamed(context, AppRouter.salaries),
          ),
          SettingsTile(
            icon: Icons.folder_copy_outlined,
            title: context.tr('settings.projects'),
            onTap: () => Navigator.pushNamed(context, AppRouter.projects),
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final user = state is AuthSuccess ? state.user : null;
              final companyId = user?.companyId;
              final isEmployer = user?.role == UserRole.Employer;
              final hasCompany = companyId != null && companyId.isNotEmpty;
              return SettingsTile(
                icon: Icons.business_center_outlined,
                title: context.tr('settings.company_dashboard'),
                subtitle: hasCompany || isEmployer
                    ? null
                    : context.tr('settings.company_dashboard_hint'),
                onTap: _openCompanyDashboard,
              );
            },
          ),
        ]),
        SizedBox(height: 24.h),
        _sectionHeader(context.tr('settings.support')),
        SizedBox(height: 12.h),
        _sectionCard(context, [
          SettingsTile(
            icon: Icons.help_outline,
            title: context.tr('settings.help'),
            onTap: () => Navigator.pushNamed(context, AppRouter.help),
          ),
          SettingsTile(
            icon: Icons.info_outline,
            title: context.tr('about'),
            onTap: () => Navigator.pushNamed(context, AppRouter.about),
          ),
        ]),
        SizedBox(height: 40.h),
        Center(
          child: TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: Text(
              context.tr('logout'),
              style: TextStyle(
                color: AppColors.logoutRed,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
