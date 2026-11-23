import 'package:flutter/services.dart';
import 'package:sokosafi/features/discovery/domain/repositories/phone_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the dialler with the number filled in through a tel: link.
class UrlPhoneLauncher implements PhoneLauncher {
  const UrlPhoneLauncher();

  static Uri callUri(String phone) =>
      Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[^0-9+]'), ''));

  @override
  Future<bool> call(String phone) async {
    try {
      return await launchUrl(callUri(phone));
    } on PlatformException {
      return false;
    }
  }
}
