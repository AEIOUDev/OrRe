import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebSocketService {
  static final String _defaultUrl = dotenv.get('ORRE_WEBSOCKET_URL');

  static String _url = _defaultUrl;

  static String get url => _url;

  static void setUrl(String url) {
    _url = url;
  }
}
