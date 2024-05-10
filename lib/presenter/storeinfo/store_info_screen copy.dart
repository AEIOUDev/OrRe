// import 'package:animated_flip_counter/animated_flip_counter.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:orre/presenter/storeinfo/store_detail_info_screen.dart';
// import 'package:orre/provider/userinfo/user_info_state_notifier.dart';
// import 'package:orre/widget/text_field/text_input_widget.dart';

// import '../../model/store_info_model.dart';
// import '../../provider/store_detail_info_state_notifier.dart';
// import '../../provider/network/websocket/store_waiting_info_list_state_notifier.dart';
// import '../../provider/network/websocket/store_waiting_info_request_state_notifier.dart';
// import '../../provider/network/websocket/store_waiting_usercall_list_state_notifier.dart';
// import '../../provider/waiting_usercall_time_list_state_notifier.dart';

// class StoreDetailInfoWidget extends ConsumerStatefulWidget {
//   final int storeCode;

//   StoreDetailInfoWidget({Key? key, required this.storeCode}) : super(key: key);

//   @override
//   _StoreDetailInfoWidgetState createState() => _StoreDetailInfoWidgetState();
// }

// class _StoreDetailInfoWidgetState extends ConsumerState<StoreDetailInfoWidget> {
//   @override
//   void initState() {
//     super.initState();
//     print('storeCode: ${widget.storeCode}');
//     ref.read(storeDetailInfoProvider.notifier).fetchStoreDetailInfo(
//           StoreInfoParams(widget.storeCode, 0),
//         );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final storeDetailInfo = ref.watch(storeDetailInfoProvider);
//     final myWaitingInfo = ref.watch(storeWaitingRequestNotifierProvider.select(
//         (value) => value
//             .where((element) =>
//                 element.waitingDetails.storeCode == widget.storeCode)
//             .firstOrNull));

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.orange,
//         actions: [
//           IconButton(
//             onPressed: () async {
//               // Call the store
//               print('Call the store: ${storeDetailInfo.storePhoneNumber}');
//               await FlutterPhoneDirectCaller.callNumber(
//                   storeDetailInfo.storePhoneNumber);
//             },
//             icon: Icon(Icons.phone),
//           ),
//           IconButton(
//             icon: Icon(Icons.info),
//             onPressed: () {
//               // Navigate to the store detail info page
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       StoreDetailInfoScreen(storeDetailInfo: storeDetailInfo),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: storeDetailInfo.storeCode == 0
//           ? Center(child: CircularProgressIndicator()) // TODO: 추후 에러 페이지로 변경
//           : SingleChildScrollView(
//               padding: const EdgeInsets.only(bottom: 10.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   StoreBannerAppBar(storeDetailInfo),
//                   Divider(),
//                   WaitingStatusWidget(
//                       storeCode: widget.storeCode,
//                       myWaitingInfo: myWaitingInfo),
//                   Divider(),
//                   StoreMenuListWidget(storeDetailInfo: storeDetailInfo),
//                   Divider(),
//                 ],
//               ),
//             ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       floatingActionButton: storeDetailInfo != StoreDetailInfo.nullValue()
//           ? SizedBox(
//               child: BottomButtonSelecter(
//                 storeCode: widget.storeCode,
//                 waitingState: (myWaitingInfo != null),
//               ),
//               width: MediaQuery.of(context).size.width * 0.95,
//             )
//           : null,
//     );
//   }
// }

// class StoreBannerAppBar extends ConsumerWidget {
//   final StoreDetailInfo storeDetailInfo;

