class SchoolMeal {
  final String restaurantLocation;
  final String date;
  final String breakfast;
  final String lunch;
  final String dinner;

  SchoolMeal({
    required this.restaurantLocation,
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  factory SchoolMeal.fromJson(Map<String, dynamic> json) {
    return SchoolMeal(
      restaurantLocation: json['restaurantLocation'] ?? "식당 정보 없음",
      date: json['date'] ?? "날짜 정보 없음",
      breakfast: addNewLine(json['breakfast'] ?? "[조식] :\n제공 정보 없음\n"),
      lunch: addNewLine(json['lunch'] ?? "[중식] :\n제공 정보 없음\n"),
      dinner: addNewLine(json['dinner'] ?? "[석식] :\n제공 정보 없음\n"),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurantLocation': restaurantLocation,
      'date': date,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
    };
  }

  // 글자 줄바꿈 함수
  static String addNewLine(String text) {
    String temp = "";
    if (text.contains('[')) {
      temp = text.replaceAll('[', '\n[');
    } else {
      temp = text;
    }

    if (temp.contains('0,')) {
      temp = temp.replaceAll('0,', '0\n');
    }

    if (temp.contains("**")) {
      temp = temp.replaceAll('** ', '\n** ');
    }

    if (temp.contains('**,')) {
      temp = temp.replaceAll('**,', '**\n');
    }

    return temp;
  }
}
