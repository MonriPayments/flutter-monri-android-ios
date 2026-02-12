class ScanDocValidationResponse {
  final String? transactionID;
  final String? uploadedAt;
  final String? productName;
  final List<String>? errors;
  final List<String>? warnings;
  final int? status;
  final String? method;
  final int? infoCode;
  final double? analysisTime;
  final List<List<double>>? keypoints;
  final bool? validated;
  final int? index;
  final String? info;
  final double? detectedBlurValue;

  ScanDocValidationResponse({
    this.transactionID,
    this.uploadedAt,
    this.productName,
    this.errors,
    this.warnings,
    this.status,
    this.method,
    this.infoCode,
    this.analysisTime,
    this.keypoints,
    this.validated,
    this.index,
    this.info,
    this.detectedBlurValue
  });

  factory ScanDocValidationResponse.fromJson(Map<String, dynamic> json) {
    return ScanDocValidationResponse(
      transactionID: json['TransactionID'] as String?,
      uploadedAt: json['UploadedAt'] as String?,
      productName: json['ProductName'] as String?,
      errors: (json['Errors'] as List?)?.map((e) => e as String).toList(),
      warnings: (json['Warnings'] as List?)?.map((e) => e as String).toList(),
      status: json['Status'] as int?,
      method: json['Method'] as String?,
      infoCode: json['InfoCode'] as int?,
      analysisTime: (json['AnalysisTime'] as num?)?.toDouble(),
      keypoints: (json['Keypoints'] as List?)
          ?.map(
            (e) => (e as List).map((v) => (v as num).toDouble()).toList(),
      )
          .toList(),
      validated: json['Validated'] as bool?,
      index: json['Index'] as int?,
      info: json['Info'] as String?,
      detectedBlurValue: json['DetectedBlurValue'] as double?
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionID': transactionID,
      'uploadedAt': uploadedAt,
      'productName': productName,
      'errors': errors,
      'warnings': warnings,
      'status': status,
      'method': method,
      'infoCode': infoCode,
      'analysisTime': analysisTime,
      'keypoints': keypoints,
      'validated': validated,
      'index': index,
      'info': info,
      'detectedBlurValue': detectedBlurValue
    };
  }
}
