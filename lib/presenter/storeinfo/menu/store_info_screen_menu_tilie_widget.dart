import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orre/model/menu_info_model.dart';
import 'package:orre/presenter/storeinfo/menu/store_info_screen_menu_popup_widget.dart';
import 'package:orre/widget/text/text_widget.dart';

class StoreMenuTileWidget extends ConsumerWidget {
  final MenuInfo menu;

  const StoreMenuTileWidget({
    super.key,
    required this.menu,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.white,
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    menu.menu,
                    textAlign: TextAlign.left,
                    fontSize: 16.r,
                  ),
                  SizedBox(
                    height: 4.r,
                  ),
                  TextWidget(
                    menu.introduce,
                    textAlign: TextAlign.left,
                    fontSize: 16.r,
                    color: const Color.fromARGB(255, 133, 133, 133),
                    overflow: TextOverflow.ellipsis,
                  ),
                  TextWidget(
                    '${menu.price}원',
                    textAlign: TextAlign.left,
                    fontSize: 16.r,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 16.r,
            ),
            CachedNetworkImage(
                imageUrl: menu.image,
                imageBuilder: (context, imageProvider) => Container(
                      width: 72.r,
                      height: 72.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(10.0.r),
                      ),
                    ),
                errorWidget: (context, url, error) {
                  return Container(
                    width: 72.r,
                    height: 72.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.0.r),
                    ),
                    child: Icon(
                      Icons.no_food_rounded,
                      color: Colors.white,
                      size: 60.r,
                    ),
                  );
                }),
          ],
        ),
        onTap: () {
          PopupDialog.show(
              context,
              menu.menu,
              CachedNetworkImageProvider(menu.image),
              menu.price,
              menu.introduce);
        },
      ),
    );
  }
}
