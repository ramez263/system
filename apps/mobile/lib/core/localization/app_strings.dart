import 'package:flutter/widgets.dart';

class AppStrings {
  final Locale locale;

  AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings) ??
        AppStrings(const Locale('en'));
  }

  bool get isArabic => locale.languageCode == 'ar';

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Ramez Tunnel Plus',
      'app_subtitle': 'Next-Gen Secure Tunneling & VPN',
      'tap_to_connect': 'TAP TO CONNECT',
      'connected': 'CONNECTED',
      'connecting': 'CONNECTING...',
      'disconnected': 'DISCONNECTED',
      'reconnecting': 'RECONNECTING...',
      'server': 'Server',
      'protocol': 'Protocol',
      'latency': 'Latency',
      'download_speed': 'Download',
      'upload_speed': 'Upload',
      'duration': 'Duration',
      'public_ip': 'Public IP',
      'device_identity': 'Device Identity',
      'guest_session': 'Guest Session (No Login)',
      'servers_title': 'Servers',
      'search_servers': 'Search by country or city...',
      'best_server': 'Fastest Server (Auto)',
      'filter_all': 'All',
      'filter_free': 'Free',
      'filter_vip': 'VIP',
      'configs_title': 'Configurations',
      'import_config': 'Import Config',
      'import_file': 'Import .ovpn / .rtp File',
      'import_clipboard': 'Import from Clipboard',
      'import_qr': 'Scan QR Code',
      'create_config': 'Create Custom Config',
      'config_editor': 'Configuration Editor',
      'statistics_title': 'Statistics',
      'history_title': 'Connection History',
      'plans_title': 'Subscription Plans',
      'current_plan': 'Current Tier: Free',
      'appearance_title': 'Appearance & Themes',
      'language_title': 'Language',
      'notifications_title': 'Notifications',
      'advanced_settings_title': 'Advanced Network Settings',
      'app_settings_title': 'App Settings',
      'support_center_title': 'Support Center',
      'faq_title': 'Frequently Asked Questions',
      'about_title': 'About Ramez Tunnel Plus',
      'kill_switch': 'Kill Switch (Always-on VPN)',
      'custom_dns': 'Custom DNS Resolvers',
      'split_tunneling': 'Split Tunneling (Exclude Apps)',
      'battery_optimization': 'Battery Optimization Guidance',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'retry': 'Retry',
      'export_csv': 'Export History to CSV',
      'erase_account': 'Delete Device Data (GDPR)',
      'no_configs_found': 'No custom configurations found.',
      'no_servers_found': 'No servers match your search criteria.',
      'offline_warning': 'No internet connection detected.',
      'error_occurred': 'An unexpected error occurred.',
      'changelog_title': 'Changelog & Logs',
      'clear_logs': 'Clear Logs',
      'logs_cleared': 'Logs cleared successfully.',
      'virtual_ip': 'Virtual Secure IP',
      'real_ip': 'Original Public IP',
      'copied_ip': 'IP address copied to clipboard',
      'admin_dashboard_title': 'Admin Dashboard',
      'admin_password_prompt': 'Enter Admin Password',
      'upload_server': 'Upload Server',
      'upload_config': 'Upload Configuration',
    },
    'ar': {
      'app_name': 'رامز تنل بلس',
      'app_subtitle': 'تطبيق الاتصال والأنفاق الآمن الفائق',
      'tap_to_connect': 'اضغط للاتصال',
      'connected': 'متصل الآن',
      'connecting': 'جاري الاتصال...',
      'disconnected': 'غير متصل',
      'reconnecting': 'إعادة الاتصال...',
      'server': 'الخادم',
      'protocol': 'البروتوكول',
      'latency': 'زمن الاستجابة',
      'download_speed': 'سرعة التنزيل',
      'upload_speed': 'سرعة الرفع',
      'duration': 'مدة الجلسة',
      'public_ip': 'عنوان IP العام',
      'device_identity': 'هوية الجهاز',
      'guest_session': 'جلسة جهاز مباشرة (بدون حساب)',
      'servers_title': 'قائمة الخوادم',
      'search_servers': 'البحث بالدولة أو المدينة...',
      'best_server': 'الخادم الأسرع (تلقائي)',
      'filter_all': 'الكل',
      'filter_free': 'مجاني',
      'filter_vip': 'مميز VIP',
      'configs_title': 'الإعدادات والملفات',
      'import_config': 'استيراد ملف إعداد',
      'import_file': 'استيراد ملف .ovpn / .rtp',
      'import_clipboard': 'استيراد من الحافظة',
      'import_qr': 'مسح رمز الاستجابة QR',
      'create_config': 'إنشاء ملف مخصص',
      'config_editor': 'محرر الإعدادات المتقدمة',
      'statistics_title': 'الإحصائيات واستهلاك البيانات',
      'history_title': 'سجل الاتصالات السابقة',
      'plans_title': 'خطط الاشتراك والترقية',
      'current_plan': 'الخطة الحالية: مجانية',
      'appearance_title': 'المظهر والألوان',
      'language_title': 'اللغة (Language)',
      'notifications_title': 'الإشعارات والتنبيهات',
      'advanced_settings_title': 'إعدادات الشبكة المتقدمة',
      'app_settings_title': 'إعدادات التطبيق العامة',
      'support_center_title': 'مركز المساعدة والدعم الفني',
      'faq_title': 'الأسئلة الشائعة',
      'about_title': 'عن رامز تنل بلس',
      'kill_switch': 'مفتاح الإيقاف التلقائي (Kill Switch)',
      'custom_dns': 'خوادم DNS مخصصة',
      'split_tunneling': 'استثناء التطبيقات (Split Tunneling)',
      'battery_optimization': 'إرشادات تحسين أداء البطارية',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'retry': 'إعادة المحاولة',
      'export_csv': 'تصدير السجل إلى ملف CSV',
      'erase_account': 'مسح بيانات الجهاز نهائياً (GDPR)',
      'no_configs_found': 'لم يتم العثور على أي ملفات إعداد.',
      'no_servers_found': 'لا توجد خوادم مطابقة لمعايير البحث.',
      'offline_warning': 'لا يوجد اتصال بالإنترنت حالياً.',
      'error_occurred': 'حدث خطأ غير متوقع.',
      'changelog_title': 'سجل التغييرات والسجلات',
      'clear_logs': 'مسح السجلات',
      'logs_cleared': 'تم مسح السجلات بنجاح.',
      'virtual_ip': 'عنوان IP الافتراضي (مشفر)',
      'real_ip': 'عنوان IP الحقيقي (مكشوف)',
      'copied_ip': 'تم نسخ عنوان IP إلى الحافظة',
      'admin_dashboard_title': 'لوحة تحكم المسؤول',
      'admin_password_prompt': 'أدخل كلمة مرور المسؤول',
      'upload_server': 'رفع خادم جديد',
      'upload_config': 'رفع ملف إعداد جديد',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String get appName => get('app_name');
  String get appSubtitle => get('app_subtitle');
  String get tapToConnect => get('tap_to_connect');
  String get connected => get('connected');
  String get connecting => get('connecting');
  String get disconnected => get('disconnected');
  String get server => get('server');
  String get protocol => get('protocol');
  String get latency => get('latency');
  String get downloadSpeed => get('download_speed');
  String get uploadSpeed => get('upload_speed');
  String get duration => get('duration');
  String get publicIp => get('public_ip');
  String get deviceIdentity => get('device_identity');
  String get guestSession => get('guest_session');
  String get serversTitle => get('servers_title');
  String get searchServers => get('search_servers');
  String get bestServer => get('best_server');
  String get configsTitle => get('configs_title');
  String get importConfig => get('import_config');
  String get statisticsTitle => get('statistics_title');
  String get historyTitle => get('history_title');
  String get plansTitle => get('plans_title');
  String get appearanceTitle => get('appearance_title');
  String get languageTitle => get('language_title');
  String get advancedSettingsTitle => get('advanced_settings_title');
  String get supportCenterTitle => get('support_center_title');
  String get aboutTitle => get('about_title');
  String get changelogTitle => get('changelog_title');
  String get clearLogs => get('clear_logs');
  String get logsCleared => get('logs_cleared');
  String get virtualIp => get('virtual_ip');
  String get realIp => get('real_ip');
  String get copiedIp => get('copied_ip');
  String get adminDashboardTitle => get('admin_dashboard_title');
  String get adminPasswordPrompt => get('admin_password_prompt');
  String get uploadServer => get('upload_server');
  String get uploadConfig => get('upload_config');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
