import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          child: TextWidget(category.toKoKr()),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                selectedTitle == category ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    );
  }
}
