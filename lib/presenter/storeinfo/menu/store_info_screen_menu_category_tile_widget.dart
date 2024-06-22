import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:orre/presenter/storeinfo/menu/store_info_screen_menu_list_widget.dart';
import 'package:orre/services/debug_services.dart';
import 'package:orre/widget/text/text_widget.dart';

import '../../../../model/store_info_model.dart';

class StoreMenuCategoryTileWidget extends ConsumerWidget {
  final StoreDetailInfo storeDetailInfo;
  final List<String> categoryKR;

  const StoreMenuCategoryTileWidget(
      {super.key, required this.storeDetailInfo, required this.categoryKR});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    printd("StoreMenuCategoryTileWidget build");
    final menuCategories = storeDetailInfo.menuCategories;

    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: List.generate(categoryKR.length, (index) {
            final category = categoryKR[index];
            return Material(
              color: Colors.white,
              child: Column(
                children: [
                  if (index > 0)
                    Divider(
                      color: const Color(0xFFDFDFDF),
                      thickness: 2.r,
                      endIndent: 10.r,
                      indent: 10.r,
                    ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.r),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: Color(0xFFFFB74D)),
                        SizedBox(
                          width: 5.r,
                        ),
                        TextWidget(category,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFB74D)),
                        SizedBox(
                          width: 5.r,
                        ),
                        const Icon(Icons.auto_awesome,
                            color: Color(0xFFFFB74D)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8.r,
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      // printd("category: $category");
                      final categoryCode =
                          menuCategories.categories.keys.firstWhere(
                        (key) => menuCategories.categories[key] == category,
                        orElse: () => '추천 메뉴',
                      );
                      return StoreMenuListWidget(
                        storeDetailInfo: storeDetailInfo,
                        category: categoryCode,
                      );
                    },
                  ),
                  SizedBox(
                    height: 8.r,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
