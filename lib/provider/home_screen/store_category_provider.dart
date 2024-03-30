import 'package:flutter_riverpod/flutter_riverpod.dart';

enum StoreCategory { all, korean, chinese, japanese, western, snack, cafe, etc }

extension StoreCategoryExtension on StoreCategory {
  String toKoKr() {
    switch (this) {
      case StoreCategory.all:
        return '전체';
      case StoreCategory.korean:
        return '한식';
      case StoreCategory.chinese:
        return '중식';
      case StoreCategory.japanese:
        return '일식';
      case StoreCategory.western:
        return '양식';
      case StoreCategory.snack:
        return '분식';
      case StoreCategory.cafe:
        return '카페';
      case StoreCategory.etc:
        return '기타';
      default:
        return '기타';
    }
  }
}

// 홈 화면의 카테고리를 관리하는 Provider
final selecteCategoryProvider =
    StateProvider<StoreCategory>((ref) => StoreCategory.all);
