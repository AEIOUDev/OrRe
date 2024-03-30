class WebSocketService {
  static final String _defaultUrl = 'wss://orre.store/ws';

  static String _url = _defaultUrl;

  static String get url => _url;

  static void setUrl(String url) {
    _url = url;
  }
}
