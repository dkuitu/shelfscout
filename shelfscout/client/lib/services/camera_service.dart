import 'package:image_picker/image_picker.dart';

class CameraService {
  final _picker = ImagePicker();

  Future<String?> capturePhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );
    return image?.path;
  }

  Future<String?> pickFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );
    return image?.path;
  }
}
