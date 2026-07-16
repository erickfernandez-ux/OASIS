import 'dart:io' as io;

bool isMobilePrivacyPlatform() {
  return io.Platform.isAndroid || io.Platform.isIOS;
}