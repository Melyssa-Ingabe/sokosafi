import 'package:image_picker/image_picker.dart';
import 'package:sokosafi/core/storage/photo_picker.dart';

class DevicePhotoPicker implements PhotoPicker {
  DevicePhotoPicker({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  @override
  Future<String?> pick(PhotoSource source) async {
    // Resized and compressed on the phone so uploads stay small on mobile
    // data.
    final file = await _imagePicker.pickImage(
      source: source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 75,
    );
    return file?.path;
  }
}
