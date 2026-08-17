class CircularModel {
  final String id;
  final String title;
  final String orgName;
  final String category; // 'govt', 'bank', 'varsity', 'other'
  final String deadline;
  final String ageLimit;
  final String eligibility;
  final List<String> summaryBullets;
  final String originalPdfUrl;
  final String pdfHash;
  final bool isHighPriority;
  final String source; // 'seed', 'scraped', 'manual'
  final DateTime createdAt;

  CircularModel({
    required this.id,
    required this.title,
    required this.orgName,
    required this.category,
    required this.deadline,
    required this.ageLimit,
    required this.eligibility,
    required this.summaryBullets,
    required this.originalPdfUrl,
    required this.pdfHash,
    this.isHighPriority = false,
    this.source = 'scraped',
    required this.createdAt,
  });

  factory CircularModel.fromJson(Map<String, dynamic> json) {
    List<String> bullets = [];
    if (json['summary_bullets'] != null) {
      if (json['summary_bullets'] is List) {
        bullets = List<String>.from(json['summary_bullets']);
      } else if (json['summary_bullets'] is String) {
        bullets = [json['summary_bullets'].toString()];
      }
    }

    return CircularModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      orgName: json['org_name'] ?? '',
      category: json['category'] ?? 'other',
      deadline: json['deadline'] ?? 'নির্দিষ্ট নয়',
      ageLimit: json['age_limit'] ?? 'নির্দিষ্ট নয়',
      eligibility: json['eligibility'] ?? '',
      summaryBullets: bullets,
      originalPdfUrl: json['original_pdf_url'] ?? '',
      pdfHash: json['pdf_hash'] ?? '',
      isHighPriority: json['is_high_priority'] ?? false,
      source: json['source'] ?? 'scraped',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'org_name': orgName,
      'category': category,
      'deadline': deadline,
      'age_limit': ageLimit,
      'eligibility': eligibility,
      'summary_bullets': summaryBullets,
      'original_pdf_url': originalPdfUrl,
      'pdf_hash': pdfHash,
      'is_high_priority': isHighPriority,
      'source': source,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
