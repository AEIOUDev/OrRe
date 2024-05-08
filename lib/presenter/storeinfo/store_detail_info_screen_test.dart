import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/store_info_model.dart';
import 'package:orre/presenter/storeinfo/store_detail_info_screen.dart';
import 'package:sliver_app_bar_builder/sliver_app_bar_builder.dart';

class StoreDetailInfoTestScreen extends ConsumerWidget {
  final StoreDetailInfo storeDetailInfo;

  const StoreDetailInfoTestScreen({Key? key, required this.storeDetailInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      child: CustomScrollView(
        slivers: [
          SliverAppBarBuilder(
            backgroundColorAll: Colors.orange,
            backgroundColorBar: Colors.transparent,
            debug: false,
            barHeight: 40,
            initialBarHeight: 40,
            pinned: true,
            leadingActions: [
              (context, expandRatio, barHeight, overlapsContent) {
                return SizedBox(
                  height: barHeight,
                  child: const BackButton(color: Colors.white),
                );
              }
            ],
            trailingActions: [
              (context, expandRatio, barHeight, overlapsContent) {
                return SizedBox(
                    height: barHeight,
                    child: IconButton(
                      color: Colors.white,
                      onPressed: () async {
                        // Call the store
                        print(
                            'Call the store: ${storeDetailInfo.storePhoneNumber}');
                        await FlutterPhoneDirectCaller.callNumber(
                            storeDetailInfo.storePhoneNumber);
                      },
                      icon: Icon(Icons.phone),
                    ));
              },
              (context, expandRatio, barHeight, overlapsContent) {
                return SizedBox(
                    height: barHeight,
                    child: IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.info),
                      onPressed: () {
                        // Navigate to the store detail info page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StoreDetailInfoScreen(
                                storeDetailInfo: storeDetailInfo),
                          ),
                        );
                      },
                    ));
              }
            ],
            initialContentHeight: 400,
            contentBuilder: (
              context,
              expandRatio,
              contentHeight,
              centerPadding,
              overlapsContent,
            ) {
              return Stack(
                children: [
                  // All height image that fades away on scroll.
                  Opacity(
                    opacity: expandRatio,
                    child: ShaderMask(
                      shaderCallback: _shaderCallback,
                      blendMode: BlendMode.dstIn,
                      child: Image(
                          height: contentHeight,
                          width: double.infinity,
                          fit: BoxFit.fill,
                          alignment: Alignment.topCenter,
                          image: CachedNetworkImageProvider(
                            storeDetailInfo.storeImageMain,
                          )),
                    ),
                  ),

                  // Using alignment and padding, centers text to center of bar.
                  Container(
                    alignment: Alignment.centerLeft,
                    height: contentHeight,
                    padding: centerPadding.copyWith(
                      left: 10 + (1 - expandRatio) * 40,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        storeDetailInfo.storeName,
                        style: TextStyle(
                          fontSize: 24 + expandRatio * 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Color.lerp(
                                    Colors.black,
                                    Colors.transparent,
                                    1 - expandRatio,
                                  ) ??
                                  Colors.transparent,
                              blurRadius: 10,
                              offset: const Offset(4, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          StoreMenuListWidget(storeDetailInfo: storeDetailInfo),
          SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Container(
                    color: Colors.red[100 * (index % 9)],
                  );
                },
                childCount: 100,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                // 한 줄에 보일 내용의 수 - 필수값
                crossAxisCount: 2,

                // GridView Item 간의 세로 간격
                crossAxisSpacing: 5,

                // GridView Item 간의 가로 간격
                mainAxisSpacing: 5,

                // GridView Item 의 가로 길이
                mainAxisExtent: 200,
              )),
        ],
      ),
    );
  }

  Shader _shaderCallback(Rect rect) {
    return const LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Colors.black, Colors.transparent],
      stops: [0.6, 1],
    ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
  }
}

class StoreMenuListWidget extends ConsumerWidget {
  final StoreDetailInfo storeDetailInfo;

  StoreMenuListWidget({required this.storeDetailInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (storeDetailInfo.menuInfo.length < 1) {
      return SliverToBoxAdapter(
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 100.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.menu_book, size: 50),
              Text('메뉴 정보가 없습니다.'),
            ],
          ),
        ),
      );
    } else {
      return SliverToBoxAdapter(
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: storeDetailInfo.menuInfo.length,
          itemBuilder: (context, index) {
            final menu = storeDetailInfo.menuInfo[index];
            return Material(
              child: ListTile(
                leading: CachedNetworkImage(
                  imageUrl: menu.image,
                  imageBuilder: (context, imageProvider) => Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                title: Text(menu.menu),
                subtitle: Text('${menu.price}원 - ${menu.introduce}'),
              ),
            );
          },
          separatorBuilder: (context, index) => Divider(),
        ),
      );
    }
  }
}
