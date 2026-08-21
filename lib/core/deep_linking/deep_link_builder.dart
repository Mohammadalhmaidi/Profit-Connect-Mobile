import '../constants/app_constants.dart';

/// بناء موحد لروابط التطبيق العميقة — يضمن تطابق النطاق مع إعدادات
/// AndroidManifest (profitconnect://app.profitconnect.com) في كل مكان.
class DeepLinkBuilder {
  static String get base =>
      '${AppConstants.deepLinkScheme}://${AppConstants.deepLinkHost}';

  static String post(String postId) => '$base/post/$postId';

  static String profile(String userId) => '$base/profile/$userId';

  static String job(String jobId) => '$base/job/$jobId';

  static String chat(String conversationId) => '$base/chat/$conversationId';
}
