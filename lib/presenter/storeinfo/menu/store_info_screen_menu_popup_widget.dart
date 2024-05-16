import 'package:flutter/material.dart';
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
            width: MediaQuery.of(context).size.width * 0.7,
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              children: [
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    // Add your onTap logic here
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoView(
                          imageProvider: imageProvider,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image(
                      image: imageProvider,
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextWidget(
                  title,
                  fontSize: 25,
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextWidget(
                    '${price} 원',
                    fontSize: 15,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextWidget(
                    info,
                    maxLines: 3,
                    fontSize: 15,
                    color: Color(0xFF5F5F5F),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFBF52),
                  ),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  label: const TextWidget(
                    'close',
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
