bool isValidPkPhone(String phone) {
  final normalized = phone.replaceAll(RegExp(r'\s'), '');
  return RegExp(r'^(\+92|0)?3[0-9]{9}$').hasMatch(normalized);
}

String normalizePkPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('92') && digits.length == 12) return '+$digits';
  if (digits.startsWith('0') && digits.length == 11) return '+92${digits.substring(1)}';
  if (digits.length == 10 && digits.startsWith('3')) return '+92$digits';
  return phone.trim();
}
