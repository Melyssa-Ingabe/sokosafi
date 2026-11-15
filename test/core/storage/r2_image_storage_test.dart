import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sokosafi/core/storage/image_upload_failure.dart';
import 'package:sokosafi/core/storage/r2_image_storage.dart';

void main() {
  final endpoint = Uri.parse('https://worker.test/upload');
  final photoBytes = Uint8List.fromList([0xff, 0xd8, 0xff, 0xe0]);

  R2ImageStorage storageWith(
    MockClient client, {
    String? token = 'id-token',
    Uint8List? bytes,
  }) {
    return R2ImageStorage(
      uploadEndpoint: endpoint,
      idToken: () async => token,
      client: client,
      readBytes: (_) async => bytes ?? photoBytes,
    );
  }

  Matcher failureWith(String message) => throwsA(
    isA<ImageUploadFailure>().having((f) => f.message, 'message', message),
  );

  test('sends the photo with the token and returns the url', () async {
    late http.Request sent;
    final client = MockClient((request) async {
      sent = request;
      return http.Response(
        jsonEncode({'url': 'https://pub.r2.dev/uploads/u1/listings/a.jpg'}),
        201,
      );
    });

    final url = await storageWith(client)
        .upload(localPath: '/tmp/photo.JPG', folder: 'listings/biz1');

    expect(url, 'https://pub.r2.dev/uploads/u1/listings/a.jpg');
    expect(sent.method, 'POST');
    expect(sent.url.queryParameters['folder'], 'listings/biz1');
    expect(sent.headers['authorization'], 'Bearer id-token');
    expect(sent.headers['content-type'], startsWith('image/jpeg'));
    expect(sent.bodyBytes, photoBytes);
  });

  test('sends the real type when the file name is wrong', () async {
    late http.Request sent;
    final client = MockClient((request) async {
      sent = request;
      return http.Response(
        jsonEncode({'url': 'https://pub.r2.dev/a.jpg'}),
        201,
      );
    });

    await storageWith(client)
        .upload(localPath: '/tmp/scaled_24.webp', folder: 'listings');

    expect(sent.headers['content-type'], startsWith('image/jpeg'));
  });

  test('refuses files that are not photos without uploading', () async {
    var called = false;
    final client = MockClient((_) async {
      called = true;
      return http.Response('', 201);
    });

    await expectLater(
      storageWith(
        client,
        bytes: Uint8List.fromList(utf8.encode('<html></html>')),
      ).upload(localPath: '/tmp/photo.jpg', folder: 'x'),
      failureWith('Please choose a JPG, PNG or WebP photo'),
    );
    expect(called, isFalse);
  });

  test('refuses photos over 5 MB', () async {
    final client = MockClient((_) async => http.Response('', 201));
    await expectLater(
      storageWith(
        client,
        bytes: Uint8List(R2ImageStorage.maxBytes + 1),
      ).upload(localPath: '/tmp/big.png', folder: 'listings'),
      failureWith('This photo is too large. Please choose one under 5 MB'),
    );
  });

  test('asks to sign in again when there is no user or a 401', () async {
    final client = MockClient((_) async => http.Response('', 401));
    await expectLater(
      storageWith(
        client,
        token: null,
      ).upload(localPath: '/tmp/a.png', folder: 'listings'),
      failureWith('Please sign in again to add photos'),
    );
    await expectLater(
      storageWith(client).upload(localPath: '/tmp/a.png', folder: 'listings'),
      failureWith('Please sign in again to add photos'),
    );
  });

  test('shows a polite message for server and network errors', () async {
    final serverError = MockClient((_) async => http.Response('boom', 500));
    await expectLater(
      storageWith(serverError)
          .upload(localPath: '/tmp/a.webp', folder: 'listings'),
      failureWith(ImageUploadFailure.genericMessage),
    );

    final offline = MockClient(
      (_) async => throw const SocketException('no internet'),
    );
    await expectLater(
      storageWith(offline).upload(localPath: '/tmp/a.webp', folder: 'listings'),
      failureWith(ImageUploadFailure.connectionMessage),
    );
  });

  test('retries once when the connection drops', () async {
    var attempts = 0;
    final flaky = MockClient((_) async {
      attempts++;
      if (attempts == 1) throw const SocketException('wifi to mobile data');
      return http.Response(
        jsonEncode({'url': 'https://pub.r2.dev/a.jpg'}),
        201,
      );
    });

    final url = await storageWith(flaky)
        .upload(localPath: '/tmp/a.jpg', folder: 'listings');

    expect(url, 'https://pub.r2.dev/a.jpg');
    expect(attempts, 2);
  });

  test('does not retry when the user is not signed in', () async {
    var attempts = 0;
    final client = MockClient((_) async {
      attempts++;
      return http.Response('', 401);
    });

    await expectLater(
      storageWith(client).upload(localPath: '/tmp/a.jpg', folder: 'listings'),
      failureWith('Please sign in again to add photos'),
    );
    expect(attempts, 1);
  });

  test('rejects a response without an https url', () async {
    final client = MockClient(
      (_) async => http.Response(jsonEncode({'url': 'http://x'}), 201),
    );
    await expectLater(
      storageWith(client).upload(localPath: '/tmp/a.jpeg', folder: 'listings'),
      failureWith(ImageUploadFailure.genericMessage),
    );
  });
}
