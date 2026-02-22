import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final securityServiceProvider = Provider<SecurityService>(
  (ref) => SecurityService(),
);

class SecurityService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        // No biometrics available, allow access
        return true;
      }

      return await auth.authenticate(
        localizedReason:
            'Please authenticate to access your Digital Saving Box',
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}
