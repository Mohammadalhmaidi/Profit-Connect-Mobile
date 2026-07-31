import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';

class ChatBubble extends StatelessWidget {
  final String? message;
  final String time;
  final bool isSender;
  final bool isLastInGroup;
  final String? avatarUrl;
  final bool isFile;
  final String? fileName;
  final String? fileSize;
  final bool isTyping;

  const ChatBubble({
    super.key,
    this.message,
    required this.time,
    this.isSender = false,
    this.isLastInGroup = false,
    this.avatarUrl,
    this.isFile = false,
    this.fileName,
    this.fileSize,
    this.isTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLastInGroup ? 16.h : 4.h),
      child: Row(
        mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSender) ...[
            if (isLastInGroup && avatarUrl != null)
              CircleAvatar(
                radius: 16.r,
                backgroundImage: CachedNetworkImageProvider(avatarUrl!),
              )
            else
              SizedBox(width: 32.w),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSender ? AppColors.accentCyan : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: Radius.circular(isSender ? 16.r : (isLastInGroup ? 4.r : 16.r)),
                      bottomRight: Radius.circular(isSender ? (isLastInGroup ? 4.r : 16.r) : 16.r),
                    ),
                    boxShadow: [
                      if (!isSender)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                    ],
                    border: !isSender ? Border.all(color: AppColors.fieldBackground) : null,
                  ),
                  child: isTyping
                      ? _buildTypingIndicator()
                      : isFile
                          ? _buildFileAttachment()
                          : Text(
                              message ?? '',
                              style: TextStyle(
                                color: isSender ? Colors.white : AppColors.textPrimary,
                                fontSize: 15.sp,
                                height: 1.4,
                              ),
                            ),
                ),
                if (isLastInGroup && !isTyping) ...[
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 11.sp,
                        ),
                      ),
                      if (isSender) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.done_all,
                          size: 14.sp,
                          color: AppColors.accentCyan,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (isSender) SizedBox(width: 16.w),
        ],
      ),
    );
  }

  Widget _buildFileAttachment() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(Icons.insert_drive_file, color: Colors.white, size: 24.sp),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fileName ?? 'File',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            Text(
              fileSize ?? '',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            color: AppColors.textHint.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
