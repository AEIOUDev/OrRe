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
            onPressed: () => context.pop(true),
            child: TextWidget('확인'),
          ),
          TextButton(
            onPressed: () => context.pop(false),
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
    final location = ref.watch(locationListProvider);
    final customLocations = location.customLocations;
    final selectedLocation = location.selectedLocation;

    final isSame = selectedLocation?.locationName == "현재 위치";

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
                    context.pop();
                  },
                  icon: Icon(Icons.my_location,
                      color: isSame ? Color(0xFFFFFFBF52) : Color(0xFF999999)),
                  label: TextWidget(
                    isSame ? "현재 위치로 설정됨" : '현재 위치로 설정',
                    fontSize: 20,
                    color: isSame ? Color(0xFFFFFFBF52) : Color(0xFF999999),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                ),
                // IconButton(
                //     icon: Icon(Icons.table_rows_rounded,
                //         color:
                //             isSame ? Color(0xFFFFFFBF52) : Color(0xFF999999)),
                //     onPressed: () {
                //       printd(
                //           "선택된 위치 : ${ref.read(locationListProvider.notifier).getSelectedLocation()}");
                //       printd(
                //           "현재 위치 : ${ref.read(locationListProvider.notifier).getNowLocation()}");
                //       printd(
                //           "사용자 위치 : ${ref.read(locationListProvider.notifier).getCustomLocations()}");
                //     }),
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
                itemCount: customLocations.length,
                itemBuilder: (context, index) {
                  final location = customLocations[index];
                  final isSelected =
                      location.address == selectedLocation?.address;
                  return ListTile(
                    leading: Icon(Icons.location_on,
                        color: isSelected ? Color(0xFFFFFFBF52) : Colors.black),
                    title: TextWidget(
                        location.address + " (${location.locationName})",
                        color: isSelected ? Color(0xFFFFFFBF52) : Colors.black,
                        textAlign: TextAlign.left),
                    onTap: () {
                      ref
                          .read(locationListProvider.notifier)
                          .selectLocation(location);
                      context.pop();
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
