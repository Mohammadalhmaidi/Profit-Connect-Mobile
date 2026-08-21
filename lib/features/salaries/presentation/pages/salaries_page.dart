import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';

class SalariesPage extends StatefulWidget {
  const SalariesPage({super.key});

  @override
  State<SalariesPage> createState() => _SalariesPageState();
}

class _SalariesPageState extends State<SalariesPage> {
  bool _isLoading = true;
  List<String> _titles = [];
  List<String> _countries = [];
  List<String> _experienceLevels = [];
  String? _selectedTitle;
  String? _selectedCountry;
  String? _selectedLevel;
  List<Map<String, dynamic>> _salaries = [];
  List<Map<String, dynamic>> _stats = [];

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final res = await sl<ApiService>().getSalaryOptions();
      final data = res.data['data'] as Map<String, dynamic>? ?? {};
      if (!mounted) return;
      setState(() {
        _titles = (data['titles'] as List<dynamic>? ?? [])
            .whereType<String>()
            .toList();
        _countries = (data['countries'] as List<dynamic>? ?? [])
            .whereType<String>()
            .toList();
        _experienceLevels = (data['experienceLevels'] as List<dynamic>? ?? [])
            .whereType<String>()
            .toList();
        _selectedTitle = _titles.isEmpty ? null : _titles.first;
        _selectedCountry = _countries.isEmpty ? null : _countries.first;
        _selectedLevel = _experienceLevels.isEmpty
            ? null
            : _experienceLevels.first;
        _isLoading = false;
      });
      await _loadSalaries();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSalaries() async {
    try {
      final api = sl<ApiService>();
      final salariesRes = await api.getSalaries(
        title: _selectedTitle,
        country: _selectedCountry,
        experienceLevel: _selectedLevel,
      );
      final statsRes = await api.getSalaryStats(
        title: _selectedTitle,
        country: _selectedCountry,
        experienceLevel: _selectedLevel,
      );
      if (!mounted) return;
      setState(() {
        _salaries = (salariesRes.data['data'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _stats = (statsRes.data['data'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _salaries = [];
        _stats = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.backgroundAlt,
    appBar: AppBar(
      backgroundColor: context.colors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        context.tr('salaries.title'),
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _buildFilters(),
              SizedBox(height: 20.h),
              _buildStatsSection(),
              SizedBox(height: 24.h),
              _buildSectionTitle(
                context.tr('salaries.records_count', {
                  'count': '${_salaries.length}',
                }),
              ),
              if (_salaries.isEmpty)
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    context.tr('salaries.no_records'),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                )
              else
                ..._salaries.map(_buildSalaryRow),
            ],
          ),
  );

  Widget _buildFilters() => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(16.r),
    ),
    child: Column(
      children: [
        if (_titles.isNotEmpty)
          _buildDropdown(
            label: context.tr('salaries.filter_title'),
            value: _selectedTitle,
            items: _titles,
            onChanged: (v) {
              setState(() => _selectedTitle = v);
              _loadSalaries();
            },
          ),
        if (_countries.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _buildDropdown(
            label: context.tr('salaries.filter_country'),
            value: _selectedCountry,
            items: _countries,
            onChanged: (v) {
              setState(() => _selectedCountry = v);
              _loadSalaries();
            },
          ),
        ],
        if (_experienceLevels.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _buildDropdown(
            label: context.tr('salaries.filter_level'),
            value: _selectedLevel,
            items: _experienceLevels,
            onChanged: (v) {
              setState(() => _selectedLevel = v);
              _loadSalaries();
            },
          ),
        ],
      ],
    ),
  );

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) => DropdownButtonFormField<String>(
    initialValue: value,
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: context.colors.surfaceMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
    ),
    items: items
        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
        .toList(),
    onChanged: onChanged,
  );

  Widget _buildStatsSection() {
    if (_stats.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context.tr('salaries.average')),
          ..._stats.map((stat) {
            final key = stat['_id']?.toString() ?? '';
            final avgMin = stat['averageMin'] as num? ?? 0;
            final avgMax = stat['averageMax'] as num? ?? 0;
            final count = stat['count'] as num? ?? 0;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      key,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '\$${avgMin.toStringAsFixed(0)} - \$${avgMax.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: AppColors.accentCyan,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '($count)',
                    style: TextStyle(
                      color: context.colors.textHint,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSalaryRow(Map<String, dynamic> s) => Container(
    margin: EdgeInsets.only(bottom: 8.h),
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s['title']?.toString() ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                [
                  s['country']?.toString() ?? '',
                  s['experienceLevel']?.toString() ?? '',
                  s['category']?.toString() ?? '',
                ].where((e) => e.isNotEmpty).join(' \u2022 '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
        Text(
          '\$${(s['minSalaryUSD'] as num?)?.toStringAsFixed(0) ?? '?'} - '
          '\$${(s['maxSalaryUSD'] as num?)?.toStringAsFixed(0) ?? '?'}',
          style: TextStyle(
            color: AppColors.accentCyan,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  Widget _buildSectionTitle(String title) => Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: Text(
      title,
      style: TextStyle(
        color: context.colors.textPrimary,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
