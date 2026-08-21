import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../deep_linking/deep_link_builder.dart';
import '../di/dependency_injection.dart';
import '../../api_service.dart';

class PostInteractions {
  static void copyPostLink(BuildContext context, String postId) {
    final link = DeepLinkBuilder.post(postId);
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  static Future<String?> translateContent(String text) async {
    try {
      final api = sl<ApiService>();
      final response = await api.translate(text);
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;
      return data?['translated'] as String?;
    } catch (e) {
      debugPrint('Translation error: $e');
      return null;
    }
  }

  static Future<void> rateCompany({
    required String companyId,
    required int rating,
    String? review,
  }) async {
    try {
      final api = sl<ApiService>();
      await api.rateCompany(companyId, rating, review: review);
    } catch (e) {
      debugPrint('RateCompany error: $e');
    }
  }
}
