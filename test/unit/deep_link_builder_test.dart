import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/core/constants/app_constants.dart';
import 'package:profit_connect_mobile/core/deep_linking/deep_link_builder.dart';

void main() {
  group('DeepLinkBuilder', () {
    test('يربط الروابط بالنطاق المسجل في التطبيق', () {
      expect(
        DeepLinkBuilder.post('abc123'),
        '${AppConstants.deepLinkScheme}://${AppConstants.deepLinkHost}/post/abc123',
      );
      expect(
        DeepLinkBuilder.profile('u1'),
        '${AppConstants.deepLinkScheme}://${AppConstants.deepLinkHost}/profile/u1',
      );
      expect(
        DeepLinkBuilder.job('j9'),
        '${AppConstants.deepLinkScheme}://${AppConstants.deepLinkHost}/job/j9',
      );
      expect(
        DeepLinkBuilder.chat('c77'),
        '${AppConstants.deepLinkScheme}://${AppConstants.deepLinkHost}/chat/c77',
      );
    });

    test('النطاق يطابق إعدادات المنصة', () {
      expect(AppConstants.deepLinkScheme, 'profitconnect');
      expect(AppConstants.deepLinkHost, 'app.profitconnect.com');
    });
  });
}
