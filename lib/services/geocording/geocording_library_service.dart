import 'package:geocoding/geocoding.dart';

// 위도와 경도로부터 주소를 문자열로 반환하는 비동기 함수입니다.
Future<String?> getAddressFromLatLngLibrary(
    double latitude, double longitude, int detail, bool includeArea1) async {
  try {
    // 주어진 위도와 경도로 Placemark 객체의 리스트를 비동기적으로 조회합니다.
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);

    // 조회된 Placemark 리스트가 비어있지 않은 경우 처리를 계속합니다.
    if (placemarks.isNotEmpty) {
      // 리스트의 첫 번째 Placemark 객체를 사용합니다.
      Placemark place = placemarks[0];
      // 주소 구성요소를 담을 리스트를 초기화합니다.
      List<String> addressParts = [];

      // Debugging purposes
      print(place);

      // 행정구역 정보를 추가하는 조건입니다. includeArea1이 true이고, administrativeArea가 비어있지 않을 때 추가합니다.
      if (includeArea1 &&
          place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty) {
        addressParts.add(place.administrativeArea!.trim());
      }

      // 지역명을 추가하는 조건입니다. detail이 2 이상이고, locality가 administrativeArea와 다르며 비어있지 않을 때 추가합니다.
      if (detail >= 2 &&
          place.locality != null &&
          place.locality != place.administrativeArea &&
          place.locality!.isNotEmpty) {
        addressParts.add(place.locality!.trim());
      }

      // 하위 지역명을 추가하는 조건입니다. detail이 3 이상이고, subLocality가 locality와 다르며 비어있지 않을 때 추가합니다.
      if (detail >= 3 &&
          place.subLocality != null &&
          place.subLocality != place.locality &&
          place.subLocality!.isNotEmpty) {
        addressParts.add(place.subLocality!.trim());
      }

      // 거리명을 추가하는 조건입니다. detail이 4 이상이고, street가 비어있지 않을 때 추가합니다.
      // subLocality와 시작 부분이 일치하는 경우, 그 부분을 제거합니다.
      if (detail >= 4 && place.street != null && place.street!.isNotEmpty) {
        String street = place.street!.trim();
        if (place.subLocality != null &&
            street.startsWith(place.subLocality!)) {
          street = street.replaceFirst(place.subLocality! + ' ', '').trim();
        }
        addressParts.add(street);
      }

      // 주소 구성요소를 공백으로 연결하고, 앞뒤 공백을 제거하여 최종 주소 문자열을 생성합니다.
      String address = addressParts.join(' ').trim();

      // 최종 주소 문자열을 반환합니다.
      return address;
    } else {
      // 조회된 Placemark 리스트가 비어 있는 경우, null을 반환합니다.
      return null;
    }
  } catch (e) {
    // 오류 발생 시, 콘솔에 오류 메시지를 출력하고 null을 반환합니다.
    print('Error fetching address: $e');
    return null;
  }
}
