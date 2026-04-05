import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  static final _picker = ImagePicker();

  static Future<String?> pickAndProcess({
    required ImageSource source,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85, // first-pass compression
    );

    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return null;

    final side = original.width < original.height
        ? original.width
        : original.height;
    final x = (original.width - side) ~/ 2;
    final y = (original.height - side) ~/ 2;
    final cropped = img.copyCrop(
      original,
      x: x,
      y: y,
      width: side,
      height: side,
    );

    final resized = img.copyResize(
      cropped,
      width: 512,
      height: 512,
      interpolation: img.Interpolation.linear,
    );

    final compressed = img.encodeJpg(resized, quality: 78);
    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'food_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(compressed);

    return file.path;
  }
}