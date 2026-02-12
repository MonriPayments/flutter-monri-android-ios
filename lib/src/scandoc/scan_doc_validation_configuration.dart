class ScanDocValidationConfiguration {
  List<double> blurValues;
  final ValidationConfigurationSettings validationSettings;

  ScanDocValidationConfiguration({
    required this.blurValues,
    required this.validationSettings,
  });

  void setBlurValues(List<double> blurValues) {
    this.blurValues = blurValues;
  }

  Map<String, dynamic> toJson() {
    return {
      'blurValues': blurValues,
      'validationSettings': {
        'skipImageSizeCheck':
        validationSettings.skipImageSizeCheck,
      },
    };
  }
}

class ValidationConfigurationSettings {
  final bool skipImageSizeCheck;

  ValidationConfigurationSettings({
    required this.skipImageSizeCheck,
  });
}


