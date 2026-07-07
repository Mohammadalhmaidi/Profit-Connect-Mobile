import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/connection_request_card.dart';
import '../widgets/connection_grid_card.dart';
import '../../../feed/presentation/widgets/post_card.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  bool _showAllRequests = false;
  String _searchQuery = "";
  bool _isSearchActive = false;

  final List<Map<String, String>> _requests = [
    {'name': 'Jane Doe', 'role': 'Product Manager at TechCo', 'mutual': '23 mutual connections', 'image': 'https://i.pravatar.cc/150?u=jane'},
    {'name': 'Mark Zuckerberg', 'role': 'Director of Engineering', 'mutual': '5 mutual connections', 'image': 'https://i.pravatar.cc/150?u=mark'},
    {'name': 'Elon Musk', 'role': 'Chief Engineer at SpaceX', 'mutual': '12 mutual connections', 'image': 'https://i.pravatar.cc/150?u=elon'},
  ];

  final List<Map<String, dynamic>> _allConnections = [
    {'name': 'John Smith', 'role': 'Senior Developer at Amazon', 'image': 'https://i.pravatar.cc/150?u=john', 'isOnline': true},
    {'name': 'Sarah Lee', 'role': 'UX Designer at Creative Studio', 'image': 'https://i.pravatar.cc/150?u=sarah', 'isOnline': false},
    {'name': 'Mike Ross', 'role': 'Legal Consultant & Advisor', 'image': 'https://i.pravatar.cc/150?u=mike', 'isOnline': false},
    {'name': 'Dr. Emily Chen', 'role': 'Professor of Computer Science', 'image': 'https://i.pravatar.cc/150?u=emily', 'isOnline': true},
  ];

  List<Map<String, dynamic>> get _filteredConnections {
    if (_searchQuery.isEmpty) return _allConnections;
    return _allConnections.where((c) => c['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _isSearchActive 
          ? TextField(
              autofocus: true,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(hintText: 'Search connections...', border: InputBorder.none),
            )
          : Text('My Network', style: TextStyle(color: AppColors.textPrimary, fontSize: 20.sp, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isSearchActive ? Icons.close : Icons.search, color: AppColors.textPrimary),
            onPressed: () => setState(() {
              _isSearchActive = !_isSearchActive;
              if (!_isSearchActive) _searchQuery = "";
            }),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isSearchActive) ...[
              _buildSectionHeader(
                title: 'Connection Requests',
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(color: AppColors.primaryDark.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
                  child: Text('3 NEW', style: TextStyle(color: AppColors.primaryDark, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 12.h),
              AnimatedSize(
                duration: 300.ms,
                child: Column(
                  children: _requests.take(_showAllRequests ? _requests.length : 2).map((req) => ConnectionRequestCard(
                    name: req['name']!, role: req['role']!, mutualConnections: req['mutual']!, imageUrl: req['image']!, onAccept: () {}, onIgnore: () {},
                  )).toList(),
                ),
              ),
              if (!_showAllRequests && _requests.length > 2)
                Center(child: TextButton(
                  onPressed: () => setState(() => _showAllRequests = true),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [Text('Show more', style: TextStyle(fontWeight: FontWeight.bold)), Icon(Icons.keyboard_arrow_down)]),
                )),
              SizedBox(height: 24.h),
            ],

            _buildSectionHeader(
              title: 'Your Connections',
              trailing: Text('${_filteredConnections.length} results', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
            ),
            SizedBox(height: 12.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 12.w, mainAxisSpacing: 12.h,
              ),
              itemCount: _filteredConnections.length,
              itemBuilder: (context, index) {
                final conn = _filteredConnections[index];
                return ConnectionGridCard(name: conn['name'], role: conn['role'], imageUrl: conn['image'], isOnline: conn['isOnline']);
              },
            ),
            
            if (_searchQuery.isEmpty) ...[
              SizedBox(height: 32.h),
              Text('Trending in your network', style: TextStyle(color: AppColors.primaryDark, fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              const PostCard(
                userName: 'Sarah Lee', userRole: 'UX Designer', userAvatar: 'https://i.pravatar.cc/150?u=sarah', timeAgo: '1h',
                content: 'Workshop on accessibility was amazing! 🎨✨', hashtags: ['#UX', '#Design'], mediaUrl: 'https://images.unsplash.com/photo-1558655146-d09347e92766?q=80&w=500',
                likes: '124', comments: '12',
              ),
            ],
            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required Widget trailing}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: TextStyle(color: AppColors.primaryDark, fontSize: 18.sp, fontWeight: FontWeight.bold)),
      trailing,
    ]);
  }
}
