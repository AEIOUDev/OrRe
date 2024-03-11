import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/location_model.dart';
import '../../provider/location/location_securestorage_provider.dart'; // 필요에 따라 경로 수정
import '../../provider/location/location_info_provider.dart';
import 'add_location_screen.dart'; // 필요에 따라 경로 수정

class LocationManagementScreen extends ConsumerStatefulWidget {
  @override
  _LocationManagementScreenState createState() =>
      _LocationManagementScreenState();
}

class _LocationManagementScreenState
    extends ConsumerState<LocationManagementScreen> {
  // 개별 위치 삭제 함수
  void _deleteLocation(String locationName, WidgetRef ref) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('삭제하시겠습니까?'),
        content: Text('선택한 위치를 삭제합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('확인'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('취소'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      // 선택한 위치 삭제
      ref.read(locationListProvider.notifier).removeLocation(locationName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myLocationAsyncValue = ref.watch(locationProvider);
    final customLocations = ref.watch(locationListProvider);
    final selectedLocation = customLocations.selectedLocation;

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedLocation?.locationName ?? '위치 목록'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              // 위치 추가 로직
              // final newLocationName = await showDialog<String>(
              //   context: context,
              //   builder: (context) => NewLocationDialog(),
              // );
              // if (newLocationName != null && newLocationName.isNotEmpty) {
              //   ref.read(locationListProvider.notifier).addLocation(
              //         LocationInfo(
              //           locationName: newLocationName,
              //           latitude: 0.0, // 새 위치의 위도
              //           longitude: 0.0, // 새 위치의 경도
              //           address: "새 위치의 주소", // 새 위치의 주소
              //         ),
              //       );
              // }
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AddLocationScreen()),
              );
            },
          ),
        ],
      ),
      body: myLocationAsyncValue.when(
        data: (myLocation) => ListView.builder(
          itemCount: customLocations.customLocations.length,
          itemBuilder: (context, index) {
            final location = customLocations.customLocations[index];
            return ListTile(
              title: Text(location.locationName),
              subtitle: Text('${location.address}'),
              onTap: () {
                ref
                    .read(locationListProvider.notifier)
                    .selectLocation(location);
                Navigator.pop(context);
              },
              trailing: location.locationName != 'nowLocation'
                  ? IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () =>
                          _deleteLocation(location.locationName, ref),
                    )
                  : null, // "nowLocation" 항목에는 삭제 버튼이 없음
            );
          },
        ),
        loading: () => CircularProgressIndicator(),
        error: (error, stack) => Text('오류 발생: $error'),
      ),
    );
  }
}

class NewLocationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    return AlertDialog(
      title: Text('새 위치 추가'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: '위치 이름 입력',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text('추가'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('취소'),
        ),
      ],
    );
  }
}
