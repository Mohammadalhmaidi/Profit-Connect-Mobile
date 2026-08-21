import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:profit_connect_mobile/core/error/failures.dart';
import 'package:profit_connect_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:profit_connect_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:profit_connect_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:profit_connect_mobile/features/company/domain/entities/company_entity.dart';
import 'package:profit_connect_mobile/features/company/domain/repositories/company_repository.dart';
import 'package:profit_connect_mobile/features/company/domain/usecases/create_company_usecase.dart';
import 'package:profit_connect_mobile/features/feed/domain/entities/post_entity.dart';
import 'package:profit_connect_mobile/features/feed/domain/repositories/post_repository.dart';
import 'package:profit_connect_mobile/features/feed/domain/usecases/add_comment_usecase.dart';
import 'package:profit_connect_mobile/features/feed/domain/usecases/create_post_usecase.dart';
import 'package:profit_connect_mobile/features/feed/domain/usecases/get_post_usecase.dart';
import 'package:profit_connect_mobile/features/feed/domain/usecases/get_posts_usecase.dart';
import 'package:profit_connect_mobile/features/feed/domain/usecases/toggle_like_usecase.dart';
import 'package:profit_connect_mobile/features/jobs/domain/entities/job_entity.dart';
import 'package:profit_connect_mobile/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:profit_connect_mobile/features/jobs/domain/usecases/get_jobs_usecase.dart';

class _MockAuthRepo extends Mock implements AuthRepository {}

class _MockCompanyRepo extends Mock implements CompanyRepository {}

class _MockPostRepo extends Mock implements PostRepository {}

class _MockJobsRepo extends Mock implements JobsRepository {}

