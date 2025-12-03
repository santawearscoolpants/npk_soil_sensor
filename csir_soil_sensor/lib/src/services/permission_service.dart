import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Central place to request/check permissions needed by the app.
class PermissionService {
  Future<bool> ensureStoragePermission() async {
    // On iOS we only write into app sandbox via path_provider, which does not
    // require an extra storage permission. Let the OS handle Photos/Camera
    // when image_picker is used.
    if (Platform.isIOS) {
      return true;
    }

    final status = await Permission.storage.status;
    if (status.isGranted) return true;

    final result = await Permission.storage.request();
    return result.isGranted;
  }
}

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});


