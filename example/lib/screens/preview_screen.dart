import 'dart:convert';

import 'package:MonriPayments/MonriPayments.dart';
import 'package:MonriPayments/src/scandoc/scan_doc_extraction_configuration.dart';
import 'package:MonriPayments/src/scandoc/scan_doc_validation_configuration.dart';
import 'package:MonriPayments/src/scandoc/scan_doc_api_options.dart';
import 'package:flutter/material.dart' hide ImageConfiguration;

import 'extract_results.dart';

class PreviewScreen extends StatelessWidget {
  final String imageBase64;
  MonriPayments monriPayments = MonriPayments.create();

  PreviewScreen({super.key, required this.imageBase64});

  @override
  Widget build(BuildContext context) {

    monriPayments.initScanDoc(ScanDocApiOptions(scanDocApiBaseUrl: 'REPLACE', userKey: 'REPLACE', subClient: 'REPLACE', acceptTermsAndConditions: true));

    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: Column(
        children: [
          Expanded(
            child: Image.memory(base64Decode(imageBase64),
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retake"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.analytics),
                  label: const Text("Extract"),
                  onPressed: () {
                    extractData(context);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  
  Future<void> extractData(BuildContext context) async {
    try {
      //validateData(context);

      final extractionConfig = ScanDocExtractionConfiguration(imageConfiguration: ImageConfiguration(imageCropped: false),
          extractionConfigurationSettings: ExtractionConfigurationSettings(shouldReturnDocumentImage: true,
              skipDocumentSizeCheck: true,
              skipImageSizeCheck: true,
              canStoreImages: false,
              dontUseValidation: true));

      final response = await monriPayments.extractScannedCard(imageBase64, null);

      if (response != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExtractResultScreen(response: response),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Extraction failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Extraction failed" + e.toString())),
      );
    }
  }

  Future<void> validateData(BuildContext context) async {

    try {

      final validationConfig = ScanDocValidationConfiguration(blurValues: [],
          validationSettings: ValidationConfigurationSettings(skipImageSizeCheck: true));

      final response = await monriPayments.validateScannedCard([imageBase64], validationConfig);

      if (response != null) {
        print("Is validated: " + response.validated.toString());
      } else {
        print("Empty validation response");
      }
    } catch (e) {
      print("Validation failed" + e.toString());
    }

  }
}
