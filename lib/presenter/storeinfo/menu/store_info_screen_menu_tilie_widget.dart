import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/menu_info_model.dart';
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
          title: TextWidget(
            menu.menu,
            textAlign: TextAlign.left,
          ),
          subtitle: TextWidget('${menu.price}원 - ${menu.introduce}',
              textAlign: TextAlign.left),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return Scaffold(
                  appBar: AppBar(
                    title: TextWidget(menu.menu),
                  ),
                  body: PhotoView(
                    imageProvider: CachedNetworkImageProvider(menu.image),
                  ));
            }));
          }),
    );
  }
}
