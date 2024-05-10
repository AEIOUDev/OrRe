import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/presenter/storeinfo/menu/store_info_screen_menu_list_widget.dart';
import 'package:orre/widget/text/text_widget.dart';

import '../../../model/store_info_model.dart';

class StoreMenuCategoryTileWidget extends ConsumerWidget {
  final StoreDetailInfo storeDetailInfo;

  StoreMenuCategoryTileWidget({required this.storeDetailInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuCategories = storeDetailInfo.menuCategories;
    final categoryKR = menuCategories.getCategories();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categoryKR.length,
      itemBuilder: (context, index) {
        final category = categoryKR[index];
        print("category: $category");
        final categoryCode = menuCategories.categories.keys.firstWhere(
          (key) => menuCategories.categories[key] == category,
          orElse: () => '',
        );
        print("categoryCode: $categoryCode");
        return Material(
          child: Column(
            children: [
              TextWidget(category, fontSize: 40, fontWeight: FontWeight.bold),
              StoreMenuListWidget(
                storeDetailInfo: storeDetailInfo,
                category: categoryCode,
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) => Divider(),
    );
  }
}
