import 'package:http/http.dart' as http;

class HttpsService {
  static final String _defaultUrl = 'https://orre.store/api/user';

  static Uri getUri(String url) {
    return Uri.parse(_defaultUrl + url);
  }

  static Future<http.Response> postRequest(String url, String jsonBody) async {
    print('jsonBody: $jsonBody');
    print('post url: ${getUri(url)}');
    final response = await http.post(
      getUri(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonBody,
    );
    print('response: ${response.body}');
    return response;
  }

  static Future<http.Response> getRequest(String url) async {
    print('get url: ${getUri(url)}');
    final response = await http.get(
      getUri(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    return response;
  }
}
