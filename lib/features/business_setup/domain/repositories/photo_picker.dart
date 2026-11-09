/// Where a photo can come from.
enum PhotoSource { camera, gallery }

/// Lets the user take or choose a photo. Kept behind an interface so the
/// setup BLoC can be tested without the camera plugin.
abstract interface class PhotoPicker {
  /// Returns the local file path, or null when the user cancels.
  Future<String?> pick(PhotoSource source);
}
