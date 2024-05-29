// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:orre/provider/location/now_location_provider.dart';
// import 'package:orre/widget/popup/alert_popup_widget.dart';
// import 'package:orre/widget/text/text_widget.dart';
// import '../../provider/location/location_securestorage_provider.dart'; // 필요에 따라 경로 수정
// import 'add_location_screen.dart'; // 필요에 따라 경로 수정

// class LocationManagementScreen extends ConsumerStatefulWidget {
//   @override
//   _LocationManagementScreenState createState() =>
//       _LocationManagementScreenState();
// }

// class _LocationManagementScreenState
//     extends ConsumerState<LocationManagementScreen> {
//   // 개별 위치 삭제 함수
//   void _deleteLocation(String locationName, WidgetRef ref) async {
//     await showDialog(
//       context: context,
//       builder: (context) => AlertPopupWidget(
//         title: '삭제하시겠습니까?',
//         subtitle: '선택한 위치를 삭제합니다.',
//         buttonText: '삭제',
//         onPressed: () {
//           ref.read(locationListProvider.notifier).removeLocation(locationName);
//         },
//         cancelButton: true,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userLocations = ref.watch(locationListProvider);
//     final nowLocation = ref.watch(nowLocationProvider);
//     final selectedLocation = userLocations.selectedLocation;

//     return Scaffold(
//       appBar: AppBar(
//         title: TextWidget(selectedLocation?.locationName ?? '위치 목록'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () async {
//               Navigator.of(context).push(
//                 MaterialPageRoute(builder: (context) => AddLocationScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             if (nowLocation != null)
//               ListTile(
//                 titleAlignment: ListTileTitleAlignment.bottom,
//                 title: TextWidget('현재 위치'),
//                 subtitle: TextWidget(nowLocation.address),
//                 onTap: () {
//                   ref
//                       .read(locationListProvider.notifier)
//                       .selectLocation(nowLocation);
//                 },
//               ),
//             Divider(),
//             ListView.builder(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               itemCount: userLocations.customLocations.length,
//               itemBuilder: (context, index) {
//                 final location = userLocations.customLocations[index];
//                 return ListTile(
//                   title: TextWidget(location.locationName),
//                   subtitle: TextWidget(location.address),
//                   onTap: () {
//                     ref
//                         .read(locationListProvider.notifier)
//                         .selectLocation(location);
//                     Navigator.of(context).pop();
//                   },
//                   trailing: IconButton(
//                     icon: Icon(Icons.delete),
//                     onPressed: () =>
//                         _deleteLocation(location.locationName, ref),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
