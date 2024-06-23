import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:orre/model/location_model.dart';

import '../../provider/home_screen/store_category_provider.dart';
import 'home_screen_modal_sheet.dart';
import '../../widget/grid/grid_tile_widget.dart';
import 'package:orre/widget/text/text_widget.dart';

class CategoryWidget extends ConsumerWidget {
  final LocationInfo location;
  const CategoryWidget({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowCategory = ref.watch(selectCategoryProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CategoryItem(category: StoreCategory.all),
                  CategoryItem(category: StoreCategory.korean),
                  CategoryItem(category: StoreCategory.chinese),
                  CategoryItem(category: StoreCategory.japanese),
                  CategoryItem(category: StoreCategory.western),
                  CategoryItem(category: StoreCategory.snack),
                  CategoryItem(category: StoreCategory.cafe),
                  CategoryItem(category: StoreCategory.etc),
                ],
              ),
            ),
          ),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextWidget(nowCategory.toKoKr(),
                  fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            HomeScreenModalBottomSheet(location: location),
          ],
        ),
      ],
    );
  }
}