//   StoreBannerAppBar(this.storeDetailInfo);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Container(
//       alignment: Alignment.topCenter,
//       color: Colors.orange,
//       child: Column(
//         children: [
//           CachedNetworkImage(
//               imageUrl: storeDetailInfo.storeImageMain,
//               imageBuilder: (context, imageProvider) => Container(
//                     width: MediaQuery.of(context).size.height / 5,
//                     height: MediaQuery.of(context).size.height / 5,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       image: DecorationImage(
//                         image: imageProvider,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//               placeholder: (context, url) => CircularProgressIndicator(),
//               errorWidget: (context, url, error) => Icon(Icons.store)),
//           SizedBox(height: 8),
//           TextWidget(
//             storeDetailInfo.storeName,
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                   color: Colors.white,
//                 ),
//           ),
//           SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               TextWidget(
//                 storeDetailInfo.storeCategory,
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: Colors.white,
//                     ),
//               ),
//               TextWidget(" | ",
//                   style: Theme.of(context)
//                       .textTheme
//                       .bodyMedium
//                       ?.copyWith(color: Colors.white)),
//               TextWidget(
//                 storeDetailInfo.storeIntroduce,
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: Colors.white,
//                     ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//         ],
//       ),
//     );
//   }
// }

// class WaitingStatusWidget extends ConsumerWidget {
//   final int storeCode;
//   final StoreWaitingRequest? myWaitingInfo;

//   WaitingStatusWidget({required this.storeCode, this.myWaitingInfo});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final storeWaitingInfo = ref
//         .watch(storeWaitingInfoNotifierProvider.select((value) =>
//             value.where((element) => element.storeCode == storeCode)))
//         .first;
//     final myUserCall = ref
//         .watch(storeWaitingUserCallNotifierProvider.select((value) =>
//             value.where((element) => element.storeCode == storeCode)))
//         .firstOrNull;
//     final remaingTime = ref.watch(waitingUserCallTimeListProvider);

//     if (myWaitingInfo != null) {
//       final myWaitingNumber = myWaitingInfo!.waitingDetails.waiting;
//       final int myWaitingIndex = storeWaitingInfo.waitingTeamList
//           .indexWhere((team) => team == myWaitingNumber);
//       ref
//           .read(storeWaitingUserCallNotifierProvider.notifier)
//           .subscribeToUserCall(storeCode, myWaitingNumber);
//       if (myUserCall != null) {
//         final enteringTime = myUserCall.entryTime;
//         print("enteringTime" + {enteringTime}.toString());
//         print("nowTime" + {DateTime.now()}.toString());

//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextWidget('내 웨이팅 번호: ${myWaitingInfo?.waitingDetails.waiting}'),
//             TextWidget('남은 팀 수 :  ${myWaitingIndex.toString()}'),
//             TextWidget('남은 입장 시간: ${remaingTime.inSeconds}초'),
//           ],
//         );
//       } else {
//         if (myWaitingIndex == -1) {
//           return Container(
//             height: 50,
//             width: 50,
//             alignment: Alignment.center,
//             child: CircularProgressIndicator(
//               color: Colors.orange,
//             ),
//           );
//         } else {
//           return Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               TextWidget('내 웨이팅 번호: ${myWaitingInfo?.waitingDetails.waiting}'),
//               TextWidget('남은 팀 수 :  ${myWaitingIndex.toString()}'),
//               TextWidget(
//                   '예상 대기 시간: ${myWaitingIndex * storeWaitingInfo.estimatedWaitingTimePerTeam}분'),
//             ],
//           );
//         }
//       }
//     } else {
//       return Column(
//         children: [
//           TextWidget('대기중인 팀 수: ${storeWaitingInfo.waitingTeamList.length}'),
//           TextWidget(
//               '예상 대기 시간: ${storeWaitingInfo.waitingTeamList.length * storeWaitingInfo.estimatedWaitingTimePerTeam}분'),
//           Divider(),
//         ],
//       );
//     }
//   }
// }

// class StoreMenuListWidget extends ConsumerWidget {
//   final StoreDetailInfo storeDetailInfo;

