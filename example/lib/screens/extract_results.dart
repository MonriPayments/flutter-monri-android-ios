import 'dart:convert';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:MonriPayments/src/scandoc/scan_doc_extraction_response.dart';

class ExtractResultScreen extends StatelessWidget {
  final ScanDocExtractionResponse response;

  const ExtractResultScreen({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    // Fake extracted data for now
    final extractedData = {
      "Card Number": response.data?.cardNumber ?? "",
      "Name": response.data?.holdersName ?? "",
      "Expiry": response.data?.expiryDate ?? "",
    };

    final image = response.imageData?.creditCardImage ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text('Extracted Card Data')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.memory(base64Decode(image), height: 200),
            const SizedBox(height: 16),
            const Text("Detected Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...extractedData.entries.map(
                  (e) => ListTile(
                title: Text(e.key),
                subtitle: Text(e.value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Uint8List bytesFromBase64(String base64String) {
    return base64Decode(base64String);
  }

  Image imageFromBase64(String base64String) {
    final bytes = base64Decode(base64String);
    return Image.memory(bytes);
  }

}
