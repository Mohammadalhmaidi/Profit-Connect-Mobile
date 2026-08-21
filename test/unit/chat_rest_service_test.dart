import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/features/messages/data/services/chat_rest_service.dart';

Response _ok(Map<String, dynamic> data) => Response(
  requestOptions: RequestOptions(path: '/'),
  statusCode: 200,
  data: data,
);

Map<String, dynamic> _messageJson(String id, String sender, String content) => {
  '_id': id,
  'sender': {'_id': sender},
  'content': content,
  'createdAt': '2026-01-01T10:00:00.000Z',
  'isRead': false,
};

class _ChatFakeApi extends ApiService {
  Map<String, List<Map<String, dynamic>>> byConversation = {};
  bool throwOnSend = false;
  int sendCalls = 0;

  @override
  Future<Response> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async => _ok({'data': byConversation[conversationId] ?? []});

  @override
  Future<Response> sendMessage(String conversationId, String content) async {
    sendCalls++;
    if (throwOnSend) {
      throw DioException(requestOptions: RequestOptions(path: '/'));
    }
    return _ok({'success': true});
  }
}

void main() {
  group('ChatRestService', () {
    late _ChatFakeApi api;

    setUp(() {
      api = _ChatFakeApi();
    });

    test('يبث الرسائل فور بدء الاستطلاع', () async {
      api.byConversation['c1'] = [_messageJson('m1', 'peer', 'مرحبا')];
      final service = ChatRestService(api);
      final emitted = <List<ChatMessage>>[];
      final sub = service.messages.listen(emitted.add);

      service.startPolling(conversationId: 'c1', userId: 'me');
      // انتظار اكتمال أول جلب
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(emitted.isNotEmpty, isTrue);
      expect(emitted.last.first.content, 'مرحبا');
      await sub.cancel();
      service.dispose();
    });

    test('كل خدمة تعزل استطلاعها عن الأخرى (لا خطف polling)', () async {
      api.byConversation['cA'] = [_messageJson('m1', 'peerA', 'رسالة أ')];
      api.byConversation['cB'] = [_messageJson('m2', 'peerB', 'رسالة ب')];

      final serviceA = ChatRestService(api);
      final serviceB = ChatRestService(api);
      final emittedA = <List<ChatMessage>>[];
      final emittedB = <List<ChatMessage>>[];
      final subA = serviceA.messages.listen(emittedA.add);
      final subB = serviceB.messages.listen(emittedB.add);

      serviceA.startPolling(conversationId: 'cA', userId: 'me');
      serviceB.startPolling(conversationId: 'cB', userId: 'me');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(emittedA.isNotEmpty, isTrue);
      expect(emittedB.isNotEmpty, isTrue);
      expect(emittedA.last.first.content, 'رسالة أ');
      expect(emittedB.last.first.content, 'رسالة ب');

      await subA.cancel();
      await subB.cancel();
      serviceA.dispose();
      serviceB.dispose();
    });

    test('sendMessage يعيد رمي خطأ الشبكة (ليظهر في واجهة المستخدم)', () async {
      api.throwOnSend = true;
      final service = ChatRestService(api);

      expect(
        () => service.sendMessage('c1', 'نص'),
        throwsA(isA<DioException>()),
      );
      service.dispose();
    });

    test('sendMessage الناجح يمسح الكاش ويستطلع فورًا', () async {
      api.byConversation['c1'] = [_messageJson('m1', 'peer', 'قديمة')];
      final service = ChatRestService(api);
      final emitted = <List<ChatMessage>>[];
      final sub = service.messages.listen(emitted.add);

      service.startPolling(conversationId: 'c1', userId: 'me');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final firstLength = emitted.last.length;

      api.byConversation['c1'] = [
        _messageJson('m1', 'peer', 'قديمة'),
        _messageJson('m2', 'me', 'جديدة'),
      ];
      await service.sendMessage('c1', 'جديدة');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(api.sendCalls, 1);
      expect(emitted.last.length, greaterThan(firstLength));

      await sub.cancel();
      service.dispose();
    });

    test('dispose يغلق الدفق ولا يتلقى أي إصدار بعدها', () async {
      api.byConversation['c1'] = [_messageJson('m1', 'peer', 'نص')];
      final service = ChatRestService(api);
      final emitted = <List<ChatMessage>>[];
      final sub = service.messages.listen(emitted.add);

      service.startPolling(conversationId: 'c1', userId: 'me');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final before = emitted.length;

      service.dispose();
      api.byConversation['c1'] = [
        _messageJson('m1', 'peer', 'نص'),
        _messageJson('m2', 'peer', 'لاحق'),
      ];
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(emitted.length, before);
      await sub.cancel();
    });
  });
}
