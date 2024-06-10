import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:orre/widget/text/text_widget.dart';

import '../../provider/home_screen/store_category_provider.dart';

class CategoryItem extends ConsumerWidget {
  final StoreCategory category;

  const CategoryItem({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTitle = ref.watch(selectCategoryProvider);

    return ButtonBar(
      children: [
        ElevatedButton(
          onPressed: () {
            ref.read(selectCategoryProvider.notifier).state = category;
            print("category : " +
                ref.read(selectCategoryProvider.notifier).state.toKoKr());
          },
          child: TextWidget(
            category.toKoKr(),
            color: selectedTitle == category ? Colors.white : Colors.black,
            fontSize: 16.sp,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                selectedTitle == category ? Color(0xFFFFFFBF52) : Colors.white,
            foregroundColor: Color(0xFFFFFFBF52),
          ),
        ),
      ],
    );
  }
}
