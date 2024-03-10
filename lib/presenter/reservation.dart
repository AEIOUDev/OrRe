import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre/provider/store_waiting_state_notifier.dart';

import '../services/storeservice.dart';

final storeService = StoreService();

class ReservationPage extends ConsumerStatefulWidget {
  final String storeCode;

  ReservationPage({required this.storeCode});

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends ConsumerState<ReservationPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _peopleController = TextEditingController();

  late String storeName;

  int waitingTeams = 0;
  int peopleCount = 1;
  String? peopleCountError; // 인원 수 입력 에러 메시지
  bool isWaiting = false; // 웨이팅 상태
  int? waitingNumber; // 사용자의 웨이팅 번호
  int estimatedWaitTime = 0; // 예상 대기 시간 (분)

  @override
  void initState() {
    super.initState();

    final storeInfo = storeService.getStoreInfo(widget.storeCode);
    if (storeInfo != null) {
      storeName = storeInfo['storeName'] ?? '알 수 없는 상점';
      waitingTeams = storeInfo['storeWaitingInfo'] ?? 0;
    } else {
      storeName = '알 수 없는 상점';
      waitingTeams = 0;
    }

    _peopleController.text = peopleCount.toString();
  }

  void _showWaitingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('웨이팅 시작'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('이름'),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: '이름을 입력하세요',
                  ),
                ),
                SizedBox(height: 20),
                Text('전화번호'),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '전화번호를 입력하세요',
                  ),
                ),
                SizedBox(height: 20),
                Text('인원 수'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () => setState(() {
                        if (peopleCount > 1) {
                          peopleCount--;
                          _peopleController.text = peopleCount.toString();
                        }
                      }),
                    ),
                    Container(
                      width: 50,
                      child: TextField(
                        controller: _peopleController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          int? enteredValue = int.tryParse(value);
                          if (enteredValue != null &&
                              enteredValue >= 1 &&
                              enteredValue <= 20) {
                            setState(() {
                              peopleCount = enteredValue;
                            });
                          } else {
                            // 입력값이 범위를 벗어나면 이전 유효한 값으로 복원
                            _peopleController.text = peopleCount.toString();
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => setState(() {
                        if (peopleCount < 20) {
                          peopleCount++;
                          _peopleController.text = peopleCount.toString();
                        }
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                _startWaiting();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _startWaiting() {
    final currentWaitingNumber = waitingTeams + 1; // 새로운 웨이팅 번호
    final currentEstimatedTime = currentWaitingNumber * 5; // 각 팀 당 5분으로 가정

    setState(() {
      waitingTeams = currentWaitingNumber;
      waitingNumber = currentWaitingNumber;
      estimatedWaitTime = currentEstimatedTime;
      isWaiting = true; // 웨이팅 상태 활성화
    });
  }

  void _cancelWaiting() {
    if (isWaiting && waitingTeams > 0) {
      // 웨이팅 중이고, 웨이팅 팀 수가 0보다 클 때만 감소
      setState(() {
        isWaiting = false; // 웨이팅 취소
        waitingNumber = null; // 웨이팅 번호 초기화
        estimatedWaitTime = 0; // 예상 대기 시간 초기화
        waitingTeams -= 1; // 웨이팅 팀 수 감소
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // StreamProvider를 사용하여 StoreWaitingInfo 정보를 실시간으로 받아옵니다.
    final storeWaitingInfoAsyncValue =
        ref.watch(storeWaitingInfoStreamProvider(widget.storeCode));

    return Scaffold(
      appBar: AppBar(
        title: Text(storeName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isWaiting)
              Text(
                  "당신의 웨이팅 번호: $waitingNumber, 예상 대기 시간: ${estimatedWaitTime}분"),
            Text(
                "This is the Reservation Page for store code: ${widget.storeCode}"),
            SizedBox(height: 20),
            Text("현재 웨이팅 팀 수: $waitingTeams명"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isWaiting ? _cancelWaiting : _showWaitingDialog,
              child: Text(isWaiting ? "웨이팅 취소" : "웨이팅 시작"),
            ),
          ],
        ),
      ),
    );
  }
}
