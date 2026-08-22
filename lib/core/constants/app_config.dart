class AppConfig {
  AppConfig._();

  /// Default Admin Dashboard 4-digit PIN
  static const String adminPin = '2026';

  /// App Version Info
  static const String appVersion = '1.0.0+1';
  static const String appName = 'Biggopti';
  static const String appNameBangla = 'বিজ্ঞপ্তি';
  static const String tagline = 'AI-powered Bangladeshi Notice Digest';
  static const String taglineBangla = 'কৃত্রিম বুদ্ধিমত্তা চালিত সরকারি ও ব্যাংক চাকরির নোটিশ ডাইজেস্ট';

  /// Default language code ('bn' = Bangla, 'en' = English)
  static const String defaultLocale = 'bn';

  /// Default mock BDapps toggle (true = mock OTP in dev, false = real cPanel gateway)
  static const bool useMockBdapps = true;
}
