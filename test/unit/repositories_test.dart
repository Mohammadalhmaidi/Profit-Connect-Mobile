import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:profit_connect_mobile/core/error/failures.dart';
import 'package:profit_connect_mobile/core/network/network_info.dart';
import 'package:profit_connect_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:profit_connect_mobile/features/auth/data/models/user_model.dart';
import 'package:profit_connect_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:profit_connect_mobile/features/company/data/datasources/company_remote_data_source.dart';
import 'package:profit_connect_mobile/features/company/data/models/company_model.dart';
import 'package:profit_connect_mobile/features/company/data/repositories/company_repository_impl.dart';
import 'package:profit_connect_mobile/features/feed/data/datasources/post_remote_data_source.dart';
import 'package:profit_connect_mobile/features/feed/data/models/post_model.dart';
import 'package:profit_connect_mobile/features/feed/data/repositories/post_repository_impl.dart';
import 'package:profit_connect_mobile/features/feed/domain/entities/post_entity.dart';
import 'package:profit_connect_mobile/features/jobs/data/datasources/jobs_remote_data_source.dart';
import 'package:profit_connect_mobile/features/jobs/data/models/job_model.dart';
import 'package:profit_connect_mobile/features/jobs/data/repositories/jobs_repository_impl.dart';

class _MockNetworkInfo extends Mock implements NetworkInfo {}

class _MockAuthDS extends Mock implements AuthRemoteDataSource {}

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

class _MockPostDS extends Mock implements PostRemoteDataSource {}

class _MockCompanyDS extends Mock implements CompanyRemoteDataSource {}

class _MockJobsDS extends Mock implements JobsRemoteDataSource {}

