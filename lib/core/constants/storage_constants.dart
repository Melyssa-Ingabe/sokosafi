/// Where photos are uploaded. The Worker lives in `cloudflare/image-upload`.
abstract final class StorageConstants {
  static final uploadEndpoint = Uri.parse(
    'https://upload.sokosafi-images.workers.dev/upload',
  );
}
