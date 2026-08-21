import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../api_service.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/presentation/widgets/app_empty_state.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/media_url_helper.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../l10n/app_localizations.dart';
import 'create_collection_sheet.dart';
import 'create_portfolio_item_sheet.dart';

/// شاشة معرض الأعمال — أعمال المستخدم ومجموعاته من الباك.
class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final _api = sl<ApiService>();
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _collections = [];
  bool _isLoading = true;
  String? _error;

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
      final itemsRes = await _api.getMyPortfolioItems(limit: 50);
      final collectionsRes = await _api.getMyPortfolioCollections();
      if (!mounted) return;
      setState(() {
        _items = _parseList(itemsRes.data);
        _collections = _parseList(collectionsRes.data);
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

  List<Map<String, dynamic>> _parseList(Object? body) {
    if (body is! Map) return [];
    final list = body['data'];
    if (list is! List) return [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  String _coverOf(Map<String, dynamic> item) {
    final raw =
        (item['coverImage'] as String?) ??
        (item['media'] is List && (item['media'] as List).isNotEmpty
            ? ((item['media'] as List).first as Map)['url'] as String?
            : null);
    return raw == null || raw.isEmpty ? '' : MediaUrlHelper.resolve(raw);
  }

  Future<void> _onAddWork() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const CreatePortfolioItemSheet(),
    );
    if (created == true) _load();
  }

  Future<void> _onAddCollection() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const CreateCollectionSheet(),
    );
    if (created == true) _load();
  }

  void _showAddMenu() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.primaryDark,
              ),
              title: Text(context.tr('portfolio.add_work')),
              onTap: () {
                Navigator.pop(context);
                _onAddWork();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.folder_outlined,
                color: AppColors.primaryDark,
              ),
              title: Text(context.tr('portfolio.add_collection')),
              onTap: () {
                Navigator.pop(context);
                _onAddCollection();
              },
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteItem(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('portfolio.delete_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.deletePortfolioItem(item['_id'] as String);
      _load();
    } catch (_) {
      if (!mounted) return;
      UIUtils.showSnackBar(context: context, message: context.tr('error'));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.tr('portfolio.title')),
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: _isLoading ? null : _showAddMenu,
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _isLoading ? null : _showAddMenu,
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, style: const TextStyle(color: Colors.red)),
                SizedBox(height: 12.h),
                FilledButton(
                  onPressed: _load,
                  child: Text(context.tr('retry')),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: EdgeInsets.only(bottom: 96.h),
              children: [
                _buildCollectionsSection(),
                SizedBox(height: 24.h),
                _buildItemsHeader(),
                if (_items.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 24.h),
                    child: AppEmptyState(
                      icon: Icons.workspaces_outline,
                      title: context.tr('portfolio.empty_items'),
                      subtitle: context.tr('portfolio.empty_items_hint'),
                    ),
                  )
                else
                  _buildItemsGrid(),
              ],
            ),
          ),
  );

  Widget _buildCollectionsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
        child: Text(
          context.tr('portfolio.collections'),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
      ),
      if (_collections.isEmpty)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            context.tr('portfolio.empty_collections'),
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 14.sp,
            ),
          ),
        )
      else
        SizedBox(
          height: 96.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _collections.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final collection = _collections[index];
              final items = collection['items'] as List? ?? [];
              return InkWell(
                onLongPress: () => _deleteCollection(collection),
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  width: 220.w,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: context.colors.chipUnselected,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder,
                        color: AppColors.primaryDark,
                        size: 32.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              collection['name'] as String? ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${items.length}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
    ],
  );

  Future<void> _deleteCollection(Map<String, dynamic> collection) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('portfolio.delete_collection_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.deletePortfolioCollection(collection['_id'] as String);
      _load();
    } catch (_) {
      if (!mounted) return;
      UIUtils.showSnackBar(context: context, message: context.tr('error'));
    }
  }

  Widget _buildItemsHeader() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.tr('portfolio.items'),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    ),
  );

  Widget _buildItemsGrid() => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 0.78,
    ),
    itemCount: _items.length,
    itemBuilder: (context, index) {
      final item = _items[index];
      final cover = _coverOf(item);
      return InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRouter.portfolioItem,
          arguments: item['_id'] as String,
        ),
        onLongPress: () => _deleteItem(item),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: context.colors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: cover.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: cover,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorWidget: (_, __, ___) => _coverPlaceholder(item),
                        placeholder: (_, __) => _coverPlaceholder(item),
                      )
                    : _coverPlaceholder(item),
              ),
              Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String? ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['category'] as String? ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.favorite,
                          size: 14.sp,
                          color: Colors.redAccent,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${(item['likes'] as List?)?.length ?? 0}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _coverPlaceholder(Map<String, dynamic> item) {
    final icon = (item['media'] as List?)?.isNotEmpty == true
        ? Icons.ondemand_video
        : Icons.workspaces_outline;
    return ColoredBox(
      color: context.colors.surfaceMuted,
      child: Icon(icon, size: 40.sp, color: context.colors.textHint),
    );
  }
}
