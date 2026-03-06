class ScanDocExtractionConfiguration {
  final ImageConfiguration imageConfiguration;
  final ExtractionConfigurationSettings extractionConfigurationSettings;

  const ScanDocExtractionConfiguration({
    required this.imageConfiguration,
    required this.extractionConfigurationSettings,
  });

  factory ScanDocExtractionConfiguration.fromJson(Map<String, dynamic> json) {
    return ScanDocExtractionConfiguration(
      imageConfiguration: ImageConfiguration.fromJson(
        json['imageConfiguration'] as Map<String, dynamic>,
      ),
      extractionConfigurationSettings:
      ExtractionConfigurationSettings.fromJson(
        json['extractionConfigurationSettings'] as Map<String, dynamic>,
      )
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageConfiguration': imageConfiguration.toJson(),
      'extractionConfigurationSettings':
      extractionConfigurationSettings.toJson()
    };
  }
}

class ExtractionConfigurationSettings {
  final bool shouldReturnDocumentImage;
  final bool skipDocumentSizeCheck;
  final bool skipImageSizeCheck;
  final bool canStoreImages;
  final bool dontUseValidation;

  const ExtractionConfigurationSettings({
    required this.shouldReturnDocumentImage,
    required this.skipDocumentSizeCheck,
    required this.skipImageSizeCheck,
    required this.canStoreImages,
    required this.dontUseValidation,
  });

  factory ExtractionConfigurationSettings.fromJson(Map<String, dynamic> json) {
    return ExtractionConfigurationSettings(
      shouldReturnDocumentImage: json['shouldReturnDocumentImage'] as bool,
      skipDocumentSizeCheck: json['skipDocumentSizeCheck'] as bool,
      skipImageSizeCheck: json['skipImageSizeCheck'] as bool,
      canStoreImages: json['canStoreImages'] as bool,
      dontUseValidation: json['dontUseValidation'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shouldReturnDocumentImage': shouldReturnDocumentImage,
      'skipDocumentSizeCheck': skipDocumentSizeCheck,
      'skipImageSizeCheck': skipImageSizeCheck,
      'canStoreImages': canStoreImages,
      'dontUseValidation': dontUseValidation,
    };
  }
}

class ImageConfiguration {
  final String imageType;
  final bool imageCropped;

  const ImageConfiguration({
    required this.imageCropped,
  }) : imageType = ImageTypes.base64;

  factory ImageConfiguration.fromJson(Map<String, dynamic> json) {
    return ImageConfiguration(
      imageCropped: json['imageCropped'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageType': imageType,
      'imageCropped': imageCropped,
    };
  }
}

class ImageTypes {
  static const String base64 = 'BASE_64';
}

