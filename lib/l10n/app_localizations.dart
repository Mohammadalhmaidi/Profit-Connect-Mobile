import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Profit Connect',
      'welcome': 'Welcome to Profit Connect',
      'login': 'Log In',
      'signup': 'Sign Up',
      'email': 'Email Address',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'no_account': "Don't have an account?",
      'have_account': 'Already have an account?',
      'create_account': 'Create Account',
      'search_jobs': 'Search jobs...',
      'jobs': 'Jobs',
      'posts': 'Posts',
      'messages': 'Messages',
      'profile': 'Profile',
      'settings': 'Settings',
      'logout': 'Log Out',
      'save': 'Save',
      'cancel': 'Cancel',
      'edit': 'Edit',
      'delete': 'Delete',
      'done': 'Done',
      'loading': 'Loading...',
      'error': 'Something went wrong',
      'retry': 'Retry',
      'no_internet': 'No internet connection',
      'success': 'Success',
      'required_field': 'This field is required',
      'invalid_email': 'Please enter a valid email',
      'password_too_short': 'Password must be at least 8 characters',
      'network_error': 'Network error. Please try again.',
      'server_error': 'Server error. Please try again later.',
      'unauthorized': 'Please log in to continue',
      'not_found': 'Page not found',
      'back': 'Back',
      'next': 'Next',
      'skip': 'Skip',
      'continue': 'Continue',
      'search': 'Search',
      'filter': 'Filter',
      'sort': 'Sort',
      'share': 'Share',
      'copy': 'Copy',
      'paste': 'Paste',
      'close': 'Close',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'no': 'No',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'notifications': 'Notifications',
      'privacy': 'Privacy',
      'terms': 'Terms of Service',
      'about': 'About',
      'version': 'Version',
      'no_messages': 'No messages yet',
      'no_jobs': 'No jobs found',
      'no_posts': 'No posts yet',
      'no_results': 'No results found',
      'online': 'Online',
      'offline': 'Offline',
      'last_seen': 'Last seen',
      'typing': 'typing...',
      'send': 'Send',
      'attach': 'Attach',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'file': 'File',
      'location': 'Location',
      'add_comment': 'Add a comment...',
      'like': 'Like',
      'unlike': 'Unlike',
      'comments': 'comments',
      'likes': 'likes',
      'shares': 'shares',
      'views': 'views',
      'follow': 'Follow',
      'following': 'Following',
      'followers': 'Followers',
      'connections': 'Connections',
      'recommendations': 'Recommended for you',
      'trending': 'Trending',
      'recent': 'Recent',
      'popular': 'Popular',
      'full_time': 'Full-time',
      'part_time': 'Part-time',
      'contract': 'Contract',
      'internship': 'Internship',
      'remote': 'Remote',
      'on_site': 'On-site',
      'hybrid': 'Hybrid',
      'entry_level': 'Entry',
      'mid_level': 'Mid',
      'senior_level': 'Senior',
      'lead_level': 'Lead',
      'apply': 'Apply Now',
      'saved': 'Saved',
      'posted': 'Posted',
      'company': 'Company',
      'industry': 'Industry',
      'skills': 'Skills',
      'experience': 'Experience',
      'education': 'Education',
      'headline': 'Headline',
      'bio': 'Bio',
      'location': 'Location',
      'phone': 'Phone',
      'website': 'Website',
      'twitter': 'Twitter',
      'linkedin': 'LinkedIn',
      'github': 'GitHub',
      'portfolio': 'Portfolio',
    },
    'ar': {
      'app_name': 'بروفيت كونكت',
      'welcome': 'مرحباً بك في بروفيت كونكت',
      'login': 'تسجيل الدخول',
      'signup': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'forgot_password': 'نسيت كلمة المرور؟',
      'no_account': 'ليس لديك حساب؟',
      'have_account': 'لديك حساب بالفعل؟',
      'create_account': 'إنشاء حساب',
      'search_jobs': 'البحث عن وظائف...',
      'jobs': 'الوظائف',
      'posts': 'المنشورات',
      'messages': 'الرسائل',
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'logout': 'تسجيل الخروج',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'edit': 'تعديل',
      'delete': 'حذف',
      'done': 'تم',
      'loading': 'جاري التحميل...',
      'error': 'حدث خطأ ما',
      'retry': 'إعادة المحاولة',
      'no_internet': 'لا يوجد اتصال بالإنترنت',
      'success': 'تم بنجاح',
      'required_field': 'هذا الحقل مطلوب',
      'invalid_email': 'يرجى إدخال بريد إلكتروني صحيح',
      'password_too_short': 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل',
      'network_error': 'خطأ في الشبكة. يرجى المحاولة مرة أخرى.',
      'server_error': 'خطأ في الخادم. يرجى المحاولة لاحقاً.',
      'unauthorized': 'يرجى تسجيل الدخول للمتابعة',
      'not_found': 'الصفحة غير موجودة',
      'back': 'رجوع',
      'next': 'التالي',
      'skip': 'تخطي',
      'continue': 'متابعة',
      'search': 'بحث',
      'filter': 'تصفية',
      'sort': 'ترتيب',
      'share': 'مشاركة',
      'copy': 'نسخ',
      'paste': 'لصق',
      'close': 'إغلاق',
      'confirm': 'تأكيد',
      'yes': 'نعم',
      'no': 'لا',
      'dark_mode': 'الوضع الداكن',
      'language': 'اللغة',
      'notifications': 'الإشعارات',
      'privacy': 'الخصوصية',
      'terms': 'شروط الاستخدام',
      'about': 'حول',
      'version': 'الإصدار',
      'no_messages': 'لا توجد رسائل بعد',
      'no_jobs': 'لا توجد وظائف',
      'no_posts': 'لا توجد منشورات بعد',
      'no_results': 'لا توجد نتائج',
      'online': 'متصل',
      'offline': 'غير متصل',
      'last_seen': 'آخر ظهور',
      'typing': 'يكتب...',
      'send': 'إرسال',
      'attach': 'إرفاق',
      'camera': 'الكاميرا',
      'gallery': 'المعرض',
      'file': 'ملف',
      'location': 'الموقع',
      'add_comment': 'أضف تعليقاً...',
      'like': 'إعجاب',
      'unlike': 'إلغاء الإعجاب',
      'comments': 'تعليقات',
      'likes': 'إعجابات',
      'shares': 'مشاركات',
      'views': 'مشاهدات',
      'follow': 'متابعة',
      'following': 'المتابعة',
      'followers': 'المتابعون',
      'connections': 'الروابط',
      'recommendations': 'موصى به لك',
      'trending': 'الترند',
      'recent': 'الأخيرة',
      'popular': 'الشائعة',
      'full_time': 'دوام كامل',
      'part_time': 'دوام جزئي',
      'contract': 'عقد',
      'internship': 'تدريب',
      'remote': 'عن بُعد',
      'on_site': 'مكتب',
      'hybrid': 'هجين',
      'entry_level': 'مبتدئ',
      'mid_level': 'متوسط',
      'senior_level': 'كبير',
      'lead_level': 'قائد',
      'apply': 'تقديم الآن',
      'saved': 'محفوظ',
      'posted': 'منشور',
      'company': 'شركة',
      'industry': 'صناعة',
      'skills': 'مهارات',
      'experience': 'خبرة',
      'education': 'تعليم',
      'headline': 'العنوان',
      'bio': 'نبذة',
      'location': 'الموقع',
      'phone': 'الهاتف',
      'website': 'الموقع الإلكتروني',
      'twitter': 'تويتر',
      'linkedin': 'لينكدإن',
      'github': 'جيت هب',
      'portfolio': 'محفظة الأعمال',
    },
  };

  String translate(String key) {
    final langCode = locale.languageCode;
    final translations = _localizedValues[langCode];
    if (translations == null) return key;
    return translations[key] ?? key;
  }

  String get appName => translate('app_name');
  String get welcome => translate('welcome');
  String get login => translate('login');
  String get signup => translate('signup');
  String get email => translate('email');
  String get password => translate('password');
  String get forgotPassword => translate('forgot_password');
  String get noAccount => translate('no_account');
  String get haveAccount => translate('have_account');
  String get createAccount => translate('create_account');
  String get searchJobs => translate('search_jobs');
  String get jobs => translate('jobs');
  String get posts => translate('posts');
  String get messages => translate('messages');
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get logout => translate('logout');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get edit => translate('edit');
  String get delete => translate('delete');
  String get done => translate('done');
  String get loading => translate('loading');
  String get error => translate('error');
  String get retry => translate('retry');
  String get noInternet => translate('no_internet');
  String get success => translate('success');
  String get requiredField => translate('required_field');
  String get invalidEmail => translate('invalid_email');
  String get passwordTooShort => translate('password_too_short');
  String get networkError => translate('network_error');
  String get serverError => translate('server_error');
  String get unauthorized => translate('unauthorized');
  String get notFound => translate('not_found');
  String get back => translate('back');
  String get next => translate('next');
  String get skip => translate('skip');
  String get continueBtn => translate('continue');
  String get search => translate('search');
  String get filter => translate('filter');
  String get sort => translate('sort');
  String get share => translate('share');
  String get copy => translate('copy');
  String get paste => translate('paste');
  String get close => translate('close');
  String get confirm => translate('confirm');
  String get yes => translate('yes');
  String get no => translate('no');
  String get darkMode => translate('dark_mode');
  String get language => translate('language');
  String get notifications => translate('notifications');
  String get privacy => translate('privacy');
  String get terms => translate('terms');
  String get about => translate('about');
  String get version => translate('version');
  String get noMessages => translate('no_messages');
  String get noJobs => translate('no_jobs');
  String get noPosts => translate('no_posts');
  String get noResults => translate('no_results');
  String get online => translate('online');
  String get offline => translate('offline');
  String get lastSeen => translate('last_seen');
  String get typing => translate('typing');
  String get send => translate('send');
  String get attach => translate('attach');
  String get camera => translate('camera');
  String get gallery => translate('gallery');
  String get file => translate('file');
  String get location => translate('location');
  String get addComment => translate('add_comment');
  String get like => translate('like');
  String get unlike => translate('unlike');
  String get comments => translate('comments');
  String get likes => translate('likes');
  String get shares => translate('shares');
  String get views => translate('views');
  String get follow => translate('follow');
  String get following => translate('following');
  String get followers => translate('followers');
  String get connections => translate('connections');
  String get recommendations => translate('recommendations');
  String get trending => translate('trending');
  String get recent => translate('recent');
  String get popular => translate('popular');
  String get fullTime => translate('full_time');
  String get partTime => translate('part_time');
  String get contract => translate('contract');
  String get internship => translate('internship');
  String get remote => translate('remote');
  String get onSite => translate('on_site');
  String get hybrid => translate('hybrid');
  String get entryLevel => translate('entry_level');
  String get midLevel => translate('mid_level');
  String get seniorLevel => translate('senior_level');
  String get leadLevel => translate('lead_level');
  String get apply => translate('apply');
  String get saved => translate('saved');
  String get posted => translate('posted');
  String get company => translate('company');
  String get industry => translate('industry');
  String get skills => translate('skills');
  String get experience => translate('experience');
  String get education => translate('education');
  String get headline => translate('headline');
  String get bio => translate('bio');
  String get phone => translate('phone');
  String get website => translate('website');
  String get twitter => translate('twitter');
  String get linkedin => translate('linkedin');
  String get github => translate('github');
  String get portfolio => translate('portfolio');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class AppLocalizationDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;
}