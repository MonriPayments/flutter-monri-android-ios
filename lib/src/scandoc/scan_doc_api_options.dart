class ScanDocApiOptions {
  final String scanDocApiBaseUrl;
  final String scanDocUserKey;
  final String scanDocSubKey;
  final bool acceptTermsAndConditions;

  ScanDocApiOptions({
    required this.scanDocApiBaseUrl,
    required String userKey,
    required String subClient,
    required this.acceptTermsAndConditions,
  })  : scanDocUserKey = userKey,
        scanDocSubKey = subClient;

  Map<String, dynamic> toJSON() {
    return {
      'scanDocApiBaseUrl': scanDocApiBaseUrl,
      'scanDocUserKey': scanDocUserKey,
      'scanDocSubKey': scanDocSubKey,
      'acceptTermsAndConditions' : acceptTermsAndConditions,
    };
  }
}
