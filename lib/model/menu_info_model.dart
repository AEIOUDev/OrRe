import 'package:flutter/widgets.dart';

class MenuInfo {
  final String name;
  final String description;
  final int price;
  final String image;
  final bool isRecommended;

  MenuInfo({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.isRecommended,
  });

  factory MenuInfo.fromJson(Map<String, dynamic> json) {
    return MenuInfo(
      name: json['name'],
      description: json['description'],
      price: json['price'],
      // Image.asset("test") 는 정적 방식으로 사용하므로, JSON에서 이미지 경로를 받아 Image 객체를 생성하는 방식으로 변경해야 합니다.
      // 예: json['img']의 값을 기반으로 Image 객체 생성. 실제 경로는 JSON 데이터에 따라 다를 수 있습니다.
      image: json['img'],
      isRecommended: json['isRecommended'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'image': image,
        'isRecommended': isRecommended,
      };
}

class OrderedMenuList {}
