class UserProfile {
  final int age;
  final String highestDegree; // 'hsc', 'bachelor', 'masters', 'diploma'
  final bool isQuotaHolder; // Freedom fighter quota / ethnic / disability
  final String district;

  UserProfile({
    required this.age,
    required this.highestDegree,
    this.isQuotaHolder = false,
    this.district = '',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      age: json['age'] ?? 24,
      highestDegree: json['highest_degree'] ?? 'bachelor',
      isQuotaHolder: json['is_quota_holder'] ?? false,
      district: json['district'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'highest_degree': highestDegree,
      'is_quota_holder': isQuotaHolder,
      'district': district,
    };
  }

  /// Check if user profile matches a circular's eligibility guidelines
  bool checkEligibility(String ageLimitText, String eligibilityText) {
    // Check age bounds
    int maxAge = isQuotaHolder ? 32 : 30;
    if (age > maxAge) return false;
    return true;
  }
}
