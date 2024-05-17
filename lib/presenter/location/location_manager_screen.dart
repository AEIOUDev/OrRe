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
      backgroundColor: Color(0xFFDFDFDF),
      appBar: AppBar(
        title: TextWidget('주소 설정'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => AddLocationScreen()),
                      );
                    },
                    icon: Icon(
                      Icons.search,
                      color: Color(0xFF999999),
                    ),
                    label: TextWidget(
                      ' 주소로 위치를 검색해보세요.',
                      color: Color(0xFF999999),
                      fontSize: 20,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFEEEEEE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _refreshCurrentLocation(context, ref);
                  },
                  icon: Icon(Icons.my_location, color: Color(0xFF999999)),
                  label: TextWidget(
                    '현재 위치로 설정',
                    fontSize: 20,
                    color: Color(0xFF999999),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // TODO : 이거 선택된 친구만 주황색으로 만들어줘. 임시로 송파구쨩만 주황색 되게 만들었어...^^
      body: Column(
        children: [
          SizedBox(height: 16),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: userLocations.customLocations.length,
                itemBuilder: (context, index) {
                  final location = userLocations.customLocations[index];
                  return ListTile(
                    leading: Icon(Icons.location_on,
                        color: location.locationName == "송파구"
                            ? Color(0xFFFFFFBF52)
                            : Colors.black),
                    title: TextWidget(location.address,
                        color: location.locationName == "송파구"
                            ? Color(0xFFFFFFBF52)
                            : Colors.black),
                    onTap: () {
                      ref
                          .read(locationListProvider.notifier)
                          .selectLocation(location);
                      Navigator.of(context).pop();
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.delete,
                          color: location.locationName == "송파구"
                              ? Color(0xFFFFFFBF52)
                              : Colors.black),
                      onPressed: () =>
                          _deleteLocation(location.locationName, ref),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  // 현재 위치를 새로고침하는 메소드
  void _refreshCurrentLocation(BuildContext context, WidgetRef ref) async {
    print("_refreshCurrentLocation");
    try {
      // nowLocationProvider를 refresh하고 결과를 기다립니다.
      ref
          .refresh(nowLocationProvider.notifier)
          .updateNowLocation()
          .then((value) {
        // 결과를 출력합니다.
        print("updateNowLocation value : $value");
        // 성공적으로 위치 정보를 받았으면, 이를 LocationListProvider에 업데이트합니다.
        if (value != null) {
          ref.read(locationListProvider.notifier).updateNowLocation(value);
        } else {
          // 에러 처리...
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: TextWidget('현재 위치를 불러오는데 실패했습니다.')),
          );
        }
      });
    } catch (error) {
      // 에러 처리...
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: TextWidget('현재 위치를 불러오는데 실패했습니다.')),
      );
    }
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
