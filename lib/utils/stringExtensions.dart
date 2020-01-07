extension StringExtensions on String {
  /// Check if a string URL ends with .svg
  bool isSvgUrl() {
    if (isEmpty) return false;
    final parts = split('.');
    return parts.isNotEmpty && parts.last.toLowerCase() == 'svg';
  }

  /// Check if a string is a valid URL
  bool isValidUrl() {
    if (isEmpty) return false;
    final uri = Uri.tryParse(this);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }
}