void main() {
  group('AuthRepositoryImpl', () {
    late _MockNetworkInfo networkInfo;
    late _MockAuthDS ds;
    late _MockSecureStorage storage;
    late AuthRepositoryImpl repo;

    setUp(() {
      networkInfo = _MockNetworkInfo();
      ds = _MockAuthDS();
      storage = _MockSecureStorage();
      repo = AuthRepositoryImpl(
        remoteDataSource: ds,
        secureStorage: storage,
        networkInfo: networkInfo,
      );
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
    });

    test('login ينقل إلى مصدر البيانات ويعيد المستخدم', () async {
      when(
        () => ds.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async =>
            const UserModel(id: 'u1', email: 'a@b.com', fullName: 'A B'),
      );

      final result = await repo.login(
        email: 'a@b.com',
        password: 'Password123',
      );

      expect(result.isRight(), isTrue);
      verify(
        () => ds.login(email: 'a@b.com', password: 'Password123'),
      ).called(1);
    });

    test('بدون اتصال يعيد ConnectionFailure', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repo.login(email: 'a', password: 'b');

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), isA<ConnectionFailure>());
    });

    test('signup ينقل البيانات إلى مصدر البيانات', () async {
      when(
        () => ds.signup(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          role: any(named: 'role'),
          skills: any(named: 'skills'),
          phoneNumber: any(named: 'phoneNumber'),
          industry: any(named: 'industry'),
          companyName: any(named: 'companyName'),
          companyDescription: any(named: 'companyDescription'),
          companyIndustry: any(named: 'companyIndustry'),
          companyLocation: any(named: 'companyLocation'),
          avatarPath: any(named: 'avatarPath'),
          gender: any(named: 'gender'),
        ),
      ).thenAnswer(
        (_) async =>
            const UserModel(id: 'u2', email: 'b@c.com', fullName: 'B C'),
      );

      final result = await repo.signup(
        firstName: 'B',
        lastName: 'C',
        email: 'b@c.com',
        password: 'Password123',
        role: 'JobSeeker',
        skills: ['Flutter'],
        gender: 'male',
      );

      expect(result.isRight(), isTrue);
      verify(
        () => ds.signup(
          firstName: 'B',
          lastName: 'C',
          email: 'b@c.com',
          password: 'Password123',
          role: 'JobSeeker',
          skills: ['Flutter'],
          gender: 'male',
        ),
      ).called(1);
    });

    test('getCurrentUser يعيد المستخدم', () async {
      when(() => ds.getCurrentUser()).thenAnswer(
        (_) async =>
            const UserModel(id: 'u1', email: 'a@b.com', fullName: 'A B'),
      );

      final result = await repo.getCurrentUser();

      expect(result.isRight(), isTrue);
    });

    test(
      'saveToken/getToken/logout/isUserLoggedIn عبر التخزين الآمن',
      () async {
        when(
          () => storage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => storage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => 'tok');
        when(
          () => storage.delete(key: any(named: 'key')),
        ).thenAnswer((_) async {});

        await repo.saveToken('tok');
        verify(() => storage.write(key: 'auth_token', value: 'tok')).called(1);

        final token = await repo.getToken();
        expect(token, 'tok');

        expect(await repo.isUserLoggedIn(), isTrue);

        await repo.logout();
        verify(() => storage.delete(key: 'auth_token')).called(1);
      },
    );
  });

  group('PostRepositoryImpl', () {
    late _MockNetworkInfo networkInfo;
    late _MockPostDS ds;
    late PostRepositoryImpl repo;

    setUp(() {
      registerFallbackValue(PostType.normal);
      networkInfo = _MockNetworkInfo();
      ds = _MockPostDS();
      repo = PostRepositoryImpl(remoteDataSource: ds, networkInfo: networkInfo);
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
    });

    test('getPosts ينقل الصفحة والحد', () async {
      when(
        () => ds.getPosts(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => <PostModel>[]);

      final result = await repo.getPosts(page: 2, limit: 20);

      expect(result.isRight(), isTrue);
      verify(() => ds.getPosts(page: 2, limit: 20)).called(1);
    });

    test('getPostById يعيد المنشور', () async {
      when(() => ds.getPostById('p1')).thenAnswer(
        (_) async => PostModel(
          id: 'p1',
          userId: 'u1',
          userName: 'A',
          userRole: 'JobSeeker',
          userAvatar: '',
          content: 'hi',
          createdAt: DateTime(2026),
        ),
      );

      final result = await repo.getPostById('p1');

      expect(result.isRight(), isTrue);
    });

    test('toggleLike يعيد void', () async {
      when(() => ds.toggleLike('p1')).thenAnswer((_) async {});

      final result = await repo.toggleLike('p1');

      expect(result.isRight(), isTrue);
      verify(() => ds.toggleLike('p1')).called(1);
    });

    test('addComment ينقل التعليق', () async {
      when(
        () => ds.addComment(
          postId: any(named: 'postId'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) async => <String, dynamic>{'success': true});

      final result = await repo.addComment(postId: 'p1', comment: 'nice');

      expect(result.isRight(), isTrue);
      verify(() => ds.addComment(postId: 'p1', comment: 'nice')).called(1);
    });

    test('createPost ينقل المحتوى', () async {
      when(
        () => ds.createPost(
          content: any(named: 'content'),
          hashtags: any(named: 'hashtags'),
          mediaUrl: any(named: 'mediaUrl'),
          videoUrl: any(named: 'videoUrl'),
          imagePath: any(named: 'imagePath'),
          videoPath: any(named: 'videoPath'),
          postType: any(named: 'postType'),
          budget: any(named: 'budget'),
          deadline: any(named: 'deadline'),
        ),
      ).thenAnswer(
        (_) async => PostModel(
          id: 'p2',
          userId: 'u1',
          userName: 'A',
          userRole: 'JobSeeker',
          userAvatar: '',
          content: 'new',
          createdAt: DateTime(2026),
        ),
      );

      final result = await repo.createPost(content: 'new');

      expect(result.isRight(), isTrue);
      verify(
        () => ds.createPost(content: 'new', hashtags: <String>[]),
      ).called(1);
    });
  });

  group('CompanyRepositoryImpl', () {
    late _MockNetworkInfo networkInfo;
    late _MockCompanyDS ds;
    late CompanyRepositoryImpl repo;

    setUp(() {
      networkInfo = _MockNetworkInfo();
      ds = _MockCompanyDS();
      repo = CompanyRepositoryImpl(
        remoteDataSource: ds,
        networkInfo: networkInfo,
      );
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
    });

    test('createCompany ينقل البيانات', () async {
      when(
        () => ds.createCompany(any()),
      ).thenAnswer((_) async => const CompanyModel(id: 'c1', name: 'Co'));

      final result = await repo.createCompany(name: 'Co', industry: 'Tech');

      expect(result.isRight(), isTrue);
    });

    test('getCompany يجلب الشركة بالمعرف', () async {
      when(
        () => ds.getCompany('c1'),
      ).thenAnswer((_) async => const CompanyModel(id: 'c1', name: 'Co'));

      final result = await repo.getCompany('c1');

      expect(result.isRight(), isTrue);
      verify(() => ds.getCompany('c1')).called(1);
    });

    test('updateCompany يرسل الحقول الموجودة فقط', () async {
      when(
        () => ds.updateCompany(any(), any()),
      ).thenAnswer((_) async => const CompanyModel(id: 'c1', name: 'Co'));

      final result = await repo.updateCompany(companyId: 'c1', name: 'New');

      expect(result.isRight(), isTrue);
      final captured =
          verify(() => ds.updateCompany('c1', captureAny())).captured.single
              as Map<String, dynamic>;
      expect(captured, {'name': 'New'});
    });
  });

  group('JobsRepositoryImpl', () {
    test('getJobs ينقل الفلاتر', () async {
      final networkInfo = _MockNetworkInfo();
      final ds = _MockJobsDS();
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => ds.getJobs(
          search: any(named: 'search'),
          type: any(named: 'type'),
          workPlace: any(named: 'workPlace'),
          workLevel: any(named: 'workLevel'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => <JobModel>[]);
      final repo = JobsRepositoryImpl(
        remoteDataSource: ds,
        networkInfo: networkInfo,
      );

      final result = await repo.getJobs(search: 'flutter');

      expect(result.isRight(), isTrue);
      verify(() => ds.getJobs(search: 'flutter')).called(1);
    });
  });
}
