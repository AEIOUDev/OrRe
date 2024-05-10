import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/model/location_model.dart';

import '../../provider/home_screen/store_category_provider.dart';
import 'home_screen_modal_sheet.dart';
import '../../widget/grid/grid_tile_widget.dart';

class CategoryWidget extends ConsumerWidget {
  final LocationInfo location;
  const CategoryWidget({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowCategory = ref.watch(selectCategoryProvider);
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CategoryItem(category: StoreCategory.all),
            CategoryItem(category: StoreCategory.korean),
            CategoryItem(category: StoreCategory.chinese),
            CategoryItem(category: StoreCategory.japanese),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CategoryItem(category: StoreCategory.western),
            CategoryItem(category: StoreCategory.snack),
            CategoryItem(category: StoreCategory.cafe),
            CategoryItem(category: StoreCategory.etc),
          ],
        ),
        Row(
          children: [
            Text(nowCategory.toKoKr(),
                style: Theme.of(context).textTheme.headline6),
            Spacer(),
            HomeScreenModalBottomSheet(location: location),
          ],
        ),
      ],
    );
  }
}
