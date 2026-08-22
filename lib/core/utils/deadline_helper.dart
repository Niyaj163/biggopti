class DeadlineHelper {
  static const Map<String, String> _banglaToEnglishDigits = {
    '০': '0',
    '১': '1',
    '২': '2',
    '৩': '3',
    '৪': '4',
    '৫': '5',
    '৬': '6',
    '৭': '7',
    '৮': '8',
    '৯': '9',
  };

  static const Map<String, int> _banglaMonths = {
    'জানুয়ারি': 1,
    'ফেব্রুয়ারি': 2,
    'মার্চ': 3,
    'এপ্রিল': 4,
    'মে': 5,
    'জুন': 6,
    'জুলাই': 7,
    'আগস্ট': 8,
    'সেপ্টেম্বর': 9,
    'অক্টোবর': 10,
    'নভেম্বর': 11,
    'ডিসেম্বর': 12,
  };

  static const Map<String, int> _englishMonths = {
    'january': 1, 'jan': 1,
    'february': 2, 'feb': 2,
    'march': 3, 'mar': 3,
    'april': 4, 'apr': 4,
    'may': 5,
    'june': 6, 'jun': 6,
    'july': 7, 'jul': 7,
    'august': 8, 'aug': 8,
    'september': 9, 'sep': 9, 'sept': 9,
    'october': 10, 'oct': 10,
    'november': 11, 'nov': 11,
    'december': 12, 'dec': 12,
  };

  /// Convert Bangla numerals to English digits
  static String convertBanglaDigits(String input) {
    var output = input;
    _banglaToEnglishDigits.forEach((bn, en) {
      output = output.replaceAll(bn, en);
    });
    return output;
  }

  /// Parse various Bangla, English, and ISO formatted deadline strings to DateTime
  static DateTime? parseDeadline(String? deadlineStr) {
    if (deadlineStr == null || deadlineStr.trim().isEmpty) return null;

    final cleanStr = deadlineStr.trim();
    if (cleanStr == 'নির্দিষ্ট নয়' ||
        cleanStr == 'প্রযোজ্য নয়' ||
        cleanStr == 'চলমান') {
      return null;
    }

    // Try standard ISO parsing first (YYYY-MM-DD)
    try {
      final isoDate = DateTime.tryParse(cleanStr);
      if (isoDate != null) return isoDate;
    } catch (_) {}

    final normalized = convertBanglaDigits(cleanStr).toLowerCase();

    // 1. Check for Bangla Month names (e.g., "২৮ আগস্ট ২০২৬", "28 আগস্ট 2026")
    for (final entry in _banglaMonths.entries) {
      if (cleanStr.contains(entry.key)) {
        final month = entry.value;
        final digits = RegExp(r'\d+').allMatches(normalized).map((m) => int.parse(m.group(0)!)).toList();
        if (digits.length >= 2) {
          // If first number is day and second is year (e.g., 28 and 2026)
          int day = digits[0];
          int year = digits[1];
          if (day > 31 && year <= 31) {
            final temp = day;
            day = year;
            year = temp;
          }
          if (year < 100) year += 2000;
          return DateTime(year, month, day, 23, 59, 59);
        } else if (digits.length == 1) {
          // Only day specified, assume current year
          final day = digits[0];
          final year = DateTime.now().year;
          return DateTime(year, month, day, 23, 59, 59);
        }
      }
    }

    // 2. Check for English Month names (e.g., "28 August 2026", "Aug 28, 2026")
    for (final entry in _englishMonths.entries) {
      if (normalized.contains(entry.key)) {
        final month = entry.value;
        final digits = RegExp(r'\d+').allMatches(normalized).map((m) => int.parse(m.group(0)!)).toList();
        if (digits.length >= 2) {
          int day = digits[0];
          int year = digits[1];
          if (day > 31 && year <= 31) {
            final temp = day;
            day = year;
            year = temp;
          }
          if (year < 100) year += 2000;
          return DateTime(year, month, day, 23, 59, 59);
        }
      }
    }

    // 3. Check for DD/MM/YYYY or DD-MM-YYYY format
    final slashMatch = RegExp(r'(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{2,4})').firstMatch(normalized);
    if (slashMatch != null) {
      int day = int.parse(slashMatch.group(1)!);
      int month = int.parse(slashMatch.group(2)!);
      int year = int.parse(slashMatch.group(3)!);
      if (year < 100) year += 2000;
      if (month <= 12 && day <= 31) {
        return DateTime(year, month, day, 23, 59, 59);
      }
    }

    return null;
  }

  /// Returns true if the application deadline has already passed
  static bool isExpired(String? deadlineStr) {
    final parsed = parseDeadline(deadlineStr);
    if (parsed == null) {
      // If deadline is ongoing or unspecified, consider it not expired so users don't miss it
      return false;
    }

    // End of deadline day (inclusive until 23:59:59)
    final endOfDeadline = DateTime(parsed.year, parsed.month, parsed.day, 23, 59, 59);
    return DateTime.now().isAfter(endOfDeadline);
  }

  /// Returns true if the circular is currently open for applications
  static bool isActive(String? deadlineStr) => !isExpired(deadlineStr);
}
