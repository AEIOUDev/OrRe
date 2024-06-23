import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:orre/widget/appbar/static_app_bar_widget.dart';
import 'package:orre/widget/text/text_widget.dart';
import 'package:photo_view/photo_view.dart';

class PopupDialog {
  static Future<void> show(BuildContext context, String title,
      ImageProvider<Object> imageProvider, int price, String info) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: 300.r,
            height: 450.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 24.r),
                GestureDetector(
                  onTap: () {
                    // Add your onTap logic here
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Scaffold(
                            appBar: PreferredSize(
                              preferredSize: Size.fromHeight(0.25.sh),
                              child: StaticAppBarWidget(
                                title: title,
                                leading: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    context.pop();
                                  },
                                ),
                                backgroundColor: Color(0xFFFFBF52),
                              ),
                            ),
                            body: Container(
                              child: PhotoView(
                                imageProvider: imageProvider,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image(
                      image: imageProvider,
                      width: 180.r,
                      height: 180.r,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.r,
                ),
                TextWidget(
                  title,
                  fontSize: 24.sp,
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextWidget(
                    '$price 원',
                    fontSize: 16.sp.r,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextWidget(
                    info,
                    maxLines: 3,
                    fontSize: 16.sp.r,
                    color: const Color(0xFF5F5F5F),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFBF52),
                  ),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  label: const TextWidget(
                    '닫기',
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
