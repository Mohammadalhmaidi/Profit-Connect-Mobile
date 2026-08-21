import 'dart:math';

/// توليد كلمات مرور مؤقتة آمنة عشوائيًا (للحسابات التي ينشئها المدير مثل الموظفين).
class TempPasswordGenerator {
  static const String _upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const String _lower = 'abcdefghijkmnpqrstuvwxyz';
  static const String _digits = '23456789';
  static const String _alphabet = '$_upper$_lower$_digits';
  static const int _length = 12;

  /// كلمة مرور عشوائية آمنة من 12 حرفًا (بدون رموز ملتبسة مثل I/l/1/0/O).
  /// تضمن احتواءها على حرف كبير ورقم وحرف صغير — مطابقة لسياسة كلمة المرور.
  static String generate({Random? random}) {
    final rng = random ?? Random.secure();
    final chars = <String>[
      _upper[rng.nextInt(_upper.length)],
      _lower[rng.nextInt(_lower.length)],
      _digits[rng.nextInt(_digits.length)],
      ...List.generate(
        _length - 3,
        (_) => _alphabet[rng.nextInt(_alphabet.length)],
      ),
    ];
    chars.shuffle(rng);
    return chars.join();
  }
}
