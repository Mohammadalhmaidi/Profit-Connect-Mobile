import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';

class ChatPage extends StatelessWidget {
  final String userName;

  const ChatPage({super.key, this.userName = 'Sarah Jenkins'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=sarah'),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'SENIOR PRODUCT DESIGNER',
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: () {},
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              children: [
                _buildDateSeparator('MONDAY, OCT 24'),
                const ChatBubble(
                  message: 'Hi Alex! I saw your recent portfolio update on CareerPath. The fintech case study was impressive.',
                  time: '10:42 AM',
                ),
                const ChatBubble(
                  message: "Would you be open to a quick coffee chat? We're looking for a Design Lead at TechCorp.",
                  time: '10:43 AM',
                  isLastInGroup: true,
                  avatarUrl: 'https://i.pravatar.cc/150?u=sarah',
                ),
                _buildDateSeparator('TODAY'),
                const ChatBubble(
                  isSender: true,
                  message: "Absolutely, Sarah! I'd love to discuss the role and hear more about TechCorp's roadmap. Does Thursday afternoon work for you?",
                  time: '2:15 PM',
                  isLastInGroup: true,
                ),
                const ChatBubble(
                  isSender: true,
                  isFile: true,
                  fileName: 'Alex_Resume_2024.pdf',
                  fileSize: '1.2 MB • PDF',
                  time: '2:16 PM',
                  isLastInGroup: true,
                ),
                const ChatBubble(
                  isTyping: true,
                  time: '',
                  isLastInGroup: true,
                  avatarUrl: 'https://i.pravatar.cc/150?u=sarah',
                ),
              ],
            ),
          ),
          const ChatInputBar(),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(String label) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
