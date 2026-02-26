import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

enum StoragePermissionState {
  granted,
  denied,
  permanentlyDenied,
}

enum BlePermissionState {
  granted,
  denied,
  permanentlyDenied,
}

/// Central place to request/check permissions needed by the app.
class PermissionService {
  Future<StoragePermissionState> ensureStoragePermission() async {
    // On iOS we only write into app sandbox via path_provider, which does not
    // require an extra storage permission. Let the OS handle Photos/Camera
    // when image_picker is used.
    if (Platform.isIOS) {
      return StoragePermissionState.granted;
    }

    if (!Platform.isAndroid) {
      // Other platforms (web, desktop) currently don't require special handling.
      return StoragePermissionState.granted;
    }

    // Lightweight SDK detection without extra dependencies.
    final osVersion = Platform.operatingSystemVersion; // e.g. "Android 14 (UP1A...)"
    final match = RegExp(r'Android\s+(\d+)').firstMatch(osVersion);
    final sdkInt = match != null ? int.tryParse(match.group(1)!) : null;

    final statuses = <Permission, PermissionStatus>{};

    if (sdkInt != null && sdkInt >= 33) {
      // Android 13+: use dedicated media permissions.
      // This app exports/reads images (crop photos), so request photos/media.
      final photosStatus = await Permission.photos.request();
      statuses[Permission.photos] = photosStatus;
    } else {
      // Android 12 and below:
      // READ_EXTERNAL_STORAGE / WRITE_EXTERNAL_STORAGE are represented by storage.
      final storageStatus = await Permission.storage.request();
      statuses[Permission.storage] = storageStatus;
    }

    final anyPermanentlyDenied =
        statuses.values.any((s) => s.isPermanentlyDenied);
    if (anyPermanentlyDenied) {
      return StoragePermissionState.permanentlyDenied;
    }

    final allGranted = statuses.values.every((s) => s.isGranted);
    return allGranted
        ? StoragePermissionState.granted
        : StoragePermissionState.denied;
  }

  /// Requests permissions needed to scan/connect over BLE.
  ///
  /// - Android 12+: BLUETOOTH_SCAN + BLUETOOTH_CONNECT (runtime)
  /// - Android <= 11: location permission is required for BLE scans
  /// - iOS: handled by OS prompts; no explicit permission needed here
  Future<BlePermissionState> ensureBluetoothPermissions() async {
    if (Platform.isIOS) {
      return BlePermissionState.granted;
    }

    // Android
    final statuses = <Permission, PermissionStatus>{};

    // Android 12+ uses these runtime permissions.
    final scanStatus = await Permission.bluetoothScan.request();
    final connectStatus = await Permission.bluetoothConnect.request();
    statuses[Permission.bluetoothScan] = scanStatus;
    statuses[Permission.bluetoothConnect] = connectStatus;

    // Android <= 11 requires location permission for BLE scans.
    // Avoid requesting location on Android 12+ if scan/connect are already granted.
    final looksLikeAndroid12Plus = scanStatus.isGranted || connectStatus.isGranted;
    if (!looksLikeAndroid12Plus) {
      statuses[Permission.location] = await Permission.location.request();
    }

    final anyPermanentlyDenied =
        statuses.values.any((s) => s.isPermanentlyDenied);
    if (anyPermanentlyDenied) {
      return BlePermissionState.permanentlyDenied;
    }

    final allGranted = statuses.values.every((s) => s.isGranted);
    return allGranted ? BlePermissionState.granted : BlePermissionState.denied;
  }
}

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});


