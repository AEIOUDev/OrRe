import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/store_list_model.dart';
import 'package:orre/model/store_waiting_info_model.dart';
import 'package:orre/provider/network/websocket/store_waiting_info_list_state_notifier.dart';
import '../storeinfo/store_info_screen.dart';
import 'package:orre/widget/text/text_widget.dart';

class StoreListWidget extends ConsumerWidget {
  final List<StoreLocationInfo> storeList;

  const StoreListWidget({Key? key, required this.storeList}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: storeList.length,
        itemBuilder: (context, index) {
          return StoreItem(storeInfo: storeList[index]);
        },
        separatorBuilder: (context, index) {
          return Divider();
        });
  }
}

class StoreItem extends ConsumerWidget {
  final StoreLocationInfo storeInfo;

  const StoreItem({Key? key, required this.storeInfo}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref
        .read(storeWaitingInfoNotifierProvider.notifier)
        .subscribeToStoreWaitingInfo(storeInfo.storeCode);
    final storeWaitingInfo = ref.watch(
      storeWaitingInfoNotifierProvider.select((state) {
        // state를 StoreWaitingInfo의 리스트로 가정합니다.
        // storeInfo.storeCode와 일치하는 첫 번째 객체를 찾습니다.
        // print("storeInfo.storeCode : ${storeInfo.storeCode}");
        return state.firstWhere(
          (storeWaitingInfo) =>
              storeWaitingInfo.storeCode == storeInfo.storeCode,
          orElse: () => StoreWaitingInfo(
              storeCode: storeInfo.storeCode,
              waitingTeamList: [],
              enteringTeamList: [],
              estimatedWaitingTimePerTeam: 0), // 일치하는 객체가 없을 경우 0을 반환합니다.
        );
      }),
    );
    return InkWell(
      onTap: () {
        // 다음 페이지로 네비게이션
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    StoreDetailInfoWidget(storeCode: storeInfo.storeCode)));
      },
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: storeInfo.storeImageMain,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          width: 50,
          height: 50,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        //title: TextWidget('가게 ${storeInfo.storeCode}: ${storeInfo.storeName}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TextWidget(
                  '${storeInfo.storeName}',
                  fontSize: 28,
                ),
                Spacer(),
                TextWidget(
                  '거리 ${storeInfo.distance.round()}m',
                  fontSize: 18,
                  color: Color(0xFF999999),
                ),
              ],
            ),
            // TextWidget('주소: ${storeInfo.address}'),
            // TextWidget('거리: ${storeInfo.distance.round()}m'),
            // TextWidget('위도: ${storeInfo.latitude}'),
            // TextWidget('경도: ${storeInfo.longitude}'),
            TextWidget(
              '${storeInfo.storeShortIntroduce}',
              fontSize: 18,
              color: Color(0xFF999999),
            ),
            //TextWidget("카테고리: ${storeInfo.storeCategory}"),
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Color(0xFFDD0000),
                ),
                TextWidget(
                  "대기 팀 수 ${storeWaitingInfo.waitingTeamList.length} 팀\t(약 ${storeWaitingInfo.waitingTeamList.length * storeWaitingInfo.estimatedWaitingTimePerTeam}분)",
                  color: Color(0xFFDD0000),
                  fontSize: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
