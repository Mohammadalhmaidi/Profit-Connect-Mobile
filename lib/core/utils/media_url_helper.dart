import '../../api_service.dart';

class MediaUrlHelper {
  static String resolve(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '${ApiService.baseUrl}/$url';
  }
}