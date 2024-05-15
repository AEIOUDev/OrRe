import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/widget/text/text_widget.dart';
import '../../provider/location/location_securestorage_provider.dart'; // 필요에 따라 경로 수정
import '../../provider/location/now_location_provider.dart';
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
        title: TextWidget('삭제하시겠습니까?'),
        content: TextWidget('선택한 위치를 삭제합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: TextWidget('확인'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: TextWidget('취소'),
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
    final userLocations = ref.watch(locationListProvider);
    final selectedLocation = userLocations.selectedLocation;

    return Scaffold(
      appBar: AppBar(
        title: TextWidget(selectedLocation?.locationName ?? '위치 목록'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AddLocationScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: userLocations.customLocations.length,
        itemBuilder: (context, index) {
          final location = userLocations.customLocations[index];
          return ListTile(
            title: TextWidget(location.locationName),
            subtitle: TextWidget(location.address),
            onTap: () {
              ref.read(locationListProvider.notifier).selectLocation(location);
              Navigator.of(context).pop();
            },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteLocation(location.locationName, ref),
            ),
          );
        },
      ),
    );
  }
}

class NewLocationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    return AlertDialog(
      title: TextWidget('새 위치 추가'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: '위치 이름 입력',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: TextWidget('추가'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: TextWidget('취소'),
        ),
      ],
    );
  }
}
