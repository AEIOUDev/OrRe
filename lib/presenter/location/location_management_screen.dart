import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orre/widget/text/text_widget.dart';
import '../../provider/location/location_securestorage_provider.dart';
import '../../services/debug.services.dart'; // 필요에 따라 경로 수정

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
    printd("\n\nLocationManagementScreen 진입");
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
                  width: MediaQuery.sizeOf(context).width,
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      context.push('/location/addLocation');
                    },
                    icon: Icon(
                      Icons.map_rounded,
                      color: Color(0xFF999999),
                    ),
                    label: TextWidget(
                      ' 지도로 위치를 설정해보세요.',
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
                    ref
                        .read(locationListProvider.notifier)
                        .selectLocationToNowLocation();
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
                  final isSelected =
                      location.locationName == selectedLocation?.locationName;
                  return ListTile(
                    leading: Icon(Icons.location_on,
                        color: isSelected ? Color(0xFFFFFFBF52) : Colors.black),
                    title: TextWidget(location.address,
                        color: isSelected ? Color(0xFFFFFFBF52) : Colors.black,
                        textAlign: TextAlign.left),
                    onTap: () {
                      ref
                          .read(locationListProvider.notifier)
                          .selectLocation(location);
                      Navigator.of(context).pop();
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.delete,
                          color:
                              isSelected ? Color(0xFFFFFFBF52) : Colors.black),
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
}
