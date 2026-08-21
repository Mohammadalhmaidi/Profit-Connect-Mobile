import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// يكتم أخطاء NetworkImage في الاختبارات حتى لا تفسد نتيجة الاختبار
/// بسبب HttpClient في بيئة flutter_test.
/// يُرجى استدعاؤها في بداية كل دالة testWidgets تعرض صورًا شبكية.
void silenceImageErrors() {
  final prev = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception is NetworkImageLoadException) return;
    prev?.call(details);
  };
  addTearDown(() {
    FlutterError.onError = prev;
  });
}

/// يحمّل خطًا حقيقيًا بدل خط Ahem في flutter_test (كل حرف فيه بعرض حجم الخط،
/// ما يجعل النصوص أعرض بمرتين ويسبب فوائض وهمية في التخطيط).
/// استدعِها في setUpAll قبل أي testWidgets في الملفات المعرضة للفوائض.
Future<void> loadRealFont() async {
  final file = File('test/fonts/segui.ttf');
  final bytes = await file.readAsBytes();
  final loader = FontLoader('Roboto')
    ..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}