void main() {
  group('LoginUseCase', () {
    test('يفوّض للمستودع ويعيد المستخدم', () async {
      final repo = _MockAuthRepo();
      when(
        () => repo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => right(
          const UserEntity(id: 'u1', email: 'a@b.com', fullName: 'A B'),
        ),
      );
      final useCase = LoginUseCase(repo);

      final result = await useCase(
        const LoginParams(email: 'a@b.com', password: 'Password123'),
      );

      expect(result.isRight(), isTrue);
      verify(
        () => repo.login(email: 'a@b.com', password: 'Password123'),
      ).called(1);
    });

    test('يعيد الخطأ عند فشل الدخول', () async {
      final repo = _MockAuthRepo();
      when(
        () => repo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => left(const ServerFailure('خطأ')));
      final useCase = LoginUseCase(repo);

      final result = await useCase(
        const LoginParams(email: 'a@b.com', password: 'wrong'),
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('CreateCompanyUseCase', () {
    test('ينشئ الشركة عبر المستودع', () async {
      final repo = _MockCompanyRepo();
      when(
        () => repo.createCompany(
          name: any(named: 'name'),
          description: any(named: 'description'),
          industry: any(named: 'industry'),
          website: any(named: 'website'),
          location: any(named: 'location'),
          logo: any(named: 'logo'),
        ),
      ).thenAnswer(
        (_) async => right(const CompanyEntity(id: 'c1', name: 'Co')),
      );
      final useCase = CreateCompanyUseCase(repo);

      final result = await useCase(
        const CreateCompanyParams(name: 'Co', industry: 'Tech'),
      );

      expect(result.isRight(), isTrue);
      verify(
        () => repo.createCompany(
          name: 'Co',
          description: any(named: 'description'),
          industry: 'Tech',
          website: any(named: 'website'),
          location: any(named: 'location'),
          logo: any(named: 'logo'),
        ),
      ).called(1);
    });

    test('يعيد الخطأ عند فشل الإنشاء', () async {
      final repo = _MockCompanyRepo();
      when(
        () => repo.createCompany(
          name: any(named: 'name'),
          description: any(named: 'description'),
          industry: any(named: 'industry'),
          website: any(named: 'website'),
          location: any(named: 'location'),
          logo: any(named: 'logo'),
        ),
      ).thenAnswer((_) async => left(const ServerFailure('فشل')));
      final useCase = CreateCompanyUseCase(repo);

      final result = await useCase(const CreateCompanyParams(name: 'Co'));

      expect(result.isLeft(), isTrue);
    });
  });

  group('GetPostsUseCase', () {
    test('يجلب المنشورات بالصفحة والحد', () async {
      final repo = _MockPostRepo();
      when(
        () => repo.getPosts(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => right(<PostEntity>[]));
      final useCase = GetPostsUseCase(repo);

      final result = await useCase(const GetPostsParams(page: 2, limit: 20));

      expect(result.isRight(), isTrue);
      verify(() => repo.getPosts(page: 2, limit: 20)).called(1);
    });

    test('يعيد الخطأ عند فشل الجلب', () async {
      final repo = _MockPostRepo();
      when(
        () => repo.getPosts(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => left(const ServerFailure('فشل')));
      final useCase = GetPostsUseCase(repo);

      final result = await useCase(const GetPostsParams());

      expect(result.isLeft(), isTrue);
    });
  });

  group('GetPostUseCase', () {
    test('يجلب منشورًا بالمعرف', () async {
      final repo = _MockPostRepo();
      when(() => repo.getPostById('p1')).thenAnswer(
        (_) async => right(
          PostEntity(
            id: 'p1',
            userId: 'u1',
            userName: 'A',
            userRole: 'JobSeeker',
            userAvatar: '',
            content: 'hi',
            createdAt: DateTime(2026),
          ),
        ),
      );
      final useCase = GetPostUseCase(repo);

      final result = await useCase('p1');

      expect(result.isRight(), isTrue);
      verify(() => repo.getPostById('p1')).called(1);
    });
  });

  group('CreatePostUseCase', () {
    test('ينشئ منشورًا بالمحتوى والوسائط', () async {
      registerFallbackValue(PostType.normal);
      final repo = _MockPostRepo();
      when(
        () => repo.createPost(
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
        (_) async => right(
          PostEntity(
            id: 'p2',
            userId: 'u1',
            userName: 'A',
            userRole: 'JobSeeker',
            userAvatar: '',
            content: 'new',
            createdAt: DateTime(2026),
          ),
        ),
      );
      final useCase = CreatePostUseCase(repo);

      final result = await useCase(const CreatePostParams(content: 'new'));

      expect(result.isRight(), isTrue);
      verify(
        () => repo.createPost(content: 'new', hashtags: <String>[]),
      ).called(1);
    });

    test('يعيد الخطأ عند فشل الإنشاء', () async {
      final repo = _MockPostRepo();
      when(
        () => repo.createPost(
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
      ).thenAnswer((_) async => left(const ServerFailure('فشل')));
      final useCase = CreatePostUseCase(repo);

      final result = await useCase(const CreatePostParams(content: 'x'));

      expect(result.isLeft(), isTrue);
    });
  });

  group('AddCommentUseCase', () {
    test('يضيف تعليقًا', () async {
      final repo = _MockPostRepo();
      when(
        () => repo.addComment(
          postId: any(named: 'postId'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) async => right(<String, dynamic>{'success': true}));
      final useCase = AddCommentUseCase(repo);

      final result = await useCase(postId: 'p1', comment: 'nice');

      expect(result.isRight(), isTrue);
      verify(() => repo.addComment(postId: 'p1', comment: 'nice')).called(1);
    });
  });

  group('ToggleLikeUseCase', () {
    test('يبدّل الإعجاب', () async {
      final repo = _MockPostRepo();
      when(() => repo.toggleLike('p1')).thenAnswer((_) async => right(null));
      final useCase = ToggleLikeUseCase(repo);

      final result = await useCase('p1');

      expect(result.isRight(), isTrue);
      verify(() => repo.toggleLike('p1')).called(1);
    });
  });

  group('GetJobsUseCase', () {
    test('يجلب الوظائف مع الفلاتر', () async {
      final repo = _MockJobsRepo();
      when(
        () => repo.getJobs(
          search: any(named: 'search'),
          type: any(named: 'type'),
          workPlace: any(named: 'workPlace'),
          workLevel: any(named: 'workLevel'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => right(<JobEntity>[]));
      final useCase = GetJobsUseCase(repo);

      final result = await useCase(search: 'flutter', type: 'Full-time');

      expect(result.isRight(), isTrue);
      verify(
        () => repo.getJobs(search: 'flutter', type: 'Full-time'),
      ).called(1);
    });
  });

  group('Params equality', () {
    test('LoginParams يتساوى عند نفس القيم', () {
      const a = LoginParams(email: 'a@b.com', password: 'Password123');
      const b = LoginParams(email: 'a@b.com', password: 'Password123');
      expect(a, equals(b));
      expect(a.props, [a.email, a.password]);
    });

    test('GetPostsParams يتساوى عند نفس القيم', () {
      const a = GetPostsParams();
      const b = GetPostsParams();
      expect(a, equals(b));
    });

    test('CreateCompanyParams يتساوى عند نفس القيم', () {
      const a = CreateCompanyParams(name: 'Co', industry: 'Tech');
      const b = CreateCompanyParams(name: 'Co', industry: 'Tech');
      expect(a, equals(b));
      expect(a.props.length, greaterThan(0));
    });

    test('CreatePostParams يتساوى عند نفس القيم', () {
      const a = CreatePostParams(content: 'hi', hashtags: ['x']);
      const b = CreatePostParams(content: 'hi', hashtags: ['x']);
      expect(a, equals(b));
      expect(a.props.length, greaterThan(0));
    });
  });
}
