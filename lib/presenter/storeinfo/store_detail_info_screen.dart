// import 'package:flutter/material.dart';
// import 'package:orre/model/store_info_model.dart';
// import 'package:live_activities/live_activities.dart';
// import 'package:orre/presenter/storeinfo/store_detail_info_screen_test.dart';

// class StoreDetailInfoScreen extends StatelessWidget {
//   final StoreDetailInfo storeDetailInfo;

//   const StoreDetailInfoScreen({Key? key, required this.storeDetailInfo})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final _liveActivitiesPlugin = LiveActivities();
//     _liveActivitiesPlugin.init(appGroupId: "group.orre.liveactivities");
//     return Scaffold(
//       appBar: AppBar(
//         title: TextWidget('Store Detail Info'),
//         actions: [
//           IconButton(
//               icon: Icon(Icons.edit_note_rounded),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => StoreDetailInfoTestScreen(
//                       storeDetailInfo: storeDetailInfo,
//                     ),
//                   ),
//                 );
//               }),
//           IconButton(
//               icon: Icon(Icons.exit_to_app),
//               onPressed: () {
//                 final Map<String, dynamic> activityModel = {
//                   'name': 'Margherita',
//                   'ingredient': 'tomato, mozzarella, basil',
//                   'quantity': 1,
//                 };

//                 _liveActivitiesPlugin.createActivity(activityModel);
//               }),
//           IconButton(
//               icon: Icon(Icons.expand_circle_down),
//               onPressed: () {
//                 _liveActivitiesPlugin.endAllActivities();
//               }),
//         ],
//       ),
//       body: ListView(
//         children: [
//           ListTile(
//             title: TextWidget('Name'),
//             subtitle: TextWidget(storeDetailInfo.storeName),
//           ),
//           ListTile(
//             title: TextWidget('Category'),
//             subtitle: TextWidget(storeDetailInfo.storeCategory),
//           ),
//           ListTile(
//             title: TextWidget('Introduce'),
//             subtitle: TextWidget(storeDetailInfo.storeIntroduce),
//           ),
//           ListTile(
//             title: TextWidget('Number of Teams Waiting'),
//             subtitle: TextWidget(storeDetailInfo.numberOfTeamsWaiting.toString()),
//           ),
//           ListTile(
//             title: TextWidget('Estimated Waiting Time'),
//             subtitle: TextWidget(storeDetailInfo.estimatedWaitingTime.toString()),
//           ),
//           ListTile(
//             title: TextWidget('Opening Time'),
//             subtitle: TextWidget(storeDetailInfo.openingTime.toString()),
//           ),
//           ListTile(
//             title: TextWidget('Closing Time'),
//             subtitle: TextWidget(storeDetailInfo.closingTime.toString()),
//           ),
//           ListTile(
//             title: TextWidget('Last Order Time'),
//             subtitle: TextWidget(storeDetailInfo.lastOrderTime.toString()),
//           ),
//           ListTile(
//             title: TextWidget('Break Start Time'),
//             subtitle: TextWidget(storeDetailInfo.breakStartTime.toString()),
//           ),
//           ListTile(
//             title: TextWidget('Break End Time'),
//             subtitle: TextWidget(storeDetailInfo.breakEndTime.toString()),
//           ),
//           ListTile(
//             title: TextWidget('Phone Number'),
//             subtitle: TextWidget(storeDetailInfo.storePhoneNumber),
//           ),
//           ListTile(
//             title: TextWidget('Location Info'),
//             subtitle: TextWidget(storeDetailInfo.locationInfo.toString()),
//           ),
//           ListTile(
//             title: TextWidget('Menu Info'),
//             subtitle: TextWidget(storeDetailInfo.menuInfo.toString()),
//           ),
//         ],
//       ),
//     );
//   }
// }
