class ScraperLogModel {
  final int? id;
  final String sourceUrl;
  final String? pdfHash;
  final String status;
  final String? errorMessage;
  final DateTime ranAt;

  const ScraperLogModel({
    this.id,
    required this.sourceUrl,
    this.pdfHash,
    required this.status,
    this.errorMessage,
    required this.ranAt,
  });

  factory ScraperLogModel.fromJson(Map<String, dynamic> json) {
    return ScraperLogModel(
      id: json['id'] as int?,
      sourceUrl: json['source_url'] as String? ?? 'Unknown Source',
      pdfHash: json['pdf_hash'] as String?,
      status: json['status'] as String? ?? 'UNKNOWN',
      errorMessage: json['error_message'] as String?,
      ranAt: json['ran_at'] != null
          ? DateTime.tryParse(json['ran_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'source_url': sourceUrl,
      'pdf_hash': pdfHash,
      'status': status,
      'error_message': errorMessage,
      'ran_at': ranAt.toIso8601String(),
    };
  }
}
