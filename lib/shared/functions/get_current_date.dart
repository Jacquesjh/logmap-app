String getCurrentDate() {
  final now = DateTime.now();
  final formattedDate =
      '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}';
  return formattedDate;
}

String _twoDigits(int n) {
  if (n >= 10) return '$n';
  return '0$n';
}
