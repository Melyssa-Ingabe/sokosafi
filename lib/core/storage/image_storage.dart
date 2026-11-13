/// Uploads photos and returns their public URL. Used by business setup and
/// listings. The app uses R2ImageStorage; [UnavailableImageStorage] stays for
/// tests that do not upload.
abstract interface class ImageStorage {
  /// False while no image host is configured, so features can save without
  /// a photo instead of failing.
  bool get isAvailable;

  /// Uploads the file at [localPath] into [folder] and returns its URL.
  Future<String> upload({required String localPath, required String folder});
}

/// Saves without photos, for tests and when no image host is configured.
class UnavailableImageStorage implements ImageStorage {
  const UnavailableImageStorage();

  @override
  bool get isAvailable => false;

  @override
  Future<String> upload({required String localPath, required String folder}) {
    throw UnsupportedError('Image upload is not configured yet');
  }
}
