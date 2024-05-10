import 'package:flutter/material.dart';
import 'package:orre/model/store_info_model.dart';
import 'package:live_activities/live_activities.dart';
import 'package:orre/presenter/storeinfo/store_detail_info_screen_test.dart';

class StoreDetailInfoScreen extends StatelessWidget {
  final StoreDetailInfo storeDetailInfo;

  const StoreDetailInfoScreen({Key? key, required this.storeDetailInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _liveActivitiesPlugin = LiveActivities();
    _liveActivitiesPlugin.init(appGroupId: "group.orre.liveactivities");
    return Scaffold(
      appBar: AppBar(
        title: Text('Store Detail Info'),
        actions: [
          IconButton(
              icon: Icon(Icons.edit_note_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoreDetailInfoTestScreen(
                      storeDetailInfo: storeDetailInfo,
                    ),
                  ),
                );
              }),
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                final Map<String, dynamic> activityModel = {
                  'name': 'Margherita',
                  'ingredient': 'tomato, mozzarella, basil',
                  'quantity': 1,
                };

                _liveActivitiesPlugin.createActivity(activityModel);
              }),
          IconButton(
              icon: Icon(Icons.expand_circle_down),
              onPressed: () {
                _liveActivitiesPlugin.endAllActivities();
              }),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Name'),
            subtitle: Text(storeDetailInfo.storeName),
          ),
          ListTile(
            title: Text('Category'),
            subtitle: Text(storeDetailInfo.storeCategory),
          ),
          ListTile(
            title: Text('Introduce'),
            subtitle: Text(storeDetailInfo.storeIntroduce),
          ),
          ListTile(
            title: Text('Number of Teams Waiting'),
            subtitle: Text(storeDetailInfo.numberOfTeamsWaiting.toString()),
          ),
          ListTile(
            title: Text('Estimated Waiting Time'),
            subtitle: Text(storeDetailInfo.estimatedWaitingTime.toString()),
          ),
          ListTile(
            title: Text('Opening Time'),
            subtitle: Text(storeDetailInfo.openingTime.toString()),
          ),
          ListTile(
            title: Text('Closing Time'),
            subtitle: Text(storeDetailInfo.closingTime.toString()),
          ),
          ListTile(
            title: Text('Last Order Time'),
            subtitle: Text(storeDetailInfo.lastOrderTime.toString()),
          ),
          ListTile(
            title: Text('Break Start Time'),
            subtitle: Text(storeDetailInfo.breakStartTime.toString()),
          ),
          ListTile(
            title: Text('Break End Time'),
            subtitle: Text(storeDetailInfo.breakEndTime.toString()),
          ),
          ListTile(
            title: Text('Phone Number'),
            subtitle: Text(storeDetailInfo.storePhoneNumber),
          ),
          ListTile(
            title: Text('Location Info'),
            subtitle: Text(storeDetailInfo.locationInfo.toString()),
          ),
          ListTile(
            title: Text('Menu Info'),
            subtitle: Text(storeDetailInfo.menuInfo.toString()),
          ),
        ],
      ),
    );
  }
}
