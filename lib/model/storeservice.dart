class StoreService {
  // 가상의 상점 데이터를 저장하는 Map
  final Map<String, Map<String, dynamic>> _stores = {
    '001': {
      'storeName': '카페 라떼',
      'storeWaitingInfo': 5,
    },
    '002': {
      'storeName': '피자 파라다이스',
      'storeWaitingInfo': 2,
    },
    '003': {
      'storeName': '스시 천국',
      'storeWaitingInfo': 8,
    },
  };

  // storeCode를 사용하여 상점 정보를 가져오는 메서드
  Map<String, dynamic>? getStoreInfo(String storeCode) {
    return _stores[storeCode];
  }
}
