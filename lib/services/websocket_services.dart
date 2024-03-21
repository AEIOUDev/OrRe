class WebSocketService {
  static final String _defaultUrl = 'ws://192.168.1.214:8080/ws';
  // static final String _defaultUrl = 'ws://172.31.114.211:8080/ws';
  static String _url = _defaultUrl;

  static String get url => _url;

  static void setUrl(String url) {
    _url = url;
  }
}
