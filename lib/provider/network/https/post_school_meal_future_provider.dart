import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/services/network/https_services.dart';
import 'package:orre/model/school_meal_model.dart';

Future<SchoolMeal> fetchSchoolMeal(String location, String date) async {
  try {
    final body = {
      'restaurantLocation': location,
      'date': date,
    };
    final jsonBody = json.encode(body);
    final response = await HttpsService.postUniRequest(
        dotenv.get('ORRE_HTTPS_ENDPOINT_DANKOOKSCHOOLMEAL'), jsonBody);
    if (response.statusCode == 200) {
      final jsonBody = json.decode(utf8.decode(response.bodyBytes));
      print("schoolMealHttpsProvider(json 200): $jsonBody");
      final result = SchoolMeal.fromJson(jsonBody);

      return result;
    } else {
      throw Exception('Failed to fetch school meal');
    }
  } catch (error) {
    print("schoolMealHttpsProvider(error): $error");
    throw Exception('Failed to fetch school meal');
  }
}

final schoolMealFutureProvider = FutureProvider.autoDispose
    .family<SchoolMeal, String>((ref, location) async {
  // MM월DD일
  final date =
      DateTime.now().toString().substring(5, 10).replaceAll('-', '월') + '일';
  return fetchSchoolMeal(location, date);
});
