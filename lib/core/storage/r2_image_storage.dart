import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sokosafi/core/constants/storage_constants.dart';
import 'package:sokosafi/core/storage/image_storage.dart';
import 'package:sokosafi/core/storage/image_upload_failure.dart';

/// Uploads photos to the Cloudflare R2 bucket through the upload Worker in
/// `cloudflare/image-upload`. The app never holds R2 keys; it proves who the
/// user is with their Firebase ID token and the Worker saves the photo under
/// that user's folder.
class R2ImageStorage implements ImageStorage {
  R2ImageStorage({
    required this._uploadEndpoint,
    required this._idToken,
    http.Client? client,
    Future<Uint8List> Function(String path)? readBytes,
  }) : _client = client ?? http.Client(),
       _readBytes = readBytes ?? ((path) => File(path).readAsBytes());

  factory R2ImageStorage.firebase() => R2ImageStorage(
    uploadEndpoint: StorageConstants.uploadEndpoint,
    idToken: () async => FirebaseAuth.instance.currentUser?.getIdToken(),
  );

  static const maxBytes = 5 * 1024 * 1024;
  static const _timeout = Duration(seconds: 30);
  static const _attempts = 2;
  static const _retryDelay = Duration(seconds: 1);

  final Uri _uploadEndpoint;
  final Future<String?> Function() _idToken;
  final http.Client _client;
  final Future<Uint8List> Function(String path) _readBytes;

  @override
  bool get isAvailable => true;

  @override
  Future<String> upload({
    required String localPath,
    required String folder,
  }) async {
    try {
      final bytes = await _readBytes(localPath);
      if (bytes.length > maxBytes) {
        throw const ImageUploadFailure(
          'This photo is too large. Please choose one under 5 MB',
        );
      }
      // Judged from the file's first bytes: the picker sometimes keeps a
      // .webp name on a photo it re-saved as JPG.
      final contentType = contentTypeOf(bytes);
      if (contentType == null) {
        throw const ImageUploadFailure(
          'Please choose a JPG, PNG or WebP photo',
        );
      }
      final token = await _idToken();
      if (token == null) {
        throw const ImageUploadFailure('Please sign in again to add photos');
      }

      final response = await _postWithRetry(
        uri: _uploadEndpoint.replace(queryParameters: {'folder': folder}),
        headers: {
          'authorization': 'Bearer $token',
          'content-type': contentType,
        },
        bytes: bytes,
      );
      if (response.statusCode != 201) {
        throw ImageUploadFailure(
          response.statusCode == 401
              ? 'Please sign in again to add photos'
              : ImageUploadFailure.genericMessage,
        );
      }
      final url = (jsonDecode(response.body) as Map<String, dynamic>)['url'];
      if (url is! String || !url.startsWith('https://')) {
        throw const ImageUploadFailure(ImageUploadFailure.genericMessage);
      }
      return url;
    } on ImageUploadFailure {
      rethrow;
    } on SocketException {
      throw const ImageUploadFailure(ImageUploadFailure.connectionMessage);
    } on TimeoutException {
      throw const ImageUploadFailure(ImageUploadFailure.connectionMessage);
    } on http.ClientException {
      throw const ImageUploadFailure(ImageUploadFailure.connectionMessage);
    } catch (_) {
      throw const ImageUploadFailure(ImageUploadFailure.genericMessage);
    }
  }

  /// Phones often drop the connection for a moment when switching between
  /// Wi-Fi and mobile data, so a network error or a server error is tried
  /// once more before telling the user. Each upload gets a new file name, so
  /// a retry can never overwrite anything.
  Future<http.Response> _postWithRetry({
    required Uri uri,
    required Map<String, String> headers,
    required Uint8List bytes,
  }) async {
    for (var attempt = 1; ; attempt++) {
      final isLastAttempt = attempt == _attempts;
      try {
        final response = await _client
            .post(uri, headers: headers, body: bytes)
            .timeout(_timeout);
        if (response.statusCode < 500 || isLastAttempt) return response;
      } on Exception catch (error) {
        final isConnectionError =
            error is SocketException ||
            error is TimeoutException ||
            error is http.ClientException;
        if (!isConnectionError || isLastAttempt) rethrow;
      }
      await Future<void>.delayed(_retryDelay);
    }
  }

  /// The upload Worker only accepts these three types.
  @visibleForTesting
  static String? contentTypeOf(Uint8List bytes) {
    bool startsWith(List<int> signature, [int offset = 0]) {
      if (bytes.length < offset + signature.length) return false;
      for (var i = 0; i < signature.length; i++) {
        if (bytes[offset + i] != signature[i]) return false;
      }
      return true;
    }

    if (startsWith([0xff, 0xd8, 0xff])) return 'image/jpeg';
    if (startsWith([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])) {
      return 'image/png';
    }
    // "RIFF", four size bytes, then "WEBP".
    if (startsWith([0x52, 0x49, 0x46, 0x46]) &&
        startsWith([0x57, 0x45, 0x42, 0x50], 8)) {
      return 'image/webp';
    }
    return null;
  }
}
