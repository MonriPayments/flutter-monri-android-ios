class ScanDocExtractionResponse {
  final String transactionID;
  final String uploadedAt;
  final String productName;
  final List<String> errors;
  final List<String> warnings;
  final int status;
  final String method;
  final int infoCode;
  final double analysisTime;
  final String? os;
  final String? browser;
  final String? device;
  final Data? data;
  final ImageData? imageData;

  ScanDocExtractionResponse({
    required this.transactionID,
    required this.uploadedAt,
    required this.productName,
    required this.errors,
    required this.warnings,
    required this.status,
    required this.method,
    required this.infoCode,
    required this.analysisTime,
    this.os,
    this.browser,
    this.device,
    this.data,
    this.imageData,
  });

  static ScanDocExtractionResponse? fromJson(Map<String, dynamic>? body) {
    if (body == null) return null;

    try {
      return ScanDocExtractionResponse(
        transactionID: body['TransactionID']?.toString() ?? '',
        uploadedAt: body['UploadedAt']?.toString() ?? '',
        productName: body['ProductName']?.toString() ?? '',
        errors: List<String>.from(body['Errors'] ?? const []),
        warnings: List<String>.from(body['Warnings'] ?? const []),
        status: body['Status'] is int
            ? body['Status']
            : int.tryParse(body['Status']?.toString() ?? '0') ?? 0,
        method: body['Method']?.toString() ?? '',
        infoCode: body['InfoCode'] is int
            ? body['InfoCode']
            : int.tryParse(body['InfoCode']?.toString() ?? '0') ?? 0,
        analysisTime:
        (body['AnalysisTime'] as num?)?.toDouble() ?? 0.0,
        os: body['OS']?.toString(),
        browser: body['Browser']?.toString(),
        device: body['Device']?.toString(),
        data: body['Data'] != null
            ? Data.fromJson(Map<String, dynamic>.from(body['Data']))
            : null,
        imageData: body['ImageData'] != null
            ? ImageData.fromJson(Map<String, dynamic>.from(body['ImageData']))
            : null,
      );
    } catch (e) {
      // Optional: log error here
      return null;
    }
  }
}
class Data {
  final String? holdersName;
  final String? luhnCheck;
  final String? cardNumber;
  final String? expiryDate;
  final String? extractedTexts;
  final String? iban;
  final String? issuedDate;

  Data({
    this.holdersName,
    this.luhnCheck,
    this.cardNumber,
    this.expiryDate,
    this.extractedTexts,
    this.iban,
    this.issuedDate,
  });

  static Data fromJson(Map<String, dynamic> json) {
    return Data(
      holdersName: json['HoldersName']?.toString(),
      luhnCheck: json['LuhnCheck']?.toString(),
      cardNumber: json['CardNumber']?.toString(),
      expiryDate: json['ExpiryDate']?.toString(),
      extractedTexts: json['ExtractedTexts']?.toString(),
      iban: json['IBAN']?.toString(),
      issuedDate: json['IssuedDate']?.toString(),
    );
  }
}
class ImageData {
  final String? creditCardImage;

  ImageData({this.creditCardImage});

  static ImageData fromJson(Map<String, dynamic> json) {
    return ImageData(
      creditCardImage: json['CreditCardImage']?.toString(),
    );
  }
}
