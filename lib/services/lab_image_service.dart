import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class LabImageService {
  static final _picker = ImagePicker();

  static Future<String?> pickAndProcess({
    required ImageSource source,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 100, // keep max quality first
    );

    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return null;

    final targetRatio = 1 / 1.414;

    int newWidth = original.width;
    int newHeight = (newWidth / targetRatio).toInt();

    if (newHeight > original.height) {
      newHeight = original.height;
      newWidth = (newHeight * targetRatio).toInt();
    }

    final x = (original.width - newWidth) ~/ 2;
    final y = (original.height - newHeight) ~/ 2;

    final cropped = img.copyCrop(
      original,
      x: x,
      y: y,
      width: newWidth,
      height: newHeight,
    );

    final resized = img.copyResize(
      cropped,
      width: 1200,
      height: (1200 / targetRatio).toInt(),
      interpolation: img.Interpolation.linear,
    );

    final enhanced = img.adjustColor(
      resized,
      contrast: 1.1,
      saturation: 1.0,
    );

    final compressed = img.encodeJpg(enhanced, quality: 85);

    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'lab_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(compressed);

    return file.path;
  }
}