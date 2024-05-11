import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/location_model.dart';
import '../../provider/home_screen/store_list_sort_type_provider.dart';
import '../../provider/network/https/store_list_state_notifier.dart';
import 'package:orre/widget/text/text_widget.dart';

class HomeScreenModalBottomSheet extends ConsumerWidget {
  final LocationInfo location;
  const HomeScreenModalBottomSheet({Key? key, required this.location})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowSortType = ref.watch(selectSortTypeProvider);

    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: TextWidget(StoreListSortType.basic.toKoKr()),
                    trailing: nowSortType == StoreListSortType.basic
                        ? Icon(Icons.check, color: Colors.orange)
                        : null,
                    onTap: () {
                      ref.read(selectSortTypeProvider.notifier).state =
                          StoreListSortType.basic;
                      final params = StoreListParameters(
                          sortType: StoreListSortType.basic,
                          latitude: location.latitude,
                          longitude: location.longitude);
                      ref
                          .read(storeListProvider.notifier)
                          .fetchStoreDetailInfo(params);
                      Navigator.pop(context);
                    },
                  ),
                  // 아직 기능 안 함
                  ListTile(
                    title: TextWidget(StoreListSortType.popular.toKoKr()),
                    trailing: nowSortType == StoreListSortType.popular
                        ? Icon(Icons.check, color: Colors.orange)
                        : null,
                    onTap: () {
                      ref.read(selectSortTypeProvider.notifier).state =
                          StoreListSortType.popular;
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: TextWidget(StoreListSortType.nearest.toKoKr()),
                    trailing: nowSortType == StoreListSortType.nearest
                        ? Icon(Icons.check, color: Colors.orange)
                        : null,
                    onTap: () {
                      ref.read(selectSortTypeProvider.notifier).state =
                          StoreListSortType.nearest;
                      final params = StoreListParameters(
                          sortType: StoreListSortType.nearest,
                          latitude: location.latitude,
                          longitude: location.longitude);
                      ref
                          .read(storeListProvider.notifier)
                          .fetchStoreDetailInfo(params);
                      Navigator.pop(context);
                    },
                  ),
                  // 아직 기능 안 함
                  ListTile(
                    title: TextWidget(StoreListSortType.fast.toKoKr()),
                    trailing: nowSortType == StoreListSortType.fast
                        ? Icon(Icons.check, color: Colors.orange)
                        : null,
                    onTap: () {
                      ref.read(selectSortTypeProvider.notifier).state =
                          StoreListSortType.fast;
                      Navigator.pop(context);
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: TextWidget('닫기', color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            );
          },
        );
      },
      child: TextWidget(nowSortType.toKoKr()),
    );
  }
}
