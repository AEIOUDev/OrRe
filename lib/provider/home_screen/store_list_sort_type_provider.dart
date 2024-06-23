import 'package:flutter_riverpod/flutter_riverpod.dart';

enum StoreListSortType { basic, nearest, popular, fast, favorite }

extension StoreListSortTypeExtension on StoreListSortType {
  String toKoKr() {
    switch (this) {
      case StoreListSortType.basic:
        return '기본';
      case StoreListSortType.nearest:
        return '가까운 순';
      case StoreListSortType.popular:
        return '인기 순';
      case StoreListSortType.fast:
        return '빠른 순';
      case StoreListSortType.favorite:
        return '즐겨찾기 순';
      default:
        return '기본';
    }
  }

  String toEn() {
    switch (this) {
      case StoreListSortType.basic:
        return 'basicStores';
      case StoreListSortType.nearest:
        return 'nearestStores';
      case StoreListSortType.popular:
        return 'popularStores';
      case StoreListSortType.fast:
        return 'fastStores';
      case StoreListSortType.favorite:
        return 'favoriteStores';
      default:
        return 'basicStores';
    }
  }
}

final selectSortTypeProvider =
    StateProvider<StoreListSortType>((ref) => StoreListSortType.basic);
