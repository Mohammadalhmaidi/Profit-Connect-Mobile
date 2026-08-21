import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/core/utils/temp_password_generator.dart';

void main() {
  group('TempPasswordGenerator', () {
    test('يولد كلمة مرور من 12 حرفًا', () {
      final password = TempPasswordGenerator.generate();
      expect(password.length, 12);
    });

    test('يستخدم الأبجدية الآمنة فقط (بدون رموز ملتبسة)', () {
      const alphabet =
          'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789';
      final password = TempPasswordGenerator.generate();
      for (final char in password.split('')) {
        expect(alphabet.contains(char), isTrue, reason: 'حرف غير مسموح: $char');
      }
    });

    test('كل توليد يعطي كلمة مرور مختلفة', () {
      final passwords = List.generate(
        20,
        (_) => TempPasswordGenerator.generate(),
      );
      expect(passwords.toSet().length, passwords.length);
    });

    test('يحترم المولد المحقون (للقابلية للاختبار)', () {
      final rng = Random(42);
      final a = TempPasswordGenerator.generate(random: rng);
      final rng2 = Random(42);
      final b = TempPasswordGenerator.generate(random: rng2);
      expect(a, b);
    });

    test('يضمن حرفًا كبيرًا وحرفًا صغيرًا ورقمًا (سياسة كلمة المرور)', () {
      for (var i = 0; i < 50; i++) {
        final password = TempPasswordGenerator.generate(random: Random(i));
        expect(password.length, 12);
        expect(
          RegExp('[A-Z]').hasMatch(password),
          isTrue,
          reason: 'لا يوجد حرف كبير: $password',
        );
        expect(
          RegExp('[a-z]').hasMatch(password),
          isTrue,
          reason: 'لا يوجد حرف صغير: $password',
        );
        expect(
          RegExp('[0-9]').hasMatch(password),
          isTrue,
          reason: 'لا يوجد رقم: $password',
        );
      }
    });
  });
}
