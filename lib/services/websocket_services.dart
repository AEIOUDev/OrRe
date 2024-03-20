class WebSocketService {
  static final String _defaultUrl = 'ws://172.30.1.32:8080/ws';
  static String _url = _defaultUrl;

  static String get url => _url;

  static void setUrl(String url) {
    _url = url;
  }
}
