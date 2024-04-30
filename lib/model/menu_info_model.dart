class MenuInfo {
  final String menu;
  final String introduce;
  final int price;
  final String image;
  final int recommend;

  MenuInfo({
    required this.menu,
    required this.introduce,
    required this.price,
    required this.image,
    required this.recommend,
  });

  factory MenuInfo.fromJson(Map<String, dynamic> json) {
    return MenuInfo(
      menu: json['menu'],
      introduce: json['introduce'],
      price: json['price'],
      // Image.asset("test") 는 정적 방식으로 사용하므로, JSON에서 이미지 경로를 받아 Image 객체를 생성하는 방식으로 변경해야 합니다.
      // 예: json['img']의 값을 기반으로 Image 객체 생성. 실제 경로는 JSON 데이터에 따라 다를 수 있습니다.
      image: json['img'],
      recommend: json['recommend'],
    );
  }

  Map<String, dynamic> toJson() => {
        'menu': menu,
        'introduce': introduce,
        'price': price,
        'image': image,
        'recommend': recommend,
      };
}

class OrderedMenuList {}