//   StoreMenuListWidget({required this.storeDetailInfo});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     if (storeDetailInfo.menuInfo.length < 1) {
//       return Container(
//         alignment: Alignment.center,
//         margin: const EdgeInsets.only(top: 100.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Icon(Icons.menu_book, size: 50),
//             TextWidget('메뉴 정보가 없습니다.'),
//           ],
//         ),
//       );
//     } else {
//       return ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: storeDetailInfo.menuInfo.length,
//           itemBuilder: (context, index) {
//             final menu = storeDetailInfo.menuInfo[index];
//             return ListTile(
//               leading: CachedNetworkImage(
//                 imageUrl: menu.image,
//                 imageBuilder: (context, imageProvider) => Container(
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.rectangle,
//                     image: DecorationImage(
//                       image: imageProvider,
//                       fit: BoxFit.cover,
//                     ),
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                 ),
//                 placeholder: (context, url) => CircularProgressIndicator(),
//                 errorWidget: (context, url, error) => Icon(Icons.no_food),
//               ),
//               title: TextWidget(menu.menu),
//               subtitle: TextWidget('${menu.price}원 - ${menu.introduce}'),
//             );
//           },
//           separatorBuilder: (context, index) => Divider() // 구분선 추가,
//           );
//     }
//   }
// }

// class BottomButtonSelecter extends ConsumerWidget {
//   final int storeCode;
//   final bool waitingState;

//   BottomButtonSelecter({required this.storeCode, required this.waitingState});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final nowWaitable =
//         ref.watch(storeDetailInfoProvider.notifier).isCanReserve();

//     if (nowWaitable) {
//       return WaitingButton(storeCode: storeCode, waitingState: waitingState);
//     } else {
//       return FloatingActionButton.extended(
//           backgroundColor: Colors.grey,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(50),
//           ),
//           onPressed: () {
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: TextWidget("예약 불가"),
//                   content: TextWidget("현재 예약이 불가능한 시간입니다."),
//                   actions: [
//                     TextButton(
//                       child: TextWidget("확인"),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                   ],
//                 );
//               },
//             );
//           },
//           label: TextWidget('예약 불가'));
//     }
//   }
// }

// class WaitingButton extends ConsumerWidget {
//   final int storeCode;
//   final bool waitingState;

//   WaitingButton({required this.storeCode, required this.waitingState});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return FloatingActionButton.extended(
//         backgroundColor: Colors.orange,
//         foregroundColor: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(50),
//         ),
//         onPressed: () {
//           print("waitingState" + {waitingState}.toString());
//           showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return waitingState
//                   ? WaitingCancleDialog(
//                       storeCode: storeCode, waitingState: waitingState)
//                   : WaitingDialog(
//                       storeCode: storeCode,
//                       waitingState: waitingState,
//                     );
//             },
//           );
//         },
//         label: waitingState
//             ? Row(
//                 children: [
//                   Icon(Icons.person_remove_alt_1),
//                   SizedBox(width: 8),
//                   TextWidget('웨이팅 취소'),
//                 ],
//               )
//             : Row(
//                 children: [
//                   Icon(Icons.person_add),
//                   SizedBox(width: 8),
//                   TextWidget('웨이팅 시작'),
//                 ],
//               ));
//   }
// }

// final peopleNumberProvider = StateProvider<int>((ref) => 1);

// class WaitingDialog extends ConsumerWidget {
//   final int storeCode;
//   final bool waitingState;

//   WaitingDialog({required this.storeCode, required this.waitingState});

//   // 웨이팅 시작을 위한 정보 입력 다이얼로그 표시
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final phoneNumberController = TextEditingController();
//     final userInfo = ref.watch(userInfoProvider);
//     final numberOfPersonControlloer = ref.watch(peopleNumberProvider);

//     phoneNumberController.text = userInfo?.phoneNumber ?? "";

//     final formKey = GlobalKey<FormState>();

