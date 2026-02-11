import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> saveOverlayImage(File image) async {
  final dir = await getApplicationDocumentsDirectory();
  final newPath = '${dir.path}/overlay.png';
  return image.copy(newPath).then((f) => f.path);
}

Future<File?> loadOverlayImage(String path) async {
  final file = File(path);
  return file.existsSync() ? file : null;
}
