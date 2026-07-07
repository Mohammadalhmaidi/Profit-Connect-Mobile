import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../widgets/message_list_tile.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  String _searchQuery = "";
  
  final List<Map<String, dynamic>> _allMessages = [
    {
      'name': 'Sarah Jenkins',
      'message': 'I saw your profile and thought...',
      'time': '2m ago',
      'imageUrl': 'https://i.pravatar.cc/150?u=sarah',
      'isUnread': true,
      'isOnline': true,
    },
    {
      'name': 'David Chen',
      'message': 'Thanks for the advice on the...',
      'time': '1h ago',
      'imageUrl': 'https://i.pravatar.cc/150?u=david',
      'isOnline': true,
    },
    {
      'name': 'CareerPath Team',
      'message': 'Welcome to the premium...',
      'time': 'Yesterday',
      'leading': Icon(Icons.shield, color: Colors.white, size: 24.sp),
    },
    {
      'name': 'Marcus Thompson',
      'message': 'The workshop next Tuesday is...',
      'time': 'Tuesday',
      'imageUrl': 'https://i.pravatar.cc/150?u=marcus',
    },
    {
      'name': 'Elena Rodriguez',
      'message': 'Can we reschedule our sync?',
      'time': 'Oct 24',
      'imageUrl': 'https://i.pravatar.cc/150?u=elena',
    },
  ];

  List<Map<String, dynamic>> get _filteredMessages {
    if (_searchQuery.isEmpty) return _allMessages;
    return _allMessages
        .where((m) => m['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leadingWidth: 64.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRouter.profile),
            child: CircleAvatar(
              radius: 20.r,
              backgroundColor: const Color(0xFFF3E5D8),
              child: Icon(Icons.person, color: Colors.white, size: 24.sp),
            ),
          ),
        ),
        title: Text(
          'Messages',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: AppColors.primaryDark, size: 28.sp),
            onPressed: () => Navigator.pushNamed(context, AppRouter.settings),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          // Functional Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  hintStyle: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(Icons.search, color: AppColors.textHint, size: 22.sp),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ),
          
          // Messages List
          Expanded(
            child: ListView.builder(
              itemCount: _filteredMessages.length,
              itemBuilder: (context, index) {
                final msg = _filteredMessages[index];
                return MessageListTile(
                  name: msg['name'],
                  message: msg['message'],
                  time: msg['time'],
                  imageUrl: msg['imageUrl'],
                  leading: msg['leading'],
                  isUnread: msg['isUnread'] ?? false,
                  isOnline: msg['isOnline'] ?? false,
                  onTap: () => Navigator.pushNamed(
                    context, 
                    AppRouter.chat, 
                    arguments: msg['name'], // Passes the dynamic name
                  ),
                  onProfileTap: () => Navigator.pushNamed(
                    context, 
                    AppRouter.profile, 
                    arguments: msg['name'], // Correctly redirects to public profile
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.accentCyan,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
        child: Icon(Icons.edit_square, color: Colors.white, size: 28.sp),
      ),
    );
  }
}