//     return AlertDialog(
//       title: TextWidget("웨이팅 시작"),
//       content: Form(
//         key: formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextInputWidget(
//               hintText: "전화번호",
//               controller: phoneNumberController,
//               isObscure: false,
//               type: TextInputType.phone,
//               autofillHints: [AutofillHints.telephoneNumber],
//               inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//               minLength: 11,
//               maxLength: 11,
//               ref: ref,
//             ),
//             SizedBox(height: 16),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 IconButton(
//                   icon: Icon(Icons.remove),
//                   onPressed: () {
//                     if (numberOfPersonControlloer > 1) {
//                       ref.read(peopleNumberProvider.notifier).state--;
//                     }
//                   },
//                 ),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.orange, width: 2),
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   child: AnimatedFlipCounter(
//                     value: numberOfPersonControlloer,
//                     suffix: "명",
//                     textStyle: TextStyle(
//                       fontSize: 40,
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.add),
//                   onPressed: () {
//                     ref.read(peopleNumberProvider.notifier).state++;
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           child: TextWidget("취소"),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         TextButton(
//           child: TextWidget("확인"),
//           onPressed: () {
//             if (formKey.currentState!.validate()) {
//               // 여기에서 입력된 정보를 처리합니다.
//               // 예를 들어, 웨이팅 요청을 서버에 보내는 로직을 구현할 수 있습니다.
//               print("전화번호: ${phoneNumberController.text}");
//               print("인원 수: ${numberOfPersonControlloer}");
//               print("가게 코드: $storeCode");
//               print("웨이팅 시작");
//               ref
//                   .read(storeWaitingRequestNotifierProvider.notifier)
//                   .subscribeToStoreWaitingRequest(
//                     storeCode,
//                     phoneNumberController.text,
//                     int.parse(numberOfPersonControlloer.toString()),
//                   );
//               Navigator.of(context).pop();
//             }
//           },
//         ),
//       ],
//     );
//   }
// }

// class WaitingCancleDialog extends ConsumerWidget {
//   final int storeCode;
//   final bool waitingState;

//   WaitingCancleDialog({required this.storeCode, required this.waitingState});

//   // 웨이팅 취소를 위한 정보 입력 다이얼로그 표시
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // 웨이팅 취소를 위한 정보 입력 다이얼로그 표시
//     final waitingInfo = ref.watch(storeWaitingRequestNotifierProvider.select(
//         (value) => value
//             .where((element) => element.waitingDetails.storeCode == storeCode)
//             .firstOrNull));
//     final phoneNumberController = TextEditingController();
//     phoneNumberController.text = waitingInfo?.waitingDetails.phoneNumber ?? "";
//     final formKey = GlobalKey<FormState>();

//     return AlertDialog(
//       title: TextWidget("웨이팅 취소"),
//       content: Form(
//         key: formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextInputWidget(
//               hintText: "전화번호",
//               controller: phoneNumberController,
//               isObscure: false,
//               type: TextInputType.phone,
//               autofillHints: [AutofillHints.telephoneNumber],
//               inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//               minLength: 11,
//               maxLength: 11,
//               ref: ref,
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           child: TextWidget("취소"),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         TextButton(
//           child: TextWidget("확인"),
//           onPressed: () {
//             if (formKey.currentState!.validate()) {
//               Navigator.of(context).pop();
//               // 여기에서 입력된 정보를 처리합니다.
//               // 예를 들어, 웨이팅 취소 요청을 서버에 보내는 로직을 구현할 수 있습니다.
//               print("전화번호: ${phoneNumberController.text}");
//               print("가게 코드: $storeCode");
//               print("웨이팅 취소");
//               ref
//                   .read(storeWaitingRequestNotifierProvider.notifier)
//                   .subscribeToStoreWaitingCancleRequest(
//                     storeCode,
//                     phoneNumberController.text,
//                   );
//               ref
//                   .read(storeWaitingUserCallNotifierProvider.notifier)
//                   .unSubscribe(storeCode, waitingInfo!.waitingDetails.waiting);
//               Navigator.of(context).pop();
//             }
//           },
//         ),
//       ],
//     );
//   }
// }
