import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/location_model.dart';
import '../provider/location_securestorage_provider.dart'; // 필요에 따라 경로 수정
import '../provider/location_info_provider.dart'; // 필요에 따라 경로 수정

class LocationManagementScreen extends ConsumerStatefulWidget {
  @override
  _LocationManagementScreenState createState() =>
      _LocationManagementScreenState();
}

class _LocationManagementScreenState
    extends ConsumerState<LocationManagementScreen> {
  bool _isDeleteMode = false; // 삭제 모드 상태
  Set<String> _selectedLocations = {}; // 선택된 위치를 관리하는 Set

  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode;
      _selectedLocations.clear(); // 모드 전환 시 선택 상태 초기화
    });
  }

  void _toggleLocationSelection(String locationName) {
    if (locationName == 'nowLocation') {
      // nowLocation은 선택되지 않도록 함.
      return;
    }
    setState(() {
      if (_selectedLocations.contains(locationName)) {
        _selectedLocations.remove(locationName);
      } else {
        _selectedLocations.add(locationName);
      }
    });
  }

  void _deleteSelectedLocations(WidgetRef ref) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('삭제하시겠습니까?'),
        content: Text('선택된 위치를 삭제합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('확인'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('취소'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      // 선택된 위치 삭제
      for (String locationName in _selectedLocations) {
        ref.read(locationListProvider.notifier).removeLocation(locationName);
      }
      setState(() {
        _isDeleteMode = false; // 삭제 후 모드 종료
        _selectedLocations.clear(); // 선택 상태 초기화
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final myLocationAsyncValue = ref.watch(locationProvider);
    final locations = ref.watch(locationListProvider);
    final selectedLocation = locations.selectedLocation;

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedLocation?.locationName ?? '위치 목록'),
        actions: [
          IconButton(
            icon: Icon(_isDeleteMode ? Icons.delete : Icons.add),
            onPressed: () async {
              if (_isDeleteMode) {
                _deleteSelectedLocations(ref);
              } else {
                final newLocationName = await showDialog<String>(
                  context: context,
                  builder: (context) => NewLocationDialog(),
                );

                myLocationAsyncValue.when(
                  data: (myLocation) {
                    // 권한 상태와 위치 정보 확인
                    if (!myLocation.isPermissionGranted ||
                        myLocation.locationInfo == null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('오류'),
                          content: Text('위치 정보를 추가할 수 없습니다. 위치 서비스 권한을 확인하세요.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('확인'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    // 정상적인 경우, 위치 정보 추가
                    if (newLocationName != null && newLocationName.isNotEmpty) {
                      ref.read(locationListProvider.notifier).addLocation(
                            LocationModel(
                              locationName: newLocationName,
                              latitude: myLocation.locationInfo!.latitude,
                              longitude: myLocation.locationInfo!.longitude,
                              address: myLocation.locationInfo!.address,
                            ),
                          );
                    }
                  },
                  loading: () => {},
                  error: (error, stack) => {},
                );
              }
            },
          ),
          if (_isDeleteMode)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: _toggleDeleteMode,
            )
          else
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: _toggleDeleteMode,
            ),
        ],
      ),
      body: myLocationAsyncValue.when(
        data: (myLocation) => ListView.builder(
          itemCount: locations.locations.length,
          itemBuilder: (context, index) {
            final location = locations.locations[index];
            final isSelected =
                _selectedLocations.contains(location.locationName);

            return ListTile(
              title: Text(location.locationName),
              subtitle: Text('${location.address}'),
              onTap: () {
                if (_isDeleteMode) {
                  _toggleLocationSelection(location.locationName);
                } else {
                  ref
                      .read(locationListProvider.notifier)
                      .selectLocation(location);
                }
              },
              selected: isSelected,
              selectedTileColor: Colors.grey[300],
            );
          },
        ),
        loading: () => CircularProgressIndicator(),
        error: (error, stack) => Text('오류 발생: $error'),
      ),
    );
  }
}

class NewLocationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    return AlertDialog(
      title: Text('새 위치 추가'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: '위치 이름 입력',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text('추가'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('취소'),
        ),
      ],
    );
  }
}
