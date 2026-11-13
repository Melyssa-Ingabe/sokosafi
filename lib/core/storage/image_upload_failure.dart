/// A photo could not be uploaded. [message] is safe to show in a SnackBar.
class ImageUploadFailure implements Exception {
  const ImageUploadFailure(this.message);

  static const genericMessage =
      'We could not upload the photo. Please try again';
  static const connectionMessage =
      'We could not upload the photo. Check your connection and try again';

  final String message;

  @override
  String toString() => 'ImageUploadFailure: $message';
}
