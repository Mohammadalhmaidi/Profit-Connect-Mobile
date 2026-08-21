import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': _en,
    'ar': _ar,
  };

  String translate(String key, [Map<String, String>? args]) {
    final langCode = locale.languageCode;
    final table = _localizedValues[langCode] ?? _en;
    var value = table[key] ?? _en[key] ?? key;
    if (args != null) {
      args.forEach((k, v) {
        value = value.replaceAll('{$k}', v);
      });
    }
    return value;
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

const Map<String, String> _en = {
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
  'pending': 'Pending',
  'connect': 'Connect',
  'accept': 'Accept',
  'ignore': 'Ignore',
  'followers': 'Followers',
  'followers_count': '{count} followers',
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
  'saved_posts_title': 'Saved Posts',
  'saved_posts_empty': 'No saved posts yet',
  'saved_posts_empty_hint':
      'Tap the bookmark icon on any post to save it for later',
  'leaderboard_title': 'Leaderboard',
  'leaderboard_points': 'pts',
  'leaderboard_empty': 'No users on the board yet',
  'leaderboard_top_users': 'Top Users',
  'leaderboard_top_managers': 'Top Managers',
  'leaderboard_manager_companies': '{count} companies',
  'leaderboard_followers': 'followers',
  'leaderboard_managers_unavailable': 'Managers list is unavailable',
  'posted': 'Posted',
  'company': 'Company',
  'industry': 'Industry',
  'skills': 'Skills',
  'experience': 'Experience',
  'education': 'Education',
  'headline': 'Headline',
  'bio': 'Bio',
  'phone': 'Phone',
  'website': 'Website',
  'twitter': 'Twitter',
  'linkedin': 'LinkedIn',
  'github': 'GitHub',
  'portfolio': 'Portfolio',
  'portfolio.title': 'My Portfolio',
  'portfolio.items': 'Works',
  'portfolio.collections': 'Collections',
  'portfolio.add_work': 'Add Work',
  'portfolio.add_collection': 'Add Collection',
  'portfolio.empty_items': 'No works yet',
  'portfolio.empty_items_hint': 'Add your first work so employers can see it',
  'portfolio.empty_collections': 'No collections yet',
  'portfolio.create_title': 'Work title',
  'portfolio.create_category': 'Category',
  'portfolio.create_category_hint': 'e.g. UI Design, App Development',
  'portfolio.create_desc': 'Description',
  'portfolio.create_client': 'Client',
  'portfolio.create_duration': 'Duration',
  'portfolio.create_role': 'My role',
  'portfolio.create_url': 'Project URL',
  'portfolio.create_tags': 'Tags (comma separated)',
  'portfolio.link_project': 'Link to project',
  'portfolio.link_project_hint': 'Select a project (optional)',
  'portfolio.create_media': 'Images & videos (up to 12 files)',

  'portfolio.create_visibility_public': 'Public',
  'portfolio.create_visibility_private': 'Private',
  'portfolio.delete_confirm': 'Delete this work?',
  'portfolio.delete_collection_confirm': 'Delete this collection?',
  'portfolio.collection_name': 'Collection name',
  'portfolio.collection_desc': 'Collection description',
  'portfolio.views': 'views',

  // Common
  'common.ok': 'OK',
  'common.add': 'Add',

  'common.submit': 'Submit',





  'common.all': 'All',


  'common.today': 'Today',
  'common.just_now': 'Just now',
  'common.min_ago': '{m} min ago',
  'common.hour_ago': '{h} hr ago',
  'common.day_ago': '{d} d ago',
  'common.yesterday': 'Yesterday',



  // navigation
  'nav.home': 'Home',
  'nav.network': 'Network',
  'nav.jobs': 'Jobs',
  'nav.messages': 'Messages',
  'nav.profile': 'Profile',
  'nav.notifications': 'Notifications',

  // auth

  'auth.welcome_subtitle': 'Log in to continue your journey',


  'auth.login_google': 'Login with Google',
  'auth.or_continue': 'Or continue with',




  'auth.full_name': 'Full Name',

  'auth.confirm_password': 'Confirm Password',
  'auth.password_mismatch': 'Passwords do not match',
  'auth.i_am': "I'm a",

  'auth.employer': 'Employer',
  'auth.skills_min_3': 'Please select at least 3 skills',
  'auth.forgot_title': 'Forgot Password',
  'auth.forgot_subtitle': 'Enter your email and we will send you a reset link',
  'auth.reset_sent': 'Reset link sent to your email',
  'auth.reset': 'Reset Password',
  'auth.new_password': 'New Password',




  'auth.otp_invalid': 'Enter the 4-digit code sent to your email',

  // reset password
  'reset.resend_sent': 'A new verification code has been sent',
  'reset.demo_code': 'Demo code: {code}',
  'reset.verify': 'Verify & Reset',
  'reset.sent_to': 'We sent a 4-digit code to',
  'reset.resend_in': 'Resend code in {s}s',
  'reset.not_received': "Didn't receive the code?",
  'reset.resend': 'Resend',
  'reset.at_least': 'At least 6 characters',
  'reset.reenter': 'Re-enter your new password',
  'reset.success': 'Password reset successfully. Please sign in.',

  // onboarding
  'onb.step_of': 'Step {step} of {total}',
  'onb.job_title': 'Job Title',












  'onb.create_company': 'Create Company',

  'onb.build_title': 'Build your profile',
  'onb.build_subtitle':
      'Help recruiters and peers find you by starting with the basics.',
  'onb.select_uni': 'Select University or Degree',
  'onb.strengths_title': 'What are your\nstrengths?',
  'onb.strengths_subtitle':
      'Select at least 3 skills to personalize your feed and help recruiters find you.',
  'onb.skills_search': 'Search specific skills (e.g. Python)',
  'onb.name_required': 'Please enter your full name',
  'onb.save_failed': 'Could not save your profile. Please try again.',

  // feed / home
  'feed.what_do_you_want': 'What do you want to talk about?',
  'feed.empty_title': 'No posts in your feed',
  'feed.empty_subtitle': 'Follow people to see their posts here.',
  'feed.find_people': 'Find people',
  'feed.create_post': 'Create Post',
  'feed.post': 'Post',

  'feed.improve_ai': 'Improve with AI',








  'feed.copied': 'Copied to clipboard',


  'feed.comment_failed': 'Could not add comment. Please try again.',
  'feed.hashtag_empty': 'No posts found with this hashtag',
  'feed.comments_title': 'Comments',
  'feed.no_comments': 'No comments yet. Be the first to reply!',
  'feed.write_comment': 'Write a comment...',
  'feed.save_failed': 'Could not save post',
  'feed.translate_failed': 'Translation failed',
  'translate': 'Translate',
  'feed.ai_improved': 'Improved with AI!',
  'feed.ai_failed': 'AI improvement failed. Try again.',
  'feed.improving': 'Improving...',
  'feed.photo': 'Photo',
  'feed.video': 'Video',
  'feed.video_selected': 'Video selected',
  'common.you': 'You',
  'feed.post_detail': 'Post',
  'network.my_network': 'My Network',
  'network.search_hint': 'Search connections...',
  'network.requests_count': 'Requests ({count})',
  'network.connections_label': 'Connections',
  'network.member': 'Member',
  'network.new_request': 'New request',
  'network.no_requests_title': 'No pending requests',
  'network.no_requests_subtitle':
      'When someone sends you a connection request, it will show up here.',

  'network.suggestions': 'People you may know',
  'network.suggestions_empty': 'No suggestions right now. Pull to refresh.',
  'network.empty_subtitle':
      'Connect with people you know and grow your professional network.',
  'notifications.empty_title': 'No notifications yet',
  'notifications.empty_subtitle':
      'Updates about your posts, connections and jobs\nwill appear here.',
  'network.search_failed_title': 'Search failed',
  'network.search_failed': 'Search failed. Please try again.',
  'network.no_results_msg': 'No results',
  'network.no_results_subtitle': 'Try a different name or keyword.',
  'network.request_accepted': 'Request accepted!',
  'network.accept_failed': 'Could not accept request',
  'network.request_ignored': 'Request ignored',
  'network.ignore_failed': 'Could not ignore request',
  'network.request_sent': 'Connection request sent!',
  'network.send_failed': 'Could not send request',
  'network.follow_failed': 'Could not follow this user',
  'jobs.title': 'Profit Connect Jobs',
  'jobs.my_apps': 'My Applications',
  'jobs.search_titles': 'Search titles, companies...',
  'jobs.featured_role': 'Featured Roles',
  'jobs.recommended': 'Recommended for you',
  'jobs.showing': 'Showing {type} Jobs',
  'jobs.no_jobs': 'No Jobs Found',
  'jobs.high_match': 'HIGH MATCH',

  'jobs.salary_on_request': 'Salary on request',
  'jobs.company_unavailable': 'Company page is not available',
  'jobs.level_label': 'LEVEL',
  'jobs.status_label': 'STATUS',
  'jobs.open': 'Open',
  'jobs.about_title': 'About the job',
  'jobs.no_description': 'No description provided for this job.',
  'jobs.requirements_title': 'Requirements',
  'jobs.no_requirements': 'No requirements specified.',
  'jobs.easy_apply': 'Easy Apply',
  'jobs.apply_failed': 'Unable to apply for this job',
  'jobs.save_failed': 'Could not save this job',
  'jobs.applied_to': 'Application submitted for {title}',
  'jobs.apply_error':
      'Failed to submit application. Upload a PDF or Word resume.',
  'jobs.posted': 'Posted {time}',
  'jobs.empty_search': 'Search for jobs by title, keywords, or company',
  'jobs.no_results_for': 'No jobs found for "{query}"',
  'jobs.try_adjusting': 'Try adjusting your keywords or filters',
  'jobs.load_failed': 'Could not load applications',
  'jobs.untitled': 'Untitled Job',
  'jobs.yesterday': 'Yesterday',
  'jobs.days_ago': '{d} days ago',
  'jobs.no_apps_title': 'No applications yet',
  'jobs.no_apps_subtitle': 'When you apply to a job, it will show up here.',

  // messages
  'messages.load_failed': 'Failed to load conversations',
  'messages.unknown': 'Unknown',
  'messages.search_hint': 'Search people or messages...',
  'messages.search_people': 'People',
  'messages.search_no_results': 'No results for "{q}"',
  'search_people': 'Search people',
  'search.type_hint': 'Type at least 2 characters to search',
  'messages.no_conversations': 'No conversations yet',
  'messages.compose_soon': 'Compose is coming soon',
  'messages.new_message': 'New message',
  'messages.send_failed': 'Failed to send message: {error}',
  'messages.online': 'ONLINE',
  'messages.empty_chat': 'No messages yet. Say hello!',
  'messages.write_message': 'Write a message...',

  // profile
  'profile.follow_failed': 'Could not update follow status',
  'profile.avatar_updated': 'Profile picture updated!',
  'profile.avatar_failed': 'Failed to update profile picture',
  'profile.guest': 'Guest User',
  'profile.add_title': 'Add a professional title',
  'profile.no_bio': 'No bio yet. Tap "Edit profile" to add one.',
  'profile.uploading': 'Uploading...',
  'profile.change_photo': 'Change photo',
  'profile.full_name': 'Full Name',
  'profile.professional_title': 'Professional Title',
  'profile.about': 'About',
  'profile.top_skills': 'Top Skills',
  'profile.birth_date': 'Date of Birth',
  'profile.pick_birth_date': 'Select date of birth',
  'profile.gender': 'Gender',
  'profile.pick_gender': 'Select gender',
  'profile.updated': 'Profile updated successfully!',
  'profile.update_failed': 'Failed to update profile: {error}',
  'profile.name_hint': 'Jane Doe',
  'profile.current_role': 'Current Role',
  'profile.role_hint': 'e.g. Product Designer',

  // network









  'network.no_results': 'No people found',






  // jobs







































  // messages










  // settings
  'settings.appearance': 'APPEARANCE',
  'settings.email_notifications': 'Email Notifications',
  'settings.push_notifications': 'Push Notifications',
  'settings.profile_visibility': 'Profile Visibility',
  'settings.public': 'Public',
  'settings.connections_only': 'Connections only',
  'settings.private': 'Private',
  'settings.account': 'ACCOUNT',
  'settings.edit_profile': 'Edit Profile',
  'settings.change_password': 'Change Password',
  'settings.services': 'SERVICES',
  'settings.wallet': 'Wallet',
  'settings.payments': 'Payments',
  'settings.salaries': 'Salaries',
  'settings.projects': 'Projects',
  'settings.company_dashboard': 'Company Dashboard',
  'settings.company_dashboard_hint': 'Available for company owners & employees',
  'settings.support': 'SUPPORT',
  'settings.help': 'Help Center',
  'settings.sync_error': 'Could not sync settings',

  // help & support
  'help_support.title': 'Help & Support',
  'help_support.faq': 'FREQUENTLY ASKED QUESTIONS',
  'help_support.q1': 'How do I create a post?',
  'help_support.a1':
      'Go to the Home tab, tap the composer at the top, write your update and press Post.',
  'help_support.q2': 'How do I apply for a job?',
  'help_support.a2':
      'Open the Jobs tab, open a job you like and tap the Apply button. Track your applications from My Applications.',
  'help_support.q3': 'How do I change my account details?',
  'help_support.a3':
      'Open Settings from the menu, then Edit Profile to update your personal information.',
  'help_support.contact': 'CONTACT SUPPORT',
  'help_support.contact_hint': 'Email us and our team will reply shortly',
  'help_support.community': 'COMMUNITY',
  'help_support.community_title': 'Visit your Profile',
  'help_support.community_hint': 'Review and improve your public profile',

  // about

  'about.tagline': 'Professional networking and job search made easy.',
  'about.version': 'Version',
  'about.company_name': 'Profit Connect',
  'about.website': 'www.profitconnect.com',
  'about.copyright': 'Copyright © 2026 Profit Connect. All rights reserved.',
  'about.disclaimer':
      'Profit Connect is a networking platform. Content posted by users expresses the views of its authors only.',

  // company
  'company.title': 'Company',
  'company.no_linked': 'No company linked to your account',
  'company.dashboard': 'Company Dashboard',




  'company.total_jobs': 'Total Jobs',
  'company.open_jobs': 'Open Jobs',
  'company.team': 'Team',

  'company.no_employees': 'No employees yet',
  'company.add_employee': 'Add Employee',
  'company.remove_employee': 'Remove',
  'company.employee_email': 'Email',
  'company.employee_password': 'Password',
  'company.employee_first': 'First Name',
  'company.employee_last': 'Last Name',
  'company.employee_position': 'Position',
  'company.employee_added': 'Employee added',
  'company.employee_removed': 'Employee removed',

  'company.post_job': 'Post Job',
  'company.job_title': 'Job Title',
  'company.job_location': 'Location',
  'company.job_type': 'Type',
  'company.job_level': 'Level',
  'company.workplace': 'Work Place',
  'company.min_salary': 'Min Salary',
  'company.max_salary': 'Max Salary',
  'company.description': 'Description',
  'company.job_posted': 'Job posted',

  'company.no_applicants': 'No applicants yet',
  'company.shortlist': 'Shortlist',
  'company.accept': 'Accept',
  'company.reject': 'Reject',
  'company.status_updated': 'Status updated to {status}',
  'company.setup_title': 'Set up your company profile',
  'company.setup_subtitle': 'Tell candidates about your company',
  'company.add_logo': 'Add Logo',
  'company.access_logo': 'Add Logo (coming soon)',
  'company.name': 'Company Name',
  'company.name_hint': 'e.g. TechCorp Inc.',
  'company.required': 'Required',
  'company.industry': 'Industry',
  'company.select_industry': 'Select industry',
  'company.desc_hint': 'Tell us about your company...',
  'company.website': 'Website',
  'company.website_hint': 'https://yourcompany.com',
  'company.location': 'Location',
  'company.location_hint': 'City, Country',
  'company.location_required': 'Enter city and country (e.g. Amman, Jordan)',
  'company.employees_count': 'Employees ({count})',
  'company.jobs_count': 'Jobs ({count})',
  'company.no_jobs': 'No jobs posted yet',
  'company.status_value': 'Status: {status}',
  'company.email_required': 'Email is required',
  'company.employee_added_creds':
      'Employee added!\nLogin: {email} / {password}',
  'company.add_employee_failed': 'Could not add employee',
  'company.remove_employee_failed': 'Could not remove employee',
  'company.job_title_required': 'Job title is required',
  'company.post_failed': 'Could not post job',
  'company.status_update_failed': 'Could not update status',
  'company.employee_name': 'Employee',
  'company.applicant': 'Applicant',
  'company.load_failed': 'Could not load company',
  'company.follow_failed': 'Could not update follow status',
  'company.add_admin': 'Add Company Admin',
  'company.admin_id_hint': 'Enter user ID',
  'company.admin_added': 'Admin added successfully!',
  'company.admin_add_failed': 'Could not add admin. Check the user ID.',
  'company.followers_count': '{count} followers',
  'company.overview': 'Overview',
  'company.followers_title': 'Followers ({count})',
  'company.recent_jobs': 'Recent Jobs',
  'company.stat_open': 'Open',
  'company.stat_applicants': 'Applicants',
  'company.stat_followers': 'Followers',
  'company.stat_rating': 'Rating',
  'company.stat_today': 'Today',
  'company.stat_week': 'This Week',
  'company.stat_growth': 'Growth',

  // wallet
  'wallet.title': 'My Wallet',


  'wallet.total_earned': 'Total Earned',




  'wallet.withdraw_failed': 'Withdrawal failed',


  'wallet.no_transactions': 'Your transactions will appear here',
  'wallet.escrow': 'Escrow (Held Payments)',
  'wallet.no_escrow': 'No held payments',
  'wallet.release': 'Release payment',
  'wallet.released': 'Payment released to the recipient wallet',
  'wallet.release_failed': 'Could not release the payment',
  'wallet.project': 'Project',








  'wallet.available_balance': 'Available Balance',
  'wallet.in_escrow': 'In Escrow',
  'wallet.withdrawn': 'Withdrawn',
  'wallet.withdraw_btn': 'Withdraw Funds',
  'wallet.withdraw_title': 'Request Withdrawal',
  'wallet.amount_label': 'Amount (USD)',
  'wallet.method': 'Withdrawal Method',
  'wallet.bank_transfer': 'Bank Transfer',
  'wallet.cash': 'Cash',
  'wallet.other': 'Other',
  'wallet.bank_name': 'Bank Name',
  'wallet.account_holder': 'Account Holder',
  'wallet.request_withdraw': 'Request',
  'wallet.invalid_amount': 'Please enter a valid amount',
  'wallet.withdraw_requested': 'Withdrawal requested',
  'wallet.withdraw_cancelled': 'Withdrawal cancelled',
  'wallet.cancel_failed': 'Could not cancel withdrawal',
  'wallet.recent_transactions': 'Recent Transactions',
  'wallet.withdrawals': 'Withdrawals',
  'wallet.withdrawal_row': 'Withdrawal of {amount}',

  // payments
  'payments.title': 'Payments',

  'payments.received': 'Received',
  'payments.sent': 'Sent',




  'payments.none': 'No payments found',
  'payments.release': 'Release',
  'payments.released': 'Payment released!',
  'payments.release_failed': 'Could not release payment',
  'payments.project_payment': 'Project payment',

  // salaries
  'salaries.title': 'Salaries',


  'salaries.average': 'Average Salary',

  'salaries.no_records': 'No salary records',




  'salaries.filter_title': 'Job Title',
  'salaries.filter_country': 'Country',
  'salaries.filter_level': 'Experience Level',




  'salaries.records_count': 'Salary Records ({count})',

  // projects
  'projects.title': 'Projects',
  'projects.my': 'My Projects',
  'projects.proposals': 'My Proposals',
  'projects.empty': 'No projects yet',
  'projects.empty_proposals': 'No proposals yet',
  'projects.untitled_project': 'Untitled Project',
  'projects.budget_label': 'Budget: {amount}',
  'projects.bid_label': 'My bid: {amount}',
  'projects.client_label': 'Client: {name}',
  'projects.no_proposals_received': 'No proposals received yet',
  'projects.proposals_count': 'Proposals ({count})',
  'projects.freelancer': 'Freelancer',

  'projects.deadline': 'Deadline',











  'projects.add_project': 'Add Project',
  'projects.budget_min': 'Min budget',
  'projects.budget_max': 'Max budget',
  'projects.category': 'Category',
  'projects.description': 'Description',
  'projects.select_deadline': 'Select deadline',
  'projects.title_field': 'Title',

  // profile
  'profile.edit': 'Edit Profile',
  'followers.empty': 'No followers yet',
  'followers.empty_following': 'Not following anyone yet',







  'profile.my_company': 'My Company',
};

const Map<String, String> _ar = {
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
  'following': 'متابعة',
  'pending': 'قيد الانتظار',
  'connect': 'تواصل',
  'accept': 'قبول',
  'ignore': 'تجاهل',
  'followers': 'المتابعون',
  'followers_count': '{count} متابع',
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
  'saved_posts_title': 'المنشورات المحفوظة',
  'saved_posts_empty': 'لا توجد منشورات محفوظة بعد',
  'saved_posts_empty_hint': 'اضغط أيقونة الإشارة على أي منشور لحفظه لاحقاً',
  'leaderboard_title': 'لوحة المتصدرين',
  'leaderboard_points': 'نقطة',
  'leaderboard_empty': 'لا يوجد مستخدمون على اللوحة بعد',
  'leaderboard_top_users': 'أفضل المستخدمين',
  'leaderboard_top_managers': 'أفضل المديرين',
  'leaderboard_manager_companies': '{count} شركات',
  'leaderboard_followers': 'متابع',
  'leaderboard_managers_unavailable': 'قائمة المديرين غير متاحة',
  'posted': 'منشور',
  'company': 'شركة',
  'industry': 'صناعة',
  'skills': 'مهارات',
  'experience': 'خبرة',
  'education': 'تعليم',
  'headline': 'العنوان',
  'bio': 'نبذة',
  'phone': 'الهاتف',
  'website': 'الموقع الإلكتروني',
  'twitter': 'تويتر',
  'linkedin': 'لينكدإن',
  'github': 'جيت هب',
  'portfolio': 'محفظة الأعمال',
  'portfolio.title': 'معرضي',
  'portfolio.items': 'الأعمال',
  'portfolio.collections': 'المجموعات',
  'portfolio.add_work': 'إضافة عمل',
  'portfolio.add_collection': 'إضافة مجموعة',
  'portfolio.empty_items': 'لا توجد أعمال بعد',
  'portfolio.empty_items_hint': 'أضف أول عمل ليظهر في ملفك المهني',
  'portfolio.empty_collections': 'لا توجد مجموعات بعد',
  'portfolio.create_title': 'عنوان العمل',
  'portfolio.create_category': 'التصنيف',
  'portfolio.create_category_hint': 'مثال: تصميم واجهات، تطوير تطبيقات',
  'portfolio.create_desc': 'الوصف',
  'portfolio.create_client': 'العميل',
  'portfolio.create_duration': 'المدة',
  'portfolio.create_role': 'دوري في المشروع',
  'portfolio.create_url': 'رابط المشروع',
  'portfolio.create_tags': 'الوسوم (افصل بينها بفاصلة)',
  'portfolio.link_project': 'ربط بمشروع',
  'portfolio.link_project_hint': 'اختر مشروعًا (اختياري)',
  'portfolio.create_media': 'الصور والفيديو (حتى 12 ملف)',

  'portfolio.create_visibility_public': 'عام',
  'portfolio.create_visibility_private': 'خاص',
  'portfolio.delete_confirm': 'حذف هذا العمل؟',
  'portfolio.delete_collection_confirm': 'حذف هذه المجموعة؟',
  'portfolio.collection_name': 'اسم المجموعة',
  'portfolio.collection_desc': 'وصف المجموعة',
  'portfolio.views': 'مشاهدة',

  // common
  'common.ok': 'حسناً',
  'common.add': 'إضافة',

  'common.submit': 'إرسال',





  'common.all': 'الكل',


  'common.today': 'اليوم',
  'common.just_now': 'الآن',
  'common.min_ago': 'منذ {m} دقيقة',
  'common.hour_ago': 'منذ {h} ساعة',
  'common.day_ago': 'منذ {d} يوم',
  'common.yesterday': 'أمس',



  // navigation
  'nav.home': 'الرئيسية',
  'nav.network': 'الشبكة',
  'nav.jobs': 'الوظائف',
  'nav.messages': 'الرسائل',
  'nav.profile': 'الملف الشخصي',
  'nav.notifications': 'الإشعارات',

  // auth

  'auth.welcome_subtitle': 'سجّل الدخول للمتابعة',


  'auth.login_google': 'الدخول عبر جوجل',
  'auth.or_continue': 'أو المتابعة عبر',




  'auth.full_name': 'الاسم الكامل',

  'auth.confirm_password': 'تأكيد كلمة المرور',
  'auth.password_mismatch': 'كلمتا المرور غير متطابقتين',
  'auth.i_am': 'أنا',

  'auth.employer': 'صاحب عمل',
  'auth.skills_min_3': 'يرجى اختيار 3 مهارات على الأقل',
  'auth.forgot_title': 'استعادة كلمة المرور',
  'auth.forgot_subtitle': 'أدخل بريدك الإلكتروني وسنرسل لك رابط الاستعادة',
  'auth.reset_sent': 'تم إرسال رابط الاستعادة إلى بريدك',
  'auth.reset': 'إعادة تعيين كلمة المرور',
  'auth.new_password': 'كلمة المرور الجديدة',




  'auth.otp_invalid': 'أدخل الرمز المكوّن من 4 أرقام المرسل إلى بريدك',

  // reset password
  'reset.resend_sent': 'تم إرسال رمز تحقق جديد',
  'reset.demo_code': 'الرمز التجريبي: {code}',
  'reset.verify': 'التحقق وإعادة التعيين',
  'reset.sent_to': 'أرسلنا رمزاً من 4 أرقام إلى',
  'reset.resend_in': 'إعادة إرسال الرمز خلال {s} ثانية',
  'reset.not_received': 'لم تستلم الرمز؟',
  'reset.resend': 'إعادة الإرسال',
  'reset.at_least': '6 أحرف على الأقل',
  'reset.reenter': 'أعد إدخال كلمة المرور الجديدة',
  'reset.success': 'تمت إعادة تعيين كلمة المرور. يرجى تسجيل الدخول.',

  // onboarding
  'onb.step_of': 'الخطوة {step} من {total}',
  'onb.job_title': 'المسمى الوظيفي',












  'onb.create_company': 'إنشاء شركة',

  'onb.build_title': 'ابنِ ملفك الشخصي',
  'onb.build_subtitle':
      'ساعد مسؤولي التوظيف وزملاءك على الوصول إليك بالبدء بالأساسيات.',
  'onb.select_uni': 'اختر الجامعة أو المؤهل',
  'onb.strengths_title': 'ما هي نقاط\nقوتك؟',
  'onb.strengths_subtitle':
      'اختر 3 مهارات على الأقل لتخصيص خلاصتك ومساعدة مسؤولي التوظيف على العثور عليك.',
  'onb.skills_search': 'ابحث عن مهارات محددة (مثال: بايثون)',
  'onb.name_required': 'يرجى إدخال اسمك الكامل',
  'onb.save_failed': 'تعذّر حفظ ملفك الشخصي. حاول مجددًا.',

  // feed / home
  'feed.what_do_you_want': 'ماذا تريد أن تتحدث عنه؟',
  'feed.empty_title': 'لا توجد منشورات في خلاصتك',
  'feed.empty_subtitle': 'تابع أشخاصاً لترى منشوراتهم هنا.',
  'feed.find_people': 'ابحث عن أشخاص',
  'feed.create_post': 'إنشاء منشور',
  'feed.post': 'نشر',

  'feed.improve_ai': 'تحسين بالذكاء الاصطناعي',








  'feed.copied': 'تم النسخ إلى الحافظة',


  'feed.comment_failed': 'تعذّرت إضافة التعليق. حاول مجددًا.',
  'feed.hashtag_empty': 'لا توجد منشورات بهذا الهاشتاغ',
  'feed.comments_title': 'التعليقات',
  'feed.no_comments': 'لا توجد تعليقات بعد. كن أول من يرد!',
  'feed.write_comment': 'اكتب تعليقاً...',
  'feed.save_failed': 'تعذّر حفظ المنشور',
  'feed.translate_failed': 'تعذّرت الترجمة',
  'translate': 'ترجمة',
  'feed.ai_improved': 'تم التحسين بالذكاء الاصطناعي!',
  'feed.ai_failed': 'تعذّر التحسين بالذكاء الاصطناعي. حاول مجدداً.',
  'feed.improving': 'جارٍ التحسين...',
  'feed.photo': 'صورة',
  'feed.video': 'فيديو',
  'feed.video_selected': 'تم اختيار فيديو',
  'common.you': 'أنت',
  'feed.post_detail': 'المنشور',
  'network.my_network': 'شبكتي',
  'network.search_hint': 'ابحث عن اتصالات...',
  'network.requests_count': 'الطلبات ({count})',
  'network.connections_label': 'الاتصالات',
  'network.member': 'عضو',
  'network.new_request': 'طلب جديد',
  'network.no_requests_title': 'لا توجد طلبات معلّقة',
  'network.no_requests_subtitle': 'عندما يرسل لك شخص ما طلب تواصل، سيظهر هنا.',

  'network.suggestions': 'أشخاص قد تعرفهم',
  'network.suggestions_empty': 'لا توجد اقتراحات الآن. اسحب للأسفل للتحديث.',
  'network.empty_subtitle':
      'تواصل مع الأشخاص الذين تعرفهم ووسّع شبكتك المهنية.',
  'notifications.empty_title': 'لا توجد إشعارات بعد',
  'notifications.empty_subtitle':
      'ستظهر هنا تحديثات منشوراتك واتصالاتك ووظائفك.',
  'network.search_failed_title': 'فشل البحث',
  'network.search_failed': 'فشل البحث. حاول مرة أخرى.',
  'network.no_results_msg': 'لا توجد نتائج',
  'network.no_results_subtitle': 'جرّب اسماً أو كلمة مفتاحية مختلفة.',
  'network.request_accepted': 'تم قبول الطلب!',
  'network.accept_failed': 'تعذّر قبول الطلب',
  'network.request_ignored': 'تم تجاهل الطلب',
  'network.ignore_failed': 'تعذّر تجاهل الطلب',
  'network.request_sent': 'تم إرسال طلب التواصل!',
  'network.send_failed': 'تعذّر إرسال الطلب',
  'network.follow_failed': 'تعذّرت متابعة هذا المستخدم',
  'jobs.title': 'وظائف Profit Connect',
  'jobs.my_apps': 'طلباتي',
  'jobs.search_titles': 'ابحث عن المسميات، الشركات...',
  'jobs.featured_role': 'وظائف مميزة',
  'jobs.recommended': 'مقترحة لك',
  'jobs.showing': 'عرض وظائف {type}',
  'jobs.no_jobs': 'لا توجد وظائف',
  'jobs.high_match': 'تطابق عالي',

  'jobs.salary_on_request': 'الراتب عند الطلب',
  'jobs.company_unavailable': 'صفحة الشركة غير متاحة',
  'jobs.level_label': 'المستوى',
  'jobs.status_label': 'الحالة',
  'jobs.open': 'مفتوحة',
  'jobs.about_title': 'عن الوظيفة',
  'jobs.no_description': 'لا يوجد وصف لهذه الوظيفة.',
  'jobs.requirements_title': 'المتطلبات',
  'jobs.no_requirements': 'لا توجد متطلبات محددة.',
  'jobs.easy_apply': 'تقديم سريع',
  'jobs.apply_failed': 'تعذّر التقديم لهذه الوظيفة',
  'jobs.save_failed': 'تعذّر حفظ هذه الوظيفة',
  'jobs.applied_to': 'تم إرسال طلب التقديم لـ {title}',
  'jobs.apply_error': 'فشل إرسال الطلب. ارفع سيرة ذاتية بصيغة PDF أو Word.',
  'jobs.posted': 'نُشر {time}',
  'jobs.empty_search': 'ابحث عن وظائف بالعنوان أو الكلمات المفتاحية أو الشركة',
  'jobs.no_results_for': 'لا توجد وظائف مطابقة لـ "{query}"',
  'jobs.try_adjusting': 'جرّب تعديل الكلمات المفتاحية أو الفلاتر',
  'jobs.load_failed': 'تعذّر تحميل الطلبات',
  'jobs.untitled': 'وظيفة بدون عنوان',
  'jobs.yesterday': 'أمس',
  'jobs.days_ago': 'منذ {d} أيام',
  'jobs.no_apps_title': 'لا توجد طلبات بعد',
  'jobs.no_apps_subtitle': 'عندما تتقدم لوظيفة، ستظهر هنا.',

  // messages
  'messages.load_failed': 'تعذّر تحميل المحادثات',
  'messages.unknown': 'غير معروف',
  'messages.search_hint': 'ابحث عن الأشخاص أو الرسائل...',
  'messages.search_people': 'الأشخاص',
  'messages.search_no_results': 'لا توجد نتائج لـ "{q}"',
  'search_people': 'البحث عن أشخاص',
  'search.type_hint': 'اكتب حرفين على الأقل للبحث',
  'messages.no_conversations': 'لا توجد محادثات بعد',
  'messages.compose_soon': 'الإنشاء قريباً',
  'messages.new_message': 'رسالة جديدة',
  'messages.send_failed': 'فشل إرسال الرسالة: {error}',
  'messages.online': 'متصل الآن',
  'messages.empty_chat': 'لا توجد رسائل بعد. قل مرحباً!',
  'messages.write_message': 'اكتب رسالة...',

  // profile
  'profile.follow_failed': 'تعذّر تحديث حالة المتابعة',
  'profile.avatar_updated': 'تم تحديث الصورة الشخصية!',
  'profile.avatar_failed': 'تعذّر تحديث الصورة الشخصية',
  'profile.guest': 'ضيف',
  'profile.add_title': 'أضف مسمىً مهنياً',
  'profile.no_bio': 'لا يوجد وصف بعد. اضغط "تعديل الملف" لإضافته.',
  'profile.uploading': 'جارٍ الرفع...',
  'profile.change_photo': 'تغيير الصورة',
  'profile.full_name': 'الاسم الكامل',
  'profile.professional_title': 'المسمى المهني',
  'profile.about': 'نبذة',
  'profile.top_skills': 'أبرز المهارات',
  'profile.birth_date': 'تاريخ الميلاد',
  'profile.pick_birth_date': 'اختر تاريخ الميلاد',
  'profile.gender': 'الجنس',
  'profile.pick_gender': 'اختر الجنس',
  'profile.updated': 'تم تحديث الملف بنجاح!',
  'profile.update_failed': 'تعذّر تحديث الملف: {error}',
  'profile.name_hint': 'جنى دو',
  'profile.current_role': 'الدور الحالي',
  'profile.role_hint': 'مثال: مصمم منتجات',

  // network









  'network.no_results': 'لم يتم العثور على أشخاص',






  // jobs






































  // messages










  // settings
  'settings.appearance': 'المظهر',
  'settings.email_notifications': 'إشعارات البريد',
  'settings.push_notifications': 'الإشعارات الفورية',
  'settings.profile_visibility': 'ظهور الملف الشخصي',
  'settings.public': 'عام',
  'settings.connections_only': 'الروابط فقط',
  'settings.private': 'خاص',
  'settings.account': 'الحساب',
  'settings.edit_profile': 'تعديل الملف الشخصي',
  'settings.change_password': 'تغيير كلمة المرور',
  'settings.services': 'الخدمات',
  'settings.wallet': 'المحفظة',
  'settings.payments': 'الدفعات',
  'settings.salaries': 'الرواتب',
  'settings.projects': 'المشاريع',
  'settings.company_dashboard': 'لوحة الشركة',
  'settings.company_dashboard_hint': 'متاحة لأصحاب وموظفي الشركات',
  'settings.support': 'الدعم',
  'settings.help': 'مركز المساعدة',
  'settings.sync_error': 'تعذّرت مزامنة الإعدادات',

  // help & support
  'help_support.title': 'المساعدة والدعم',
  'help_support.faq': 'الأسئلة الشائعة',
  'help_support.q1': 'كيف أنشئ منشوراً؟',
  'help_support.a1':
      'انتقل إلى تبويب الرئيسية، اضغط على صندوق الإنشاء في الأعلى، اكتب تحديثك ثم اضغط نشر.',
  'help_support.q2': 'كيف أتقدّم لوظيفة؟',
  'help_support.a2':
      'افتح تبويب الوظائف، اختر الوظيفة التي تناسبك واضغط زر التقديم. تابع طلباتك من "طلباتي".',
  'help_support.q3': 'كيف أعدّل بيانات حسابي؟',
  'help_support.a3':
      'افتح الإعدادات من القائمة ثم "تعديل الملف الشخصي" لتحديث معلوماتك الشخصية.',
  'help_support.contact': 'تواصل مع الدعم',
  'help_support.contact_hint': 'راسلنا عبر البريد وسيرد عليك فريقنا قريباً',
  'help_support.community': 'المجتمع',
  'help_support.community_title': 'زيارة ملفك الشخصي',
  'help_support.community_hint': 'راجع وحسّن ملفك الشخصي العام',

  // about

  'about.tagline': 'شبكة مهنية والبحث عن عمل أصبح أسهل.',
  'about.version': 'الإصدار',
  'about.company_name': 'بروفيت كونكت',
  'about.website': 'www.profitconnect.com',
  'about.copyright': 'جميع الحقوق محفوظة © 2026 بروفيت كونكت.',
  'about.disclaimer':
      'بروفيت كونكت منصة تواصل مهني، والمحتوى المنشور من المستخدمين يعبّر عن آراء أصحابه فقط.',

  // company
  'company.title': 'شركة',
  'company.no_linked': 'لا توجد شركة مرتبطة بحسابك',
  'company.dashboard': 'لوحة الشركة',




  'company.total_jobs': 'إجمالي الوظائف',
  'company.open_jobs': 'الوظائف المفتوحة',
  'company.team': 'الفريق',

  'company.no_employees': 'لا يوجد موظفون بعد',
  'company.add_employee': 'إضافة موظف',
  'company.remove_employee': 'إزالة',
  'company.employee_email': 'البريد الإلكتروني',
  'company.employee_password': 'كلمة المرور',
  'company.employee_first': 'الاسم الأول',
  'company.employee_last': 'اسم العائلة',
  'company.employee_position': 'المنصب',
  'company.employee_added': 'تمت إضافة الموظف',
  'company.employee_removed': 'تمت إزالة الموظف',

  'company.post_job': 'نشر وظيفة',
  'company.job_title': 'المسمى الوظيفي',
  'company.job_location': 'الموقع',
  'company.job_type': 'النوع',
  'company.job_level': 'المستوى',
  'company.workplace': 'مكان العمل',
  'company.min_salary': 'الحد الأدنى للراتب',
  'company.max_salary': 'الحد الأعلى للراتب',
  'company.description': 'الوصف',
  'company.job_posted': 'تم نشر الوظيفة',

  'company.no_applicants': 'لا يوجد متقدمون بعد',
  'company.shortlist': 'قائمة مختصرة',
  'company.accept': 'قبول',
  'company.reject': 'رفض',
  'company.status_updated': 'تم تحديث الحالة إلى: {status}',
  'company.setup_title': 'أنشئ ملف شركتك',
  'company.setup_subtitle': 'أخبر المرشحين عن شركتك',
  'company.add_logo': 'إضافة شعار',
  'company.access_logo': 'إضافة شعار (قريباً)',
  'company.name': 'اسم الشركة',
  'company.name_hint': 'مثال: TechCorp Inc.',
  'company.required': 'مطلوب',
  'company.industry': 'المجال',
  'company.select_industry': 'اختر المجال',
  'company.desc_hint': 'حدثنا عن شركتك...',
  'company.website': 'الموقع الإلكتروني',
  'company.website_hint': 'https://yourcompany.com',
  'company.location': 'الموقع',
  'company.location_hint': 'المدينة، الدولة',
  'company.location_required': 'أدخل المدينة والدولة (مثال: عمان، الأردن)',
  'company.employees_count': 'الموظفون ({count})',
  'company.jobs_count': 'الوظائف ({count})',
  'company.no_jobs': 'لا توجد وظائف منشورة بعد',
  'company.status_value': 'الحالة: {status}',
  'company.email_required': 'البريد الإلكتروني مطلوب',
  'company.employee_added_creds':
      'تمت إضافة الموظف!\nالدخول: {email} / {password}',
  'company.add_employee_failed': 'تعذر إضافة الموظف',
  'company.remove_employee_failed': 'تعذر إزالة الموظف',
  'company.job_title_required': 'المسمى الوظيفي مطلوب',
  'company.post_failed': 'تعذر نشر الوظيفة',
  'company.status_update_failed': 'تعذر تحديث الحالة',
  'company.employee_name': 'موظف',
  'company.applicant': 'متقدم',
  'company.load_failed': 'تعذر تحميل الشركة',
  'company.follow_failed': 'تعذر تحديث حالة المتابعة',
  'company.add_admin': 'إضافة مدير للشركة',
  'company.admin_id_hint': 'أدخل معرف المستخدم',
  'company.admin_added': 'تمت إضافة المدير بنجاح!',
  'company.admin_add_failed': 'تعذر إضافة المدير. تحقق من معرف المستخدم.',
  'company.followers_count': '{count} متابع',
  'company.overview': 'نظرة عامة',
  'company.followers_title': 'المتابعون ({count})',
  'company.recent_jobs': 'أحدث الوظائف',
  'company.stat_open': 'مفتوحة',
  'company.stat_applicants': 'المتقدمون',
  'company.stat_followers': 'المتابعون',
  'company.stat_rating': 'التقييم',
  'company.stat_today': 'اليوم',
  'company.stat_week': 'هذا الأسبوع',
  'company.stat_growth': 'النمو',

  // wallet
  'wallet.title': 'محفظتي',


  'wallet.total_earned': 'إجمالي المكاسب',




  'wallet.withdraw_failed': 'فشل السحب',


  'wallet.no_transactions': 'ستظهر معاملاتك هنا',
  'wallet.escrow': 'الحساب الضامن (دفعات محجوزة)',
  'wallet.no_escrow': 'لا توجد دفعات محجوزة',
  'wallet.release': 'تحرير الدفعة',
  'wallet.released': 'تم تحرير الدفعة إلى محفظة المستلم',
  'wallet.release_failed': 'تعذّر تحرير الدفعة',
  'wallet.project': 'مشروع',








  'wallet.available_balance': 'الرصيد المتاح',
  'wallet.in_escrow': 'الضمان',
  'wallet.withdrawn': 'المسحوب',
  'wallet.withdraw_btn': 'سحب الأموال',
  'wallet.withdraw_title': 'طلب سحب',
  'wallet.amount_label': 'المبلغ (دولار)',
  'wallet.method': 'طريقة السحب',
  'wallet.bank_transfer': 'تحويل بنكي',
  'wallet.cash': 'نقدي',
  'wallet.other': 'أخرى',
  'wallet.bank_name': 'اسم البنك',
  'wallet.account_holder': 'اسم صاحب الحساب',
  'wallet.request_withdraw': 'طلب',
  'wallet.invalid_amount': 'يرجى إدخال مبلغ صحيح',
  'wallet.withdraw_requested': 'تم طلب السحب',
  'wallet.withdraw_cancelled': 'تم إلغاء السحب',
  'wallet.cancel_failed': 'تعذر إلغاء السحب',
  'wallet.recent_transactions': 'أحدث المعاملات',
  'wallet.withdrawals': 'المسحوبات',
  'wallet.withdrawal_row': 'سحب بمبلغ {amount}',

  // payments
  'payments.title': 'الدفعات',

  'payments.received': 'مستلمة',
  'payments.sent': 'مرسلة',




  'payments.none': 'لا توجد دفعات',
  'payments.release': 'تحرير',
  'payments.released': 'تم تحرير الدفعة!',
  'payments.release_failed': 'تعذر تحرير الدفعة',
  'payments.project_payment': 'دفعة مشروع',

  // salaries
  'salaries.title': 'الرواتب',


  'salaries.average': 'متوسط الراتب',

  'salaries.no_records': 'لا توجد سجلات رواتب',




  'salaries.filter_title': 'المسمى الوظيفي',
  'salaries.filter_country': 'الدولة',
  'salaries.filter_level': 'مستوى الخبرة',




  'salaries.records_count': 'سجلات الرواتب ({count})',

  // projects
  'projects.title': 'المشاريع',
  'projects.my': 'مشاريعي',
  'projects.proposals': 'عروضي',
  'projects.empty': 'لا توجد مشاريع بعد',
  'projects.empty_proposals': 'لا توجد عروض بعد',
  'projects.untitled_project': 'مشروع بدون عنوان',
  'projects.budget_label': 'الميزانية: {amount}',
  'projects.bid_label': 'عرضي: {amount}',
  'projects.client_label': 'العميل: {name}',
  'projects.no_proposals_received': 'لم يتم استلام عروض بعد',
  'projects.proposals_count': 'العروض ({count})',
  'projects.freelancer': 'مستقل',

  'projects.deadline': 'الموعد النهائي',











  'projects.add_project': 'إضافة مشروع',
  'projects.budget_min': 'أدنى ميزانية',
  'projects.budget_max': 'أقصى ميزانية',
  'projects.category': 'الفئة',
  'projects.description': 'الوصف',
  'projects.select_deadline': 'اختر الموعد النهائي',
  'projects.title_field': 'العنوان',

  // profile
  'profile.edit': 'تعديل الملف الشخصي',
  'followers.empty': 'لا يوجد متابعون بعد',
  'followers.empty_following': 'لا تتابع أحدًا بعد',







  'profile.my_company': 'شركتي',
};

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  String tr(String key, [Map<String, String>? args]) =>
      l10n.translate(key, args);
}
