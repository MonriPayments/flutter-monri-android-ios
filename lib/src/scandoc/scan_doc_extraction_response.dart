class ScanDocExtractionResponse {
  final String? transactionID;
  final String? uploadedAt;
  final String? productName;
  final List<String>? errors;
  final List<String>? warnings;
  final int? status;
  final String? method;
  final String? infoCode;
  final double? analysisTime;
  final String? os;
  final String? browser;
  final String? device;
  final CardData? data;
  final ImageData? imageData;

  const ScanDocExtractionResponse({
    this.transactionID,
    this.uploadedAt,
    this.productName,
    this.errors,
    this.warnings,
    this.status,
    this.method,
    this.infoCode,
    this.analysisTime,
    this.os,
    this.browser,
    this.device,
    this.data,
    this.imageData,
  });

  /// Swift-style initializer that can fail
  static ScanDocExtractionResponse? fromJson(Map<String, dynamic> body) {
    try {
      final transactionID = body['TransactionID'] as String?;
      final uploadedAt = body['UploadedAt'] as String?;
      final productName = body['ProductName'] as String?;
      final errors = (body['Errors'] as List?)?.cast<String>();
      final warnings = (body['Warnings'] as List?)?.cast<String>();
      final status = body['Status'] as int?;
      final method = body['Method'] as String?;
      final infoCode = body['InfoCode'] as String?;
      final analysisTime = (body['AnalysisTime'] as num?)?.toDouble();

      final dataMap = body['Data'] as Map<String, dynamic>?;
      final imageDataMap = body['ImageData'] as Map<String, dynamic>?;

      if (transactionID == null ||
          uploadedAt == null ||
          productName == null ||
          errors == null ||
          warnings == null ||
          status == null ||
          method == null ||
          infoCode == null ||
          analysisTime == null ||
          dataMap == null ||
          imageDataMap == null) {
        return null;
      }

      final data = CardData.fromJson(dataMap);
      final imageData = ImageData.fromJson(imageDataMap);

      if (data == null || imageData == null) return null;

      return ScanDocExtractionResponse(
        transactionID: transactionID,
        uploadedAt: uploadedAt,
        productName: productName,
        errors: errors,
        warnings: warnings,
        status: status,
        method: method,
        infoCode: infoCode,
        analysisTime: analysisTime,
        os: body['OS'] as String?,
        browser: body['Browser'] as String?,
        device: body['Device'] as String?,
        data: data,
        imageData: imageData,
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'TransactionID': transactionID,
      'UploadedAt': uploadedAt,
      'ProductName': productName,
      'Errors': errors,
      'Warnings': warnings,
      'Status': status,
      'Method': method,
      'InfoCode': infoCode,
      'AnalysisTime': analysisTime,
      'OS': os,
      'Browser': browser,
      'Device': device,
      'Data': data?.toJson(),
      'ImageData': imageData?.toJson(),
    };
  }
}

class CardData {
  final String? holdersName;
  final String? luhnCheck;
  final String? cardNumber;
  final String? expiryDate;
  final String? extractedTexts;
  final String? iban;
  final String? issuedDate;

  const CardData({
    this.holdersName,
    this.luhnCheck,
    this.cardNumber,
    this.expiryDate,
    this.extractedTexts,
    this.iban,
    this.issuedDate,
  });

  static CardData? fromJson(Map<String, dynamic> body) {

    return CardData(
      holdersName: body['HoldersName'],
      luhnCheck: body['LuhnCheck'],
      cardNumber: body['CardNumber'],
      expiryDate: body['ExpiryDate'],
      extractedTexts: body['ExtractedTexts'],
      iban: body['IBAN'],
      issuedDate: body['IssuedDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'HoldersName': holdersName,
      'LuhnCheck': luhnCheck,
      'CardNumber': cardNumber,
      'ExpiryDate': expiryDate,
      'ExtractedTexts': extractedTexts,
      'IBAN': iban,
      'IssuedDate': issuedDate,
    };
  }
}

class ImageData {
  final String creditCardImage;

  const ImageData({
    required this.creditCardImage,
  });

  static ImageData? fromJson(Map<String, dynamic> body) {
    final image = body['CreditCardImage'];
    if (image is String) {
      return ImageData(creditCardImage: image);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'CreditCardImage': creditCardImage,
    };
  }
}
