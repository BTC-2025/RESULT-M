class ShareLinks {
  static const String _baseUrl = String.fromEnvironment(
    'APP_SHARE_BASE_URL',
    defaultValue: 'https://resulthub.app',
  );

  static String post(String postId) {
    final base = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    return '$base/post/details/${Uri.encodeComponent(postId)}';
  }
}
