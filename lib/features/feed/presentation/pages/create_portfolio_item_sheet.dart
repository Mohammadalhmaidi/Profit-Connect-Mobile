import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../api_service.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../l10n/app_localizations.dart';

/// ورقة إضافة عمل جديد إلى المعرض (رفع وسائط + حقول).
class CreatePortfolioItemSheet extends StatefulWidget {
  const CreatePortfolioItemSheet({super.key});

  @override
  State<CreatePortfolioItemSheet> createState() =>
      _CreatePortfolioItemSheetState();
}

class _CreatePortfolioItemSheetState extends State<CreatePortfolioItemSheet> {
  final _api = sl<ApiService>();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _clientController = TextEditingController();
  final _durationController = TextEditingController();
  final _roleController = TextEditingController();
  final _urlController = TextEditingController();
  final _tagsController = TextEditingController();
  final List<XFile> _media = [];
  bool _isPublic = true;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _myProjects = [];
  String? _linkedProjectId;

  @override
  void initState() {
    super.initState();
    _loadMyProjects();
  }

  Future<void> _loadMyProjects() async {
    try {
      final res = await _api.getProjects(
        params: {'mine': 'true', 'status': 'all', 'limit': '50'},
      );
      final list = res.data is Map
          ? (res.data as Map)['data'] as List<dynamic>?
          : null;
      if (!mounted || list == null) return;
      setState(() {
        _myProjects = list
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      });
    } catch (_) {
      // تجاهل فشل جلب المشاريع — الربط اختياري
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _clientController.dispose();
    _durationController.dispose();
    _roleController.dispose();
    _urlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final picked = await _imagePicker.pickMultiImage();
    final remaining = 12 - _media.length;
    if (picked.isNotEmpty) {
      setState(() {
        _media.addAll(picked.take(remaining));
      });
      if (picked.length > remaining) {
        if (!mounted) return;
        SnackBarUtils.showError(context, context.tr('portfolio.create_media'));
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_media.isEmpty) {
      SnackBarUtils.showError(context, context.tr('portfolio.create_media'));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final files = <MultipartFile>[];
      for (final file in _media) {
        final isVideo =
            file.name.toLowerCase().endsWith('.mp4') ||
            file.name.toLowerCase().endsWith('.mov') ||
            file.name.toLowerCase().endsWith('.mkv');
        files.add(
          await MultipartFile.fromFile(
            file.path,
            filename: file.name,
            contentType: isVideo
                ? DioMediaType('video', 'mp4')
                : DioMediaType('image', 'jpeg'),
          ),
        );
      }
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      await _api.createPortfolioItem(
        title: _titleController.text.trim(),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        tags: tags,
        client: _clientController.text.trim(),
        duration: _durationController.text.trim(),
        role: _roleController.text.trim(),
        projectUrl: _urlController.text.trim(),
        visibility: _isPublic ? 'public' : 'private',
        linkedProject: _linkedProjectId,
        media: files,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      SnackBarUtils.showError(context, context.tr('error'));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                context.tr('portfolio.add_work'),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: context.tr('portfolio.create_title'),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? context.tr('required_field')
                  : null,
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: context.tr('portfolio.create_category'),
                hintText: context.tr('portfolio.create_category_hint'),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? context.tr('required_field')
                  : null,
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: context.tr('portfolio.create_desc'),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _clientController,
                    decoration: InputDecoration(
                      labelText: context.tr('portfolio.create_client'),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    decoration: InputDecoration(
                      labelText: context.tr('portfolio.create_duration'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _roleController,
                    decoration: InputDecoration(
                      labelText: context.tr('portfolio.create_role'),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextFormField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: context.tr('portfolio.create_url'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: context.tr('portfolio.create_tags'),
              ),
            ),
            if (_myProjects.isNotEmpty) ...[
              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                initialValue: _linkedProjectId,
                decoration: InputDecoration(
                  labelText: context.tr('portfolio.link_project'),
                ),
                hint: Text(context.tr('portfolio.link_project_hint')),
                items: _myProjects
                    .map(
                      (p) => DropdownMenuItem<String>(
                        value: (p['_id'] ?? p['id']).toString(),
                        child: Text(
                          (p['title'] as String?) ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _linkedProjectId = v),
              ),
            ],
            SizedBox(height: 16.h),
            Text(
              context.tr('portfolio.create_media'),
              style: TextStyle(
                fontSize: 13.sp,
                color: context.colors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final file in _media)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child:
                            file.name.toLowerCase().endsWith('.mp4') ||
                                file.name.toLowerCase().endsWith('.mov')
                            ? Container(
                                width: 64.w,
                                height: 64.w,
                                color: context.colors.surfaceMuted,
                                child: const Icon(
                                  Icons.videocam,
                                  color: Colors.grey,
                                ),
                              )
                            : Image.file(
                                File(file.path),
                                width: 64.w,
                                height: 64.w,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => setState(() => _media.remove(file)),
                          child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.black54,
                            child: Icon(
                              Icons.close,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (_media.length < 12)
                  InkWell(
                    onTap: _pickMedia,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: BoxDecoration(
                        border: Border.all(color: context.colors.inputBorder),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: true,
                        label: Text(
                          context.tr('portfolio.create_visibility_public'),
                        ),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text(
                          context.tr('portfolio.create_visibility_private'),
                        ),
                      ),
                    ],
                    selected: {_isPublic},
                    onSelectionChanged: (s) =>
                        setState(() => _isPublic = s.first),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        context.tr('common.submit'),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
