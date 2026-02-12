// screens/camera_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';
import 'preview_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeFuture;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCameraFlow();
  }

  Future<void> _initCameraFlow() async {
    final status = await Permission.camera.request();

    if (!status.isGranted) {
      setState(() {
        _error = "Camera permission denied";
      });
      return;
    }

    try {
      if (cameras.isEmpty) {
        setState(() {
          _error = "No cameras available on this device";
        });
        return;
      }

      final camera = cameras.first;
      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      _initializeFuture = _controller!.initialize();
      await _initializeFuture;

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      setState(() {
        _error = "Failed to initialize camera: $e";
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Camera")),
        body: Center(child: Text(_error!)),
      );
    }

    if (_controller == null || _initializeFuture == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Take a Photo")),
      body: FutureBuilder<void>(
        future: _initializeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _controller!.value.isInitialized) {
            return CameraPreview(_controller!);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeFuture;
            final image = await _controller!.takePicture();

            if (!mounted) return;

            final bytes = await File(image.path).readAsBytes();
            final base64Image = base64Encode(bytes);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PreviewScreen(imageBase64: base64Image),
              ),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to take picture: $e")),
            );
          }
        },
      ),
    );
  }
}
