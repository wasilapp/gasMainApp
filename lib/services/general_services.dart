import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

callNumber(phone) async {
  try {
    Uri email = Uri(
      scheme: 'tel',
      path: phone,
    );

    await launchUrl(email);
  } catch (e) {
    debugPrint(e.toString());
  }
}


openUrl(cVUrl) async {
  final url = Uri.parse(cVUrl);
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    // <--
    throw Exception('Could not launch $url');
  }
}
