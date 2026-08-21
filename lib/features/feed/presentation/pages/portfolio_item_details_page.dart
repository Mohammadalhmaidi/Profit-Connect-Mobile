import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../api_service.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/media_url_helper.dart';
import '../../../../l10n/app_localizations.dart';

/// تفاصيل عمل من المعرض — وسائط، وصف، إعجاب، مشاهدات.
class PortfolioItemDetailsPage extends StatefulWidget {
  final String itemId;

  const PortfolioItemDetailsPage({required this.itemId, super.key});

  @override
  State<PortfolioItemDetailsPage> createState() =>
      _PortfolioItemDetailsPageState();
}

class _PortfolioItemDetailsPageState extends State<PortfolioItemDetailsPage> {
  final _api = sl<ApiService>();
  Map<String, dynamic>? _item;
  bool _isLoading = true;
  String? _error;
  int _page = 0;
  bool _isLiked = false;
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await _api.getPortfolioItemById(widget.itemId);
      final body = res.data is Map ? Map<String, dynamic>.from(res.data) : null;
      final item = body?['data'];
      if (!mounted) return;
      setState(() {
        _item = item is Map ? Map<String, dynamic>.from(item) : null;
        _likesCount = (_item?['likes'] as List?)?.length ?? 0;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = context.tr('error');
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleLike() async {
    if (_item == null) return;
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
    try {
      final res = await _api.togglePortfolioLike(widget.itemId);
      final map = res.data is Map ? Map<String, dynamic>.from(res.data) : null;
      if (!mounted) return;
      setState(() {
        _isLiked = map?['isLiked'] as bool? ?? _isLiked;
        _likesCount = (map?['likesCount'] as num?)?.toInt() ?? _likesCount;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLiked = !_isLiked;
        _likesCount += _isLiked ? 1 : -1;
      });
    }
  }

  List<Map<String, dynamic>> get _mediaList {
    final media = _item?['media'];
    if (media is! List) return const [];
    return media.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null || _item == null
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error ?? '', style: const TextStyle(color: Colors.red)),
                SizedBox(height: 12.h),
                FilledButton(
                  onPressed: _load,
                  child: Text(context.tr('retry')),
                ),
              ],
            ),
          )
        : _buildContent(),
  );

  Widget _buildContent() {
    final item = _item!;
    final media = _mediaList;
    final views = (item['views'] as num?)?.toInt() ?? 0;
    final tags = item['tags'] as List? ?? [];
    final skills = item['skills'] as List? ?? [];
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (media.isNotEmpty) _buildMediaCarousel(media),
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title'] as String? ?? '',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.chipSelected,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      item['category'] as String? ?? '',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Icon(
                    Icons.visibility_outlined,
                    size: 16.sp,
                    color: context.colors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '$views ${context.tr('portfolio.views')}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              if ((item['description'] as String? ?? '').isNotEmpty) ...[
                Text(
                  item['description'] as String,
                  style: TextStyle(
                    fontSize: 15.sp,
                    height: 1.6,
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
              ],
              _buildMetaRow(
                Icons.person_outline,
                context.tr('portfolio.create_client'),
                item['client'] as String? ?? '',
              ),
              _buildMetaRow(
                Icons.schedule,
                context.tr('portfolio.create_duration'),
                item['duration'] as String? ?? '',
              ),
              _buildMetaRow(
                Icons.work_outline,
                context.tr('portfolio.create_role'),
                item['role'] as String? ?? '',
              ),
              if ((item['projectUrl'] as String? ?? '').isNotEmpty)
                _buildMetaRow(
                  Icons.link,
                  context.tr('portfolio.create_url'),
                  item['projectUrl'] as String,
                ),
              if (tags.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: tags.map((t) => _chip('$t')).toList(),
                ),
              ],
              if (skills.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: skills
                      .map((s) => _chip('$s', filled: true))
                      .toList(),
                ),
              ],
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _toggleLike,
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked
                            ? Colors.redAccent
                            : context.colors.textSecondary,
                      ),
                      label: Text('$_likesCount'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.textPrimary,
                        side: BorderSide(color: context.colors.divider),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaCarousel(List<Map<String, dynamic>> media) => Column(
    children: [
      SizedBox(
        height: 260.h,
        child: PageView.builder(
          itemCount: media.length,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (context, index) {
            final url = MediaUrlHelper.resolve(
              media[index]['url'] as String? ?? '',
            );
            return url.isEmpty
                ? const SizedBox.shrink()
                : CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorWidget: (_, __, ___) => ColoredBox(
                      color: context.colors.surfaceMuted,
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 48.sp,
                        color: context.colors.textHint,
                      ),
                    ),
                  );
          },
        ),
      ),
      if (media.length > 1)
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              media.length,
              (i) => Container(
                width: 8.w,
                height: 8.w,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _page
                      ? AppColors.primaryDark
                      : context.colors.divider,
                ),
              ),
            ),
          ),
        ),
    ],
  );

  Widget _buildMetaRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: context.colors.textSecondary),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(
                fontSize: 14.sp,
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, {bool filled = false}) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: filled
          ? context.colors.chipSelected
          : context.colors.chipUnselected,
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 12.sp, color: context.colors.textPrimary),
    ),
  );
}
