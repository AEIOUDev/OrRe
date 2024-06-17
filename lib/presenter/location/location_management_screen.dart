import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orre/model/location_model.dart';
import 'package:orre/provider/location/now_location_provider.dart';
import 'package:orre/services/hardware/haptic_services.dart';
import 'package:orre/widget/popup/awesome_dialog_widget.dart';
import 'package:orre/widget/text/text_widget.dart';
import '../../provider/location/location_securestorage_provider.dart';
import '../../services/debug_services.dart'; // 필요에 따라 경로 수정
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LocationManagementScreen extends ConsumerStatefulWidget {
  @override
  _LocationManagementScreenState createState() =>
      _LocationManagementScreenState();
}

class _LocationManagementScreenState
    extends ConsumerState<LocationManagementScreen> {
  // 개별 위치 삭제 함수
  void _deleteLocation(String locationName, WidgetRef ref) async {
    AwesomeDialogWidget.showCustomDialogWithCancel(
      context: context,
      title: "위치 삭제",
      desc: "선택한 위치를 삭제하시겠습니까?",
      dialogType: DialogType.question,
      onPressed: () {
        ref.read(locationListProvider.notifier).removeLocation(locationName);
      },
      btnText: "삭제",
      onCancel: () {},
      cancelText: "취소",
    );
  }

  @override
  Widget build(BuildContext context) {
    printd("\n\nLocationManagementScreen 진입");
    final location = ref.watch(locationListProvider);
    final customLocations = location.customLocations;
    final selectedLocation = location.selectedLocation;
    final nowLocation = location.nowLocation;

    return Scaffold(
      // backgroundColor: Color(0xFFDFDFDF),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFBF52),
        title: TextWidget('주소 설정'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(58.h),
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await HapticServices.vibrate(
                          ref, CustomHapticsType.selection);
                      context.push('/location/addLocation');
                    },
                    icon: Icon(
                      Icons.map_rounded,
                      color: Color(0xFF999999),
                    ),
                    label: TextWidget(
                      ' 지도로 위치를 추가해보세요!',
                      color: Color(0xFF999999),
                      fontSize: 18.sp,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFFFFFFBF52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
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
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: customLocations.length + 1,
                itemBuilder: (context, index) {
                  LocationInfo location;
                  bool isSelected;
                  if (index == 0) {
                    location = nowLocation ?? LocationInfo.nullValue();
                    isSelected = selectedLocation?.address == location.address;
                  } else {
                    location = customLocations[index - 1];
                    isSelected = location.address == selectedLocation?.address;
                  }
                  if (index == 0) {
                    return nowLocationItem(isSelected, location, ref);
                  } else {
                    return locationItem(isSelected, location, ref);
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget nowLocationItem(
      bool isSelected, LocationInfo location, WidgetRef ref) {
    return ListTile(
      leading: Icon(Icons.my_location,
          color: isSelected ? Color(0xFFFFFFBF52) : Colors.black, size: 20.sp),
      title: TextWidget(location.locationName + (isSelected ? " (선택됨)" : ""),
          fontSize: 16.sp,
          color: isSelected ? Color(0xFFFFFFBF52) : Colors.black,
          textAlign: TextAlign.left),
      subtitle: TextWidget(
        location.address,
        fontSize: 12.sp,
        color: isSelected ? Color(0xFFFFFFBF52) : Colors.grey,
        textAlign: TextAlign.left,
      ),
      onTap: () async {
        await ref.read(nowLocationProvider.notifier).updateNowLocation();
        await ref
            .read(locationListProvider.notifier)
            .selectLocationToNowLocation();
        context.pop();
      },
    );
  }

  Widget locationItem(bool isSelected, LocationInfo location, WidgetRef ref) {
    return ListTile(
      leading: Icon(Icons.location_on,
          color: isSelected ? Color(0xFFFFFFBF52) : Colors.black, size: 20.sp),
      title: TextWidget(location.locationName + (isSelected ? " (선택됨)" : ""),
          fontSize: 16.sp,
          color: isSelected ? Color(0xFFFFFFBF52) : Colors.black,
          textAlign: TextAlign.left),
      subtitle: TextWidget(
        location.address,
        fontSize: 12.sp,
        color: isSelected ? Color(0xFFFFFFBF52) : Colors.grey,
        textAlign: TextAlign.left,
      ),
      onTap: () {
        ref.read(locationListProvider.notifier).selectLocation(location);
        context.pop();
      },
      trailing: IconButton(
        icon: Icon(Icons.delete,
            color: isSelected ? Color(0xFFFFFFBF52) : Colors.black),
        onPressed: () => _deleteLocation(location.locationName, ref),
        iconSize: 20.sp,
      ),
    );
  }
}
