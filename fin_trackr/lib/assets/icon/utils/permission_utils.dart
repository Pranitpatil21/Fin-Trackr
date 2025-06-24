// lib/utils/permission_utils.dart
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission() async {
  var status = await Permission.storage.status;

  if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
    status = await Permission.storage.request();
  }

  return status.isGranted;
}
