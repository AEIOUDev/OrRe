import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/menu_info_model.dart';
import 'package:orre/presenter/storeinfo/menu/store_info_screen_menu_popup_widget.dart';
import 'package:orre/widget/loading_indicator/coustom_loading_indicator.dart';
import 'package:orre/widget/text/text_widget.dart';
import 'package:photo_view/photo_view.dart';

class StoreMenuTileWidget extends ConsumerWidget {
  final MenuInfo menu;

  StoreMenuTileWidget({
    required this.menu,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
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
                    fontSize: 28,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextWidget(
                    '${menu.introduce}',
                    textAlign: TextAlign.left,
                    fontSize: 18,
                    color: Color(0xFFDFDFDF),
                    overflow: TextOverflow.ellipsis,
                  ),
                  TextWidget(
                    '${menu.price}원',
                    textAlign: TextAlign.left,
                    fontSize: 24,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            CachedNetworkImage(
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
              placeholder: (context, url) => CustomLoadingIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
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
