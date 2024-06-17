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
      restaurantLocation: json['restaurantLocation'],
      date: json['date'],
      breakfast: addNewLine(json['breakfast']),
      lunch: addNewLine(json['lunch']),
      dinner: addNewLine(json['dinner']),
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
