class MenuInfo {
  final String menu;
  final String introduce;
  final int price;
  final String image;
  final int recommend;
  final String menuCode;
  final int available;

  MenuInfo({
    required this.menu,
    required this.introduce,
    required this.price,
    required this.image,
    required this.recommend,
    required this.menuCode,
    required this.available,
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
      menuCode: json['menuCode'],
      available: json['available'],
    );
  }

  Map<String, dynamic> toJson() => {
        'menu': menu,
        'introduce': introduce,
        'price': price,
        'image': image,
        'recommend': recommend,
        'menuCode': menuCode,
        'available': available,
      };

  static List<MenuInfo> getMenuByCategory(
      List<MenuInfo> menuList, String category) {
    return menuList.where((menu) {
      // 메뉴 코드의 첫 글자를 추출 (알파벳 a~z)
      final menuCategory = menu.menuCode[0];

      // 메뉴 코드의 첫 글자(알파벳)와 카테고리(알파벳으로 된 변수명)가 일치하는지 확인
      return menuCategory == category;
    }).toList();
  }
}

class MenuCategories {
  final int storeCode;
  final String? recommend;
  final Map<String, String?> categories;

  MenuCategories({
    required this.storeCode,
    this.recommend,
    required this.categories,
  });

  factory MenuCategories.fromJson(Map<String, dynamic> json) {
    try {
      return MenuCategories(
        storeCode: json['storeCode'] ?? -1,
        categories: {
          'A': json['a'] ?? null,
          'B': json['b'] ?? null,
          'C': json['c'] ?? null,
          'D': json['d'] ?? null,
          'E': json['e'] ?? null,
          'F': json['f'] ?? null,
          'G': json['g'] ?? null,
          'H': json['h'] ?? null,
          'I': json['i'] ?? null,
          'J': json['j'] ?? null,
          'K': json['k'] ?? null,
          'L': json['l'] ?? null,
          'M': json['m'] ?? null,
          'N': json['n'] ?? null,
          'O': json['o'] ?? null,
          'P': json['p'] ?? null,
          'Q': json['q'] ?? null,
          'R': json['r'] ?? null,
          'S': json['s'] ?? null,
          'T': json['t'] ?? null,
          'U': json['u'] ?? null,
          'V': json['v'] ?? null,
          'W': json['w'] ?? null,
          'X': json['x'] ?? null,
          'Y': json['y'] ?? null,
          'Z': json['z'] ?? null,
        },
      );
    } catch (e) {
      print(e);
      return MenuCategories.nullValue();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'storeCode': storeCode,
      'A': categories['A'],
      'B': categories['B'],
      'C': categories['C'],
      'D': categories['D'],
      'E': categories['E'],
      'F': categories['F'],
      'G': categories['G'],
      'H': categories['H'],
      'I': categories['I'],
      'J': categories['J'],
      'K': categories['K'],
      'L': categories['L'],
      'M': categories['M'],
      'N': categories['N'],
      'O': categories['O'],
      'P': categories['P'],
      'Q': categories['Q'],
      'R': categories['R'],
      'S': categories['S'],
      'T': categories['T'],
      'U': categories['U'],
      'V': categories['V'],
      'W': categories['W'],
      'X': categories['X'],
      'Y': categories['Y'],
      'Z': categories['Z'],
    };
  }

  static MenuCategories nullValue() {
    return MenuCategories(
      storeCode: -1,
      categories: {
        'A': null,
        'B': null,
        'C': null,
        'D': null,
        'E': null,
        'F': null,
        'G': null,
        'H': null,
        'I': null,
        'J': null,
        'K': null,
        'L': null,
        'M': null,
        'N': null,
        'O': null,
        'P': null,
        'Q': null,
        'R': null,
        'S': null,
        'T': null,
        'U': null,
        'V': null,
        'W': null,
        'X': null,
        'Y': null,
        'Z': null,
      },
    );
  }

  List<String> getCategories() {
    List<String> categories = [];
    categories.add('추천 메뉴');
    categories.addAll(this
        .categories
        .values
        .where((element) => element != null)
        .cast<String>());
    return categories;
  }
}

class OrderedMenuList {
  final Map<String, String> menuCategories;
  final List<MenuInfo> orderedMenus;

  OrderedMenuList({
    required this.menuCategories,
    required this.orderedMenus,
  });
}
