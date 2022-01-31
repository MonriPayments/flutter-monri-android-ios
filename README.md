# MonriPayments

A new flutter plugin project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Proguard part
-keep public class com.monri.** {
public protected private *;
}

-keep public enum com.monri.** {
*;
}
---
in android/proguard-rules.pro

useful commands:
flutter pub run build_runner build
flutter pub run build_runner watch --delete-conflicting-outputs