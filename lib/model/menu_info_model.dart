import 'package:flutter/widgets.dart';

class MenuInfo {
  final String menuCode;
  final String menuName;
  final String? menuDescription;
  final double menuPrice;
  final Image? menuImage;
  final bool isRecommended;

  MenuInfo(
      {required this.menuCode,
      required this.menuName,
      required this.menuDescription,
      required this.menuPrice,
      required this.menuImage,
      required this.isRecommended});

  Map<String, dynamic> toJson() => {
        'menuCode': menuCode,
        'menuName': menuName,
        'menuDescription': menuDescription,
        'menuPrice': menuPrice,
        'menuImage': menuImage,
        'isRecommended': isRecommended,
      };

  factory MenuInfo.fromJson(Map<String, dynamic> json) => MenuInfo(
        menuCode: json['menuCode'],
        menuName: json['menuName'],
        menuDescription: json['menuDescription'],
        menuPrice: json['menuPrice'],
        menuImage: json['menuImage'],
        isRecommended: json['isRecommended'],
      );
}

class OrderedMenuList {
  final MenuInfo menuInfo;
  final double numberOfMenus;

  OrderedMenuList({required this.menuInfo, required this.numberOfMenus});
}
