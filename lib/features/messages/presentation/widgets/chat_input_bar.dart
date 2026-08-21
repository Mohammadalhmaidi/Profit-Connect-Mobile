import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';

class ChatInputBar extends StatefulWidget {
  final void Function(String content)? onSend;

  const ChatInputBar({super.key, this.onSend});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    _controller.clear();
    widget.onSend?.call(content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    decoration: BoxDecoration(
      color: context.colors.surface,
      border: Border(
        top: BorderSide(color: context.colors.divider, width: 1.w),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: context.colors.surfaceMuted,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: TextField(
              controller: _controller,
              style: TextStyle(color: context.colors.textPrimary),
              decoration: InputDecoration(
                hintText: context.tr('messages.write_message'),
                hintStyle: TextStyle(
                  color: context.colors.textHint,
                  fontSize: 15.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: _submit,
          child: Icon(Icons.send, color: AppColors.accentCyan, size: 28.sp),
        ),
      ],
    ),
  );
}
