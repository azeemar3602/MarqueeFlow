import 'package:url_launcher/url_launcher.dart';

Future<void> launchPhoneCall(String phone) async {
  final uri = Uri.parse('tel:$phone');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

Future<void> launchWhatsApp(String phone, {String? message}) async {
  var digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('0')) digits = '92${digits.substring(1)}';
  final uri = message != null
      ? Uri.parse('https://wa.me/$digits?text=${Uri.encodeComponent(message)}')
      : Uri.parse('https://wa.me/$digits');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
